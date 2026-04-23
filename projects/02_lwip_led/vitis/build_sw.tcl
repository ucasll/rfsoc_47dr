# Vitis XSCT 自动化重建脚本
# 使用方法：在 XSCT Console 输入 source build_sw.tcl

# 1. 路径自动定位
set script_dir [file normalize [file dirname [info script]]]
set repo_root  [file normalize "$script_dir/../.."] ;# 根据你的目录深度调整 .. 的数量

# 打印出来检查一下，这是最稳妥的调试方法
puts "-----------------------------------------------"
puts "Script Dir: $script_dir"
puts "Repo Root:  $repo_root"
puts "-----------------------------------------------"


# "D:\LL\rfsoc_47dr\projects\01_axi_led\hw_export\system_wrapper.xsa"
set xsa_path   "$repo_root/01_axi_led/hw_export/system_wrapper.xsa"
set src_path   "$script_dir/src"
set ws_path    "./workspace"

# 2. 清理旧环境
if {[file exists $ws_path]} {
    file delete -force $ws_path
}
setws $ws_path

# 3. 创建平台 (Platform)
platform create -name "hw_platform" -hw $xsa_path -os {standalone} -proc {psu_cortexa53_0}
platform write

# 4. 配置 LWIP 库 (BSP)
platform active {hw_platform}
domain active {standalone_domain}
bsp setlib -name lwip211

# 基础开关（加上 catch 防止因为版本不同导致的参数名报错）
catch {bsp config lwip_dhcp true}
catch {bsp config lwip_arp true}
catch {bsp config dhcp_does_arp_check false}
bsp config mem_size 131072

# --- 关键修改：先不急着 generate，先创建 App 并导通路径 ---

# 5. 创建应用 (Application)
app create -name "lwip_led_app" -platform "hw_platform" -domain {standalone_domain} -template {Empty Application}

# 6. 导入源码 (包含你补齐的 platform.c/h 和 debug.h)
importsources -name "lwip_led_app" -path $src_path

# # 2. 补齐宏定义，告诉代码我们是 ZynqMP 平台
# app config -name "lwip_led_app" define-macros {PLATFORM_ZYNQMP}

# # 3. 补齐链接库 (注意顺序)
# app config -name "lwip_led_app" -add libraries {m xil lwip211}

# 4. 允许重复定义 (防止 src 里的 physpeed 和库里的冲突)
# app config -name "lwip_led_app" -add linker-flags {-Wl,--allow-multiple-definition}

# --- 核心：手动强制指定 Include 路径，解决 debug.h 找不到的问题 ---

# 获取 BSP 的 include 路径 (根据你的目录层级可能需要微调)
set bsp_inc_path [file normalize "$ws_path/hw_platform/export/hw_platform/sw/hw_platform/standalone_domain/bspinclude/include"]
# D:\temp\workspace\hw_platform\export\hw_platform\sw\hw_platform\standalone_domain\bspinclude\include


# 这行命令会把你的 src 目录置于最高优先级
app config -name "lwip_led_app" include-path $src_path
app config -name "lwip_led_app" include-path "$bsp_inc_path"

# 7. 编译平台和应用
# 此时 generate 会看到你 App 目录下的头文件
platform generate
app build -name "lwip_led_app"

puts "--- Vitis Project Rebuild Successfully! ---"

# # 获取 BSP 的 include 路径 (根据你的目录层级可能需要微调)
# set bsp_inc_path [file normalize "$ws_path/hw_platform/psu_cortexa53_0/standalone_domain/bsp/psu_cortexa53_0/include"]



# # =================================================================
# # Vitis XSCT 自动化重建脚本 (RFSoC LWIP 专项版)
# # =================================================================

# # 1. 路径自动定位
# set script_dir [file normalize [file dirname [info script]]]
# set repo_root  [file normalize "$script_dir/../.."] 
# set xsa_path   "$repo_root/01_axi_led/hw_export/system_wrapper.xsa"
# set src_path   "$script_dir/src"
# set ws_path    "./workspace"

# # 清理并创建新 workspace
# if {[file exists $ws_path]} { file delete -force $ws_path }
# setws $ws_path

# # 2. 创建平台 (Platform)
# # 这一步会自动创建默认的 System Config，避免 DEPRECATED 警告
# platform create -name "hw_platform" -hw $xsa_path -proc {psu_cortexa53_0} -os {standalone}
# platform write

# # 3. 配置 LWIP 库 (BSP)
# domain active {standalone_domain}
# bsp setlib -name lwip211

# # 使用 catch 确保脚本不会因为某个 Vitis 版本不支持某个参数而挂掉
# catch {bsp config lwip_dhcp true}
# catch {bsp config lwip_arp true}
# catch {bsp config dhcp_does_arp_check false}
# catch {bsp config mem_size 131072}
# catch {bsp config pbuf_pool_size 1024}

# # 预生成平台，确保 include 文件夹出现
# platform generate

# # 4. 创建应用 (Application)
# app create -name "lwip_led_app" -platform "hw_platform" -domain {standalone_domain} -template {Empty Application}

# # 5. 导入所有源码 (包含你补齐的 platform_zynqmp.c/h, debug.h, physpeed.c 等)
# importsources -name "lwip_led_app" -path $src_path

# # 6. 编译器参数调优 (这是解决报错的核心)
# # 6.1 强制添加 Include 路径，确保找到 debug.h 和驱动头文件
# set bsp_inc [file normalize "$ws_path/hw_platform/psu_cortexa53_0/standalone_domain/bsp/psu_cortexa53_0/include"]
# app config -name "lwip_led_app" include-path $src_path
# app config -name "lwip_led_app" include-path $bsp_inc

# # 6.2 添加底层宏定义，激活 platform.c 里的 ZynqMP 逻辑
# app config -name "lwip_led_app" define-macros {PLATFORM_ZYNQMP}

# # 6.3 补齐库引用
# app config -name "lwip_led_app" -add libraries {m xil lwip211}

# # 6.4 终极必杀：允许重复定义函数 (允许 src 里的 physpeed 覆盖库里的)
# app config -name "lwip_led_app" -add linker-flags {-Wl,--allow-multiple-definition}

# # 7. 执行最终编译
# puts "--- Starting Final Build ---"
# app build -name "lwip_led_app" -type all

# # 8. 结果检查
# set elf_file "$ws_path/lwip_led_app/Debug/lwip_led_app.elf"
# if {[file exists $elf_file]} {
#     puts "==============================================="
#     puts "SUCCESS: ELF Generated at $elf_file"
#     puts "==============================================="
# } else {
#     error "ERROR: Build failed. Please check the log in GUI Console."
# }

