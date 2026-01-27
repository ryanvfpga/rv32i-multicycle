`timescale 1ns / 1ps

module load_tb;
    reg clk;
    reg rst;
    integer i;

    cpu uut (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        
        for (i=0; i<32; i=i+1) uut.dp.rf.regs[i] = 0;
        
        #20;
        rst = 0;

        $display("\n=============================================================");
        $display("             RISC-V LOAD VARIATIONS TEST (I-TYPE)            ");
        $display("   Checking Sign-Extension (LB/LH) vs Zero-Extension (LBU/LHU)");
        $display("=============================================================");

        uut.dp.mem_inst.regs[64] = 32'hFFFFFFFF;

        uut.dp.mem_inst.regs[0] = 32'h10000093;
        uut.dp.mem_inst.regs[1] = 32'h00008103;
        uut.dp.mem_inst.regs[2] = 32'h0000c183;
        uut.dp.mem_inst.regs[3] = 32'h00009203;
        uut.dp.mem_inst.regs[4] = 32'h0000d283;
        uut.dp.mem_inst.regs[5] = 32'h0000a303;
        uut.dp.mem_inst.regs[6] = 32'h0000006f;

        $display("Time | PC | Inst | x2(LB) | x3(LBU) | x4(LH) | x5(LHU) | x6(LW)");
        $monitor("%4t | %h | %h | %h | %h | %h | %h | %h", 
                 $time, uut.dp.pc, uut.dp.instreg_out, 
                 uut.dp.rf.regs[2], uut.dp.rf.regs[3], 
                 uut.dp.rf.regs[4], uut.dp.rf.regs[5], uut.dp.rf.regs[6]);

        #600;

        $display("\n-------------------------------------------------------------");

        if (uut.dp.rf.regs[2] === 32'hFFFFFFFF) 
            $display("[PASS] LB  x2 = 0xFFFFFFFF (Correctly Sign Extended)");
        else 
            $display("[FAIL] LB  x2 = %h (Expected 0xFFFFFFFF)", uut.dp.rf.regs[2]);

        if (uut.dp.rf.regs[3] === 32'h000000FF) 
            $display("[PASS] LBU x3 = 0x000000FF (Correctly Zero Extended)");
        else 
            $display("[FAIL] LBU x3 = %h (Expected 0x000000FF)", uut.dp.rf.regs[3]);

        if (uut.dp.rf.regs[4] === 32'hFFFFFFFF) 
            $display("[PASS] LH  x4 = 0xFFFFFFFF (Correctly Sign Extended)");
        else 
            $display("[FAIL] LH  x4 = %h (Expected 0xFFFFFFFF)", uut.dp.rf.regs[4]);

        if (uut.dp.rf.regs[5] === 32'h0000FFFF) 
            $display("[PASS] LHU x5 = 0x0000FFFF (Correctly Zero Extended)");
        else 
            $display("[FAIL] LHU x5 = %h (Expected 0x0000FFFF)", uut.dp.rf.regs[5]);

        if (uut.dp.rf.regs[6] === 32'hFFFFFFFF) 
            $display("[PASS] LW  x6 = 0xFFFFFFFF (Full Word Loaded)");
        else 
            $display("[FAIL] LW  x6 = %h (Expected 0xFFFFFFFF)", uut.dp.rf.regs[6]);

        $finish;
    end
endmodule