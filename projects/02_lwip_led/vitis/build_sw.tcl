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

# 获取 BSP 的 include 路径 (根据你的目录层级可能需要微调)
set bsp_inc_path [file normalize "$ws_path/hw_platform/psu_cortexa53_0/standalone_domain/bsp/psu_cortexa53_0/include"]

