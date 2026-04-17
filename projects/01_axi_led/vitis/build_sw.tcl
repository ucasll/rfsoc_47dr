# Vitis XSCT 自动化重建脚本
# 使用方法：在 XSCT Console 输入 source build_sw.tcl

# 获取脚本所在的绝对路径 (也就是你仓库里的 vitis 文件夹)
set repo_vitis_path [file normalize [file dirname [info script]]]
set repo_root [file normalize "$repo_vitis_path/.."]

# 1. 定义路径 (现在它们都指向仓库里的种子文件)
set ws_name "./workspace" ;# 在当前 temp 目录下创建工作区
set xsa_path "$repo_root/hw_export/system_wrapper.xsa"
set src_path "$repo_vitis_path/src"

# 2. 设置当前 temp 目录为工作空间
setws $ws_name

# 3. 创建 Platform (指向仓库里的 XSA)
platform create -name "hw_platform" -hw $xsa_path -proc {psu_cortexa53_0} -os {standalone}

# 4. 创建 Application
app create -name "led_app" -platform "hw_platform" -domain "standalone_domain" -template {Empty Application}

# 5. 导入仓库里的源码 (核心：这会将源码链接或拷贝到 temp)
importsources -name "led_app" -path $src_path

# 6. 编译
app build -name "led_app"

puts "--- Vitis Project Rebuild Successfully! ---"