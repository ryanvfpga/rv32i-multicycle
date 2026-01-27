`timescale 1ns / 1ps

module cpu_tb;
    reg clk;
    reg rst;

    // Instantiate CPU
    cpu uut (
        .clk(clk),
        .rst(rst)
    );

    // 100MHz Clock (10ns period)
    always #5 clk = ~clk;

    initial begin
        // 1. Initialize and Reset
        clk = 0;
        rst = 1;
        #20;
        rst = 0;
        
        // ---------------------------------------------------------
        // 2. Load Program into Memory (Word-Addressable Indexing)
        // ---------------------------------------------------------

        // [I-TYPE] ADDI x1, x0, 10  -> x1 = 0 + 10 (0xA)
        // Machine Code: 00a00093
        uut.dp.mem_inst.regs[0] = 32'h00a00093;

        // [I-TYPE] ADDI x2, x0, 20  -> x2 = 0 + 20 (0x14)
        // Machine Code: 01400113
        uut.dp.mem_inst.regs[1] = 32'h01400113;

        // [R-TYPE] ADD x3, x1, x2   -> x3 = 10 + 20 = 30 (0x1E)
        // Machine Code: 002081b3
        uut.dp.mem_inst.regs[2] = 32'h002081b3;

        // [S-TYPE] SW x3, 40(x0)    -> Store x3 (30) to Memory Address 40
        // Machine Code: 02302423 (imm[11:5]=0000001, rs2=3, rs1=0, funct3=010, imm[4:0]=01000)
        uut.dp.mem_inst.regs[3] = 32'h02302423;

        // [I-TYPE LOAD] LW x4, 40(x0) -> Load from Mem Address 40 to x4
        // Machine Code: 02802203
        uut.dp.mem_inst.regs[4] = 32'h02802203;

        // ---------------------------------------------------------
        // 3. Monitor Execution
        // ---------------------------------------------------------
        $display("Time | PC | State | Instruction | ALU_Out | x1 | x2 | x3 | x4");
        $monitor("%4t | %h | %h|   %b   |  %h   | %h | %d | %d | %d | %d", 
                 $time, uut.dp.pc, uut.dp.old_pc, uut.controller.state, uut.dp.instreg_out, 
                 uut.dp.alu_regout, uut.dp.rf.regs[1], uut.dp.rf.regs[2], 
                 uut.dp.rf.regs[3], uut.dp.rf.regs[4]);

        // Run for enough cycles to complete 5 instructions (roughly 25-30 cycles)
        #600;

        // ---------------------------------------------------------
        // 4. Final Verification
        // ---------------------------------------------------------
        $display("\n--- FINAL REGISTER REPORT ---");
        $display("x1 (Expected 10): %d", uut.dp.rf.regs[1]);
        $display("x2 (Expected 20): %d", uut.dp.rf.regs[2]);
        $display("x3 (Expected 30): %d", uut.dp.rf.regs[3]);
        $display("x4 (Expected 30): %d", uut.dp.rf.regs[4]);
        $display("Memory @ Addr 40 (Expected 30): %d", uut.dp.mem_inst.regs[10]); // 40 / 4 = 10

        if (uut.dp.rf.regs[4] === 30 && uut.dp.mem_inst.regs[10] === 30) 
            $display("\nTEST PASSED: R, I, Load, and Store logic confirmed.");
        else 
            $display("\nTEST FAILED: Data mismatch detected.");

        $finish;
    end
endmodule