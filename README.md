## 📄 License / 开源协议
This project is licensed under the **MIT License**.
本项目采用 **MIT** 开源协议。

# RFSoC-Data: Multi-Project Exploration
本项目是一个基于 **XCZU47DR (RFSoC Gen3)** 的综合实验仓库，涵盖了从基础外设控制到高速数据传输的多个子工程。

---

## 🛠 开发环境 (Global Environment)
* **Hardware**: AMD/Xilinx RFSoC [xczu47dr] (e.g., ZCU216 or Custom Board)
* **Toolchain**: Vivado / Vitis 2022.2
* **Host Side**: Python 3.10+
* **Language**: C (Embedded), Verilog/SystemVerilog, Python

---

## 📁 项目导航 (Project Navigation)

| 工程名称 (Project) | 核心功能 (Core Features) | 状态 (Status) |
| :--- | :--- | :--- |
| [**01_axi_led**](./projects/01_axi_led/) | 最小系统构建&led blink | ✅ Done |
| [**02_lwip_led**](./projects/02_lwip_led/) | lwIP TCP 通信控制 4-bit LED，Python 上位机 | ✅ Done |
| [**03_ada_loop**](./projects/03_ada_loop/) | RFDC 数据采集与 AXI-Stream 传输 | 🛠 WIP |

---

## 🚀 快速上手 (Quick Start)
每个子工程都是独立的，请进入对应的子目录查看详细的重建指南：
1. `cd projects/01_axi_led`
2. 阅读该目录下的 `README.md` 执行重建。

---

## 📄 License / 开源协议
This project is licensed under the **MIT License**.
本项目采用 **MIT** 开源协议。
本仓库代码仅供学习与技术交流。