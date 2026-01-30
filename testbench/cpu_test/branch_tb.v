`timescale 1ns / 1ps

module branch_tb;

    reg clk;
    reg rst;

    cpu uut (
        .clk(clk),
        .rst(rst)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #20 rst = 0;

        // =========================
        // Program Memory
        // =========================

        // BEQ
        uut.dp.mem_inst.regs[0]  = 32'h00a00293; // ADDI x5,  x0, 10
        uut.dp.mem_inst.regs[1]  = 32'h00a00313; // ADDI x6,  x0, 10
        uut.dp.mem_inst.regs[2]  = 32'h00628463; // BEQ  x5,  x6, +8
        uut.dp.mem_inst.regs[3]  = 32'h00000293; // ADDI x5,  x0, 0
        uut.dp.mem_inst.regs[4]  = 32'h00000013; // NOP

        // BNE
        uut.dp.mem_inst.regs[5]  = 32'h00a00393; // ADDI x7,  x0, 10
        uut.dp.mem_inst.regs[6]  = 32'h01400413; // ADDI x8,  x0, 20
        uut.dp.mem_inst.regs[7]  = 32'h00839463; // BNE  x7,  x8, +8
        uut.dp.mem_inst.regs[8]  = 32'h00000393; // ADDI x7,  x0, 0
        uut.dp.mem_inst.regs[9]  = 32'h00000013; // NOP

        // BLT (signed)
        uut.dp.mem_inst.regs[10] = 32'hffb00493; // ADDI x9,  x0, -5
        uut.dp.mem_inst.regs[11] = 32'h00500513; // ADDI x10, x0, 5
        uut.dp.mem_inst.regs[12] = 32'h00a4c463; // BLT  x9,  x10, +8
        uut.dp.mem_inst.regs[13] = 32'h00000493; // ADDI x9,  x0, 0
        uut.dp.mem_inst.regs[14] = 32'h00000013; // NOP

        // BGE (signed)
        uut.dp.mem_inst.regs[15] = 32'h00500593; // ADDI x11, x0, 5
        uut.dp.mem_inst.regs[16] = 32'hffb00613; // ADDI x12, x0, -5
        uut.dp.mem_inst.regs[17] = 32'h00c5d463; // BGE  x11, x12, +8
        uut.dp.mem_inst.regs[18] = 32'h00000593; // ADDI x11, x0, 0
        uut.dp.mem_inst.regs[19] = 32'h00000013; // NOP

        // BLTU
        uut.dp.mem_inst.regs[20] = 32'h00a00693; // ADDI x13, x0, 10
        uut.dp.mem_inst.regs[21] = 32'h01400713; // ADDI x14, x0, 20
        uut.dp.mem_inst.regs[22] = 32'h00e6e463; // BLTU x13, x14, +8
        uut.dp.mem_inst.regs[23] = 32'h00000693; // ADDI x13, x0, 0
        uut.dp.mem_inst.regs[24] = 32'h00000013; // NOP

        // BGEU
        uut.dp.mem_inst.regs[25] = 32'h01400793; // ADDI x15, x0, 20
        uut.dp.mem_inst.regs[26] = 32'h00a00813; // ADDI x16, x0, 10
        uut.dp.mem_inst.regs[27] = 32'h0107f463; // BGEU x15, x16, +8
        uut.dp.mem_inst.regs[28] = 32'h00000793; // ADDI x15, x0, 0
        uut.dp.mem_inst.regs[29] = 32'h00000013; // NOP

        // Halt
        uut.dp.mem_inst.regs[30] = 32'h0000006f; // JAL x0, 0

        #1200;

        // =========================
        // Checks
        // =========================
        if (uut.dp.rf.regs[5]  == 10) $display("BEQ  PASS"); else $display("BEQ  FAIL");
        if (uut.dp.rf.regs[7]  == 10) $display("BNE  PASS"); else $display("BNE  FAIL");
        if ($signed(uut.dp.rf.regs[9])  == -5) $display("BLT  PASS"); else $display("BLT  FAIL");
        if ($signed(uut.dp.rf.regs[11]) == 5)  $display("BGE  PASS"); else $display("BGE  FAIL");
        if (uut.dp.rf.regs[13] == 10) $display("BLTU PASS"); else $display("BLTU FAIL");
        if (uut.dp.rf.regs[15] == 20) $display("BGEU PASS"); else $display("BGEU FAIL");

        $finish;
    end

endmodule
