`timescale 1ns / 1ps

module itype_tb;
    reg clk;
    reg rst;
    reg pc_write;
    reg mem_write;
    reg ir_write;
    reg reg_write;
    reg mdr_write;
    reg [2:0] imm_ctrl;
    reg [3:0] alu_ctrl;
    reg alu_in2_ctrl;
    reg addrsrc_ctrl;
    reg regwrite_ctrl;

    integer expected[0:8];
    integer i;

    datapath dut (
        .clk(clk),
        .rst(rst),
        .pc_write(pc_write),
        .mem_write(mem_write),
        .ir_write(ir_write),
        .reg_write(reg_write),
        .mdr_write(mdr_write),
        .imm_ctrl(imm_ctrl),
        .alu_ctrl(alu_ctrl),
        .alu_in2_ctrl(alu_in2_ctrl),
        .addrsrc_ctrl(addrsrc_ctrl),
        .regwrite_ctrl(regwrite_ctrl)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        dut.mem_inst.regs[0] = 32'h00508193;
        dut.mem_inst.regs[1] = 32'h0F508193;
        dut.mem_inst.regs[2] = 32'h0A208193;
        dut.mem_inst.regs[3] = 32'h0FF0C193;
        dut.mem_inst.regs[4] = 32'h00A0A193;
        dut.mem_inst.regs[5] = 32'h00A0B193;
        dut.mem_inst.regs[6] = 32'h00109193;
        dut.mem_inst.regs[7] = 32'h0030D193;
        dut.mem_inst.regs[8] = 32'h4030D193;

        dut.rf.regs[1] = 32'h00000080;

        expected[0] = 128 + 5;
        expected[1] = 128 & 16'h0F5;
        expected[2] = 128 | 16'h0A2;
        expected[3] = 128 ^ 8'hFF;
        expected[4] = (128 < 10) ? 1 : 0;
        expected[5] = (128 < 10) ? 1 : 0;
        expected[6] = (128 << 1);
        expected[7] = (128 >> 3);
        expected[8] = ( $signed(128) >>> 3 );

        rst = 1;
        pc_write = 0;
        ir_write = 0;
        reg_write = 0;
        mem_write = 0;
        regwrite_ctrl = 0;
        mdr_write = 0;
        alu_in2_ctrl = 0;
        addrsrc_ctrl = 0;
        imm_ctrl = 3'b000;

        @(posedge clk);
        rst = 0;

        for(i = 0; i < 9; i = i + 1) begin
            pc_write = 1;
            ir_write = 1;
            @(posedge clk);
            pc_write = 0;
            ir_write = 0;
            
            @(posedge clk);
            
            alu_in2_ctrl = 1;
            
            alu_ctrl = (i == 0) ? 4'b0000 : 
                       (i == 1) ? 4'b0010 : 
                       (i == 2) ? 4'b0011 : 
                       (i == 3) ? 4'b0100 : 
                       (i == 4) ? 4'b1000 : 
                       (i == 5) ? 4'b1001 : 
                       (i == 6) ? 4'b0101 : 
                       (i == 7) ? 4'b0110 : 
                                  4'b0111 ;

            @(posedge clk);
            @(posedge clk);
            
            reg_write = 1;
            @(posedge clk);
            reg_write = 0;

            $display("INST %0d → Got=%0d  Expected=%0d  %s",
                i,
                $signed(dut.rf.regs[3]),
                expected[i],
                ($signed(dut.rf.regs[3]) == expected[i]) ? "PASS" : "FAIL"
            );
        end
        $finish;
    end
endmodule