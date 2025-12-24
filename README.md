# AHB-to-APB-Bridge-Converter-RTL-Design-and-FPGA-Implementation
AHB to APB Bridge implemented in Verilog HDL. The design converts high-performance AHB transactions into APB-compliant accesses using FSM-based control. Supports single read, single write, and burst write operations. Verified with ModelSim waveforms and synthesized using Intel Quartus Prime.
# AHB to APB Bridge – Verilog RTL Design

## Overview
This project implements an AHB to APB bridge using Verilog HDL. The bridge converts high-performance AHB transactions into APB-compliant accesses using FSM-based control logic. It supports single read, single write, and burst write operations.

The design is fully synthesizable, verified through simulation, and suitable for FPGA-based SoC designs.

---

## Architecture
The bridge consists of:
- AHB Slave Interface
- APB Controller (FSM-based)
- APB Interface
- Bridge Top module

AHB pipelined transfers are converted into APB SETUP and ENABLE phases while maintaining protocol correctness.

---

## Supported Transactions
| Operation     | Supported |
|--------------|-----------|
| Single Write | Yes |
| Single Read  | Yes |
| Burst Write | Yes |
| Burst Read  | Not implemented |

---

## FSM Description
The APB controller uses the following states:
- ST_IDLE
- ST_WAIT
- ST_WRITE / ST_WRITEP
- ST_WENABLE / ST_WENABLEP
- ST_READ
- ST_RENABLE

The FSM ensures correct APB timing and inserts wait states using HREADYOUT.

---

## Verification
Simulation is performed using ModelSim.
Verified scenarios:
- Single write (HWDATA → PWDATA)
- Single read (PRDATA → HRDATA)
- Burst write (sequential APB writes)

Waveforms confirm correct timing of PSEL, PENABLE, and HREADYOUT.

---

## Tools Used
- Verilog HDL
- ModelSim
- Intel Quartus Prime Lite
- RTL Netlist Viewer

---

## How to Run Simulation
```sh
vlog *.v
vsim top_tb
run -all
