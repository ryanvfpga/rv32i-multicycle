`timescale 1ns / 1ps

module store_tb;
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

        for (i=0; i<1024; i=i+1) uut.dp.mem_inst.regs[i] = 0;
        for (i=0; i<32; i=i+1) uut.dp.rf.regs[i] = 0;

        #20;
        rst = 0;

        $display("\n=============================================================");
        $display("             RISC-V STORE VARIATIONS TEST (S-TYPE)           ");
        $display("      Checking Masking Logic: SB (Byte) & SH (Half)          ");
        $display("=============================================================");

        uut.dp.rf.regs[1] = 32'h00000100;
        uut.dp.rf.regs[2] = 32'h112233AA;
        uut.dp.rf.regs[3] = 32'h112233BB;
        uut.dp.rf.regs[4] = 32'h1122DDEE;
        uut.dp.rf.regs[5] = 32'hDEADBEEF;

        uut.dp.mem_inst.regs[0] = 32'h00208023;
        uut.dp.mem_inst.regs[1] = 32'h003080A3;
        uut.dp.mem_inst.regs[2] = 32'h00409123;
        uut.dp.mem_inst.regs[3] = 32'h0050A223;
        uut.dp.mem_inst.regs[4] = 32'h0000006f;

        $display("Time | PC | Inst | Mem[0x100] (Target) | Mem[0x104] (Next Word)");
        $monitor("%4t | %h | %h | %h | %h", 
                 $time, uut.dp.pc, uut.dp.instreg_out, 
                 uut.dp.mem_inst.regs[64], uut.dp.mem_inst.regs[65]);
        
        #600;

        $display("\n-------------------------------------------------------------");

        if (uut.dp.mem_inst.regs[64] === 32'hDDEEBBAA)
            $display("[PASS] Mixed Stores (SB+SB+SH) at 0x100 = %h", uut.dp.mem_inst.regs[64]);
        else begin
            $display("[FAIL] Mixed Stores at 0x100 = %h", uut.dp.mem_inst.regs[64]);
            $display("       Expected: DDEEBBAA");
            $display("       (Possible Cause: SB/SH overwrote neighbor bytes)");
        end

        if (uut.dp.mem_inst.regs[65] === 32'hDEADBEEF)
            $display("[PASS] Store Word (SW) at 0x104 = %h", uut.dp.mem_inst.regs[65]);
        else
            $display("[FAIL] Store Word at 0x104 = %h (Expected DEADBEEF)", uut.dp.mem_inst.regs[65]);

        $finish;
    end
endmodule