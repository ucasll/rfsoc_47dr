# Project 02: AXI LED Control via lwIP

### 📝 功能描述
通过 ZynqMP 的 PS 端运行 lwIP 协议栈建立 TCP Server，接收上位机 Python 脚本发送的指令，通过 AXI GPIO 控制 PL 端的 4-bit LED。

### 📁 目录结构 (Structure)
* `hw_export/`: 硬件导出描述文件 (.xsa)，沿用01_axi_led硬件平台，BD参考[**01_axi_led**](../01_axi_led/doc/Minimumsys_BD.png)
* `src/`: 硬件 HDL 源码及约束 (HDL, XDC)
* `vitis/src/`: 嵌入式 C 源码 (TCP Server 逻辑)
* `host/`: Python 上位机控制脚本
* `scripts/`: Vivado/Vitis 工程重建 Tcl 脚本

### 🛠 关键配置
* **IP Address**: 192.168.1.10 (Default)
* **TCP Port**: 6001
* **AXI GPIO BaseAddr**: 0xA0000000 (请根据 Address Editor 确认)

### 🚀 重建步骤
1. **Hardware**: 在 Vivado 中 `source scripts/rebuild_hw.tcl`。
2. **Software**: 打开 Vitis，指定 `vitis/` 为 workspace，导入 `vitis/src` 下的源码。
3. **Run**: 先运行板载程序，再运行 `python host/led_ctrl.py`。