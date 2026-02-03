# RISC-V Multi-Cycle Processor Implementation

> **Computer Architecture - University of Tehran - Department of Electrical & Computer Engineering**

![Verilog](https://img.shields.io/badge/Language-Verilog-blue) ![Tool](https://img.shields.io/badge/Sim-ModelSim-green) ![Status](https://img.shields.io/badge/Status-Completed-success)

## 📌 Overview

This repository contains the Register Transfer Level (RTL) implementation of a **Multi-Cycle RISC-V Processor**. This project was developed as the third assignment for the *Computer Architecture* course at the University of Tehran.

Unlike single-cycle processors, this architecture breaks down instruction execution into multiple clock cycles, allowing for resource sharing (like a single Memory and a single ALU) and potentially higher clock frequencies.

## 🏗️ Architecture

The design follows a finite state machine (FSM) approach to manage the execution flow across different cycles: **Fetch, Decode, Execute, Memory, and Write-back**.

### Datapath Design

The multi-cycle datapath reduces hardware overhead by reusing key components. Major modules include:

![Datapath Architecture](./Design/DataPath.png)

* **Unified Memory:** Acts as both Instruction and Data memory.
* **ALU:** Performs all arithmetic, logical, and address calculations.
* **Register File:** Standard RISC-V 32-bit register file.
* **State Registers:** Intermediate registers (IR, OldPC, MDR, etc.) to hold data between clock cycles.

### 🎮 Control Logic & State Machine

The Control Unit is the brain of the multi-cycle processor, implemented as a **Finite State Machine**. It generates control signals based on the current state and the instruction opcode.

#### Main Control Unit FSM Table

This table describes the control signals generated in each state of the FSM:

<table style="width:100%; table-layout: fixed; border-collapse: collapse;">
  <thead>
    <tr>
      <th>State</th>
      <th>PCWrite</th>
      <th>IRWrite</th>
      <th>MemRead</th>
      <th>MemWrite</th>
      <th>IorD</th>
      <th>RegWrite</th>
      <th>MemtoReg</th>
      <th>ALUSrcB</th>
      <th>ALUOp</th>
      <th>RegDst</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>FETCH</td>
      <td>1</td>
      <td>1</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td style="white-space: nowrap;">Instruction Fetch</td>
    </tr>
    <tr>
      <td>DECODE</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td style="white-space: nowrap;">Decode &amp; Register Read</td>
    </tr>
    <tr>
      <td>MEM_ADDR</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td style="white-space: nowrap;">Address Calculation</td>
    </tr>
    <tr>
      <td>MEM_READ</td>
      <td>0</td>
      <td>0</td>
      <td>1</td>
      <td>0</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td style="white-space: nowrap;">Memory Access (Load)</td>
    </tr>
    <tr>
      <td>MEM_WB</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>1</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td style="white-space: nowrap;">Write-back from Memory</td>
    </tr>
    <tr>
      <td>MEM_WRITE</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>1</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td style="white-space: nowrap;">Memory Access (Store)</td>
    </tr>
    <tr>
      <td>EXEC_TYPE_C</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>Func</td>
      <td>0</td>
      <td style="white-space: nowrap;">R-type Execution</td>
    </tr>
    <tr>
      <td>EXEC_TYPE_D</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>1</td>
      <td>Opcode</td>
      <td>0</td>
      <td style="white-space: nowrap;">I-type Execution</td>
    </tr>
    <tr>
      <td>WB_ALU</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>Note A</td>
      <td style="white-space: nowrap;">ALU Write-back</td>
    </tr>
    <tr>
      <td>BRANCH</td>
      <td>1*</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>1</td>
      <td>0</td>
      <td style="white-space: nowrap;">Branch Completion</td>
    </tr>
    <tr>
      <td>JUMP</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td style="white-space: nowrap;">Jump Completion</td>
    </tr>
  </tbody>
</table>


### 🔢 ALU Operation Decoding

The ALU Control Unit determines the operation based on the current state and instruction fields.

#### R-Type Instruction Logic (Type-C)

| Function Bit | ALUOp | Operation |
| --- | --- | --- |
| Func[0] | 3'b101 | Pass In1 |
| Func[1] | 3'b110 | Pass In2 |
| Func[2] | 3'b000 | Addition (+) |
| Func[3] | 3'b001 | Subtraction (-) |
| Func[4] | 3'b010 | Bitwise AND (&) |
| Func[5] | 3'b011 | Bitwise OR ( |
| Func[6] | 3'b100 | Bitwise NOT (~) |

#### I-Type Instruction Logic (Type-D)

| Opcode | ALUOp | Operation |
| --- | --- | --- |
| 4'b1100 | 3'b000 | ADDI (Add Immediate) |
| 4'b1101 | 3'b001 | SUBI (Sub Immediate) |
| 4'b1110 | 3'b010 | ANDI (And Immediate) |
| 4'b1111 | 3'b011 | ORI (Or Immediate) |

### ⚖️ Conditional Signal Logic

Special conditions for register destinations and program counter updates:

| Signal | Condition | Value | Description |
| --- | --- | --- | --- |
| **RegDst** | Opcode == 4'b1000 AND Func[0] == 1 | 1 | Write to IR[11:9] |
|  | Otherwise | 0 | Write to 3'b000 |
| **PCSource** | current_state == JUMP | 2'b01 | Jump Target Address |
|  | current_state == BRANCH AND Zero == 1 | 2'b10 | Branch Target Address |
|  | Otherwise | 2'b00 | PC + 1 (Default) |

### 🔌 Multiplexer Selection Logic

Defines how data is routed through the datapath based on control signals:

| Mux Name | Selection Signal | sel=0 Output | sel=1 Output |
| --- | --- | --- | --- |
| **AdrMux** | IorD | PC_Out | IR_Address_Ext |
| **WDMux** | MemtoReg | ALU_Result_Reg | MDR_Out |
| **RegDstMux** | RegDst | 3'b000 | IR_Out[11:9] |
| **SrcBMux** | ALUSrcB | B_Out (if 00) | Imm_Ext (if 01) |

## 📂 Repository Structure

The project is organized as follows:

```text
RISC-V-Multi-Cycle-Processor-Implementation/
├── Description/           # Project requirements and documents
│   └── CA#03.pdf          # Problem statement (Assignment 3)
├── Design/                # Architecture diagrams and design docs
│   ├── DataPath.png       # Multi-cycle datapath schematic
│   ├── ControlUnit.png    # FSM and Control logic diagrams
│   ├── ALUControlLogic... # ALU decoding logic
│   ├── MuxSelection...    # Datapath multiplexer logic
│   └── Design.pdf         # Detailed project report
├── Project/               # ModelSim project files and simulation data
│   ├── CA_CA3.mpf         # ModelSim project file
│   └── program.mem        # Machine code for testing
├── Source/                # Verilog HDL source files
│   ├── TopModule.v        # Top-level entity
│   ├── Datapath.v         # Datapath interconnection
│   ├── ControlUnit.v      # Main FSM and ALU Control
│   ├── ALU.v              # Arithmetic Logic Unit
│   ├── Memory.v           # Combined Instruction/Data Memory
│   ├── RegisterFile.v     # RISC-V Register File
│   ├── Register.v         # Basic flip-flop modules for state storage
│   ├── Mux.v / Adder.v    # Reusable hardware components
│   └── TestBench.v        # Testbench for verification
└── README.md              # Project documentation

```