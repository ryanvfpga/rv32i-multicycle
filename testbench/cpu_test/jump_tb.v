`timescale 1ns / 1ps

module jump_tb;

    reg clk;
    reg rst;

    cpu uut (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #20 rst = 0;

        uut.dp.mem_inst.regs[0]  = 32'h01000113;
        uut.dp.mem_inst.regs[1]  = 32'h0aa00193;
        uut.dp.mem_inst.regs[2]  = 32'h00010067;
        uut.dp.mem_inst.regs[3]  = 32'h00000193;
        uut.dp.mem_inst.regs[4]  = 32'h00100513;

        uut.dp.mem_inst.regs[5]  = 32'h0bb00213;
        uut.dp.mem_inst.regs[6]  = 32'h00c0006f;
        uut.dp.mem_inst.regs[7]  = 32'h00000213;
        uut.dp.mem_inst.regs[8]  = 32'h00000013;
        uut.dp.mem_inst.regs[9]  = 32'h00100513;
        uut.dp.mem_inst.regs[10] = 32'h0000006f;

        #500;

        if (uut.dp.rf.regs[3] == 170)
            $display("JALR PASS");
        else
            $display("JALR FAIL");

        if (uut.dp.rf.regs[4] == 187)
            $display("JAL  PASS");
        else
            $display("JAL  FAIL");

        $finish;
    end
endmodule
