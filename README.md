# rfsoc_47dr
# 项目名称 (Project Name): [RFSoC-Data-Acquisition]

[Optional: Add a one-sentence project summary here / 在此处添加一句话的项目简介]

---

## 🌏 Language / 语言
- [English](#english-version)
- [中文版](#中文版)

---

<a name="english-version"></a>
## English Version

### 🛠 Development Environment
* **Hardware**: Xilinx RFSoC [e.g., ZCU111 / ZCU216]
* **Vivado Version**: 202x.x
* **Software**: Vitis / SDK 202x.x
* **Host Side**: Python 3.x (PYNQ compatible)

### 📁 Directory Structure
* `hw/`: Verilog/SystemVerilog sources, XDC constraints.
* `ip/`: IP configuration files (.xci).
* `sw/`: Embedded C source code (Vitis).
* `python/`: Host scripts and Jupyter Notebooks.
* `scripts/`: Tcl scripts for project recreation.
* `bitstream/`: Pre-compiled `.bit` and `.hwh` files.

### 🚀 How to Rebuild
1. Open **Vivado Tcl Console**.
2. Navigate to the project root: `cd <project_path>/scripts/`.
3. Run: `source rebuild_project.tcl`.

---

<a name="中文版"></a>
## 中文版

### 🛠 开发环境
* **硬件平台**: Xilinx RFSoC [例如：ZCU111 / ZCU216]
* **Vivado 版本**: 202x.x
* **软件开发**: Vitis / SDK 202x.x
* **上位机**: Python 3.x (兼容 PYNQ)

### 📁 目录结构说明
* `hw/`: 包含 Verilog/SystemVerilog 源码、XDC 约束。
* `ip/`: IP 核配置文件 (.xci)。
* `sw/`: 嵌入式 C 源码 (Vitis 工程)。
* `python/`: 上位机控制脚本、Jupyter 演示。
* `scripts/`: 包含工程重建的 Tcl 脚本。
* `bitstream/`: 存放已编译的比特流 (.bit) 和硬件描述 (.hwh)。

### 🚀 如何重建工程
1. 打开 **Vivado Tcl Console**。
2. 切换到项目路径: `cd <项目路径>/scripts/`。
3. 执行命令: `source rebuild_project.tcl`。

---

## 📄 License / 开源协议
This project is licensed under the **MIT License**.
本项目采用 **MIT** 开源协议。