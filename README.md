# RV32I Multicycle Processor Implementation

This repository contains a synthesizable Verilog implementation of a 32-bit RISC-V processor. The design utilizes a **5-stage multicycle datapath**, optimizing hardware area efficiency while maintaining functional completeness by implementing the full **RV32I Instruction Set Architecture (ISA)**.

## 🏗 Architecture & Design

The processor sequences instructions through five distinct stages, reusing the ALU and Memory interfaces across clock cycles to minimize FPGA resource consumption (specifically LUT and Slice utilization).

### 5-Stage Execution Flow:
1.  **Instruction Fetch (IF):** Retrieval of the 32-bit instruction from memory and PC increment.
2.  **Instruction Decode (ID):** Opcode parsing, Register File read, and Immediate generation.
3.  **Execute (EX):** ALU operations for arithmetic, logic, and branch target calculation.
4.  **Memory Access (MEM):** Data memory read/write operations for Load and Store instructions.
5.  **Write-back (WB):** Updating the Register File with results from the ALU or Memory.



## 🚀 Key Features

* **Full RV32I ISA Support:** Successfully implemented and verified all instructions in the base integer set:
    * **Computational:** `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND`.
    * **Immediate:** `ADDI`, `SLTI`, `SLTIU`, `XORI`, `ORI`, `ANDI`, `SLLI`, `SRLI`, `SRAI`.
    * **Load/Store:** `LW`, `LH`, `LB`, `LHU`, `LBU`, `SW`, `SH`, `SB`.
    * **Branch/Jump:** `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`, `JAL`, `JALR`.
    * **Upper Immediates:** `LUI`, `AUIPC`.
* **Verified RTL:** The design has been fully verified through functional simulation, ensuring correct architectural state transitions and data integrity across the entire instruction suite.
* **Hardware Efficiency:** Optimized for FPGA deployment by sharing a single 32-bit ALU for both branch address calculation and data processing.

## 📂 Repository Roadmap

* **`/src`**: Verilog source files (RTL). Includes the centralized FSM Controller, Datapath, Register File, and ALU.
* **`/testbench`**: Simulation environment used to verify the processor against the complete RV32I instruction suite.
* **`rv32i.xpr`**: Xilinx Vivado project file.

## 💻 Verification & Tools
* **Language:** Verilog HDL
* **Software:** Xilinx Vivado (Synthesis & Simulation)
* **Verification:** Passed functional verification for all R, I, S, B, U, and J-type instructions.



---

### **Contact**
**V Ryan Sanjay** Electronics and Communication Engineering | National Institute of Technology, Tiruchirappalli  
