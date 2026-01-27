`timescale 1ns / 1ps

module rtype_tb;
    reg clk;
    reg rst;
    reg pc_write;
    reg ir_write;
    reg reg_write;
    reg mem_write;
    reg mdr_write;
    reg [3:0] alu_ctrl;
    reg [2:0] imm_ctrl;
    reg alu_in2_ctrl;
    reg addrsrc_ctrl;
    reg regwrite_ctrl;

    integer expected [0:9];
    integer i;
    integer rs1;
    integer rs2;

    datapath dut(
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
        rs1 = 32'h000000A5;
        rs2 = 32'h0000003C;

        dut.mem_inst.regs[0] = 32'h002081B3;
        dut.mem_inst.regs[1] = 32'h402081B3;
        dut.mem_inst.regs[2] = 32'h0020F1B3;
        dut.mem_inst.regs[3] = 32'h0020E1B3;
        dut.mem_inst.regs[4] = 32'h0020C1B3;
        dut.mem_inst.regs[5] = 32'h002091B3;
        dut.mem_inst.regs[6] = 32'h0020D1B3;
        dut.mem_inst.regs[7] = 32'h4020D1B3;
        dut.mem_inst.regs[8] = 32'h0020A1B3;
        dut.mem_inst.regs[9] = 32'h0020B1B3;

        dut.rf.regs[1] = rs1;
        dut.rf.regs[2] = rs2;

        expected[0] = rs1 + rs2;
        expected[1] = rs1 - rs2;
        expected[2] = rs1 & rs2;
        expected[3] = rs1 | rs2;
        expected[4] = rs1 ^ rs2;
        expected[5] = rs1 << (rs2 & 5'h1F);
        expected[6] = rs1 >> (rs2 & 5'h1F);
        expected[7] = $signed(rs1) >>> (rs2 & 5'h1F);
        expected[8] = ($signed(rs1) < $signed(rs2)) ? 1 : 0;
        expected[9] = (rs1 < rs2) ? 1 : 0;

        rst           = 1;
        pc_write      = 0;
        ir_write      = 0;
        reg_write     = 0;
        alu_ctrl      = 0;
        alu_in2_ctrl  = 0;
        mem_write     = 0;
        mdr_write     = 0;
        addrsrc_ctrl  = 0;
        imm_ctrl      = 0;
        regwrite_ctrl = 0;
        
        @(posedge clk);
        rst = 0;

        for(i = 0; i < 10; i = i + 1) begin
            pc_write = 1;
            ir_write = 1;
            @(posedge clk);
            pc_write = 0;
            ir_write = 0;
            
            @(posedge clk);
            
            alu_ctrl = i[3:0];
            alu_in2_ctrl = 0;
            
            @(posedge clk);
            @(posedge clk);
            
            reg_write = 1;
            @(posedge clk);
            reg_write = 0;

            $display("[%0d] Got=%0d Expected=%0d %s",
                i,
                $signed(dut.rf.regs[3]),
                expected[i],
                ($signed(dut.rf.regs[3]) == expected[i]) ? "PASS" : "FAIL"
            );
        end
        $finish;
    end
endmodule