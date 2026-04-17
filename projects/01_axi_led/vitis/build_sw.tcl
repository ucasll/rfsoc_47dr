# Vitis XSCT 自动化重建脚本
# 使用方法：在 XSCT Console 输入 source build_sw.tcl

# 1. 定义路径
set ws_name "workspace"
set xsa_path "../hw_export/system_wrapper.xsa"
set src_path "./src"

# 2. 清理并创建工作区
setws $ws_name

# 3. 创建 Platform (基于 XSA)
# 注意：如果是 Cortex-A53 核心，使用 psu_cortexa53_0
platform create -name "hw_platform" -hw $xsa_path -proc {psu_cortexa53_0} -os {standalone} -out .

# 4. 创建 Application
app create -name "led_app" -platform "hw_platform" -domain "standalone_domain" -template {Empty Application}

# 5. 导入源码文件
importsources -name "led_app" -path $src_path

# 6. 编译
app build -name "led_app"

puts "--- Vitis Project Rebuild Successfully! ---"