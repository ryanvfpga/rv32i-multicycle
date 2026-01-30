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

        for (i = 0; i < 1024; i = i + 1)
            uut.dp.mem_inst.regs[i] = 0;

        for (i = 0; i < 32; i = i + 1)
            uut.dp.rf.regs[i] = 0;

        #20 rst = 0;

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

        #600;

        if (uut.dp.mem_inst.regs[64] === 32'hDDEEBBAA)
            $display("SB/SH PASS");
        else
            $display("SB/SH FAIL");

        if (uut.dp.mem_inst.regs[65] === 32'hDEADBEEF)
            $display("SW PASS");
        else
            $display("SW FAIL");

        $finish;
    end
endmodule
