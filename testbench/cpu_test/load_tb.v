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

        for (i = 0; i < 32; i = i + 1)
            uut.dp.rf.regs[i] = 0;

        #20 rst = 0;

        uut.dp.mem_inst.regs[64] = 32'hFFFFFFFF;

        uut.dp.mem_inst.regs[0] = 32'h10000093;
        uut.dp.mem_inst.regs[1] = 32'h00008103;
        uut.dp.mem_inst.regs[2] = 32'h0000c183;
        uut.dp.mem_inst.regs[3] = 32'h00009203;
        uut.dp.mem_inst.regs[4] = 32'h0000d283;
        uut.dp.mem_inst.regs[5] = 32'h0000a303;
        uut.dp.mem_inst.regs[6] = 32'h0000006f;

        #600;

        if (uut.dp.rf.regs[2] === 32'hFFFFFFFF) $display("LB  PASS");
        else                                   $display("LB  FAIL");

        if (uut.dp.rf.regs[3] === 32'h000000FF) $display("LBU PASS");
        else                                   $display("LBU FAIL");

        if (uut.dp.rf.regs[4] === 32'hFFFFFFFF) $display("LH  PASS");
        else                                   $display("LH  FAIL");

        if (uut.dp.rf.regs[5] === 32'h0000FFFF) $display("LHU PASS");
        else                                   $display("LHU FAIL");

        if (uut.dp.rf.regs[6] === 32'hFFFFFFFF) $display("LW  PASS");
        else                                   $display("LW  FAIL");

        $finish;
    end
endmodule
