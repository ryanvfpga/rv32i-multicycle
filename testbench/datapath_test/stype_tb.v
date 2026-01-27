`timescale 1ns / 1ps

module stype_tb;
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
    
    always @(negedge clk) begin
        $display("--------------------------------------------------");
        $display("Time %0t", $time);
        $display("PC            = %0d (0x%h)", dut.pc_inst.pc, dut.pc_inst.pc);
        $display("IR             = 0x%h", dut.instreg_out);
        $display("rs1_addr=%0d rs2_addr=%0d rd_addr=%0d", dut.rs1_addr, dut.rs2_addr, dut.rd_addr);
        $display("rs1_readout    = 0x%h", dut.rs1_readout);
        $display("rs2_readout    = 0x%h", dut.rs2_readout);
        $display("rs1_regout     = 0x%h", dut.rs1_regout);
        $display("rs2_regout     = 0x%h", dut.rs2_regout);
        $display("imm_out        = %0d (0x%h)", dut.imm_out, dut.imm_out);
        $display("ALU_in1        = 0x%h", dut.alu_in1);
        $display("ALU_in2        = 0x%h", dut.alu_in2);
        $display("ALU_result     = 0x%h", dut.alu_result);
        $display("ALU_regout     = 0x%h", dut.alu_regout);
        $display("mem_addrin     = %0d (0x%h)", dut.mem_addrin, dut.mem_addrin);
        $display("mem_writein    = 0x%h", dut.mem_writein);
        $display("mem_write      = %b", dut.mem_write);
    end

    initial begin
        dut.mem_inst.regs[0] = 32'h0020A423;
        dut.rf.regs[1] = 32'd80;
        dut.rf.regs[2] = 32'hCAFEBABE;
        dut.mem_inst.regs[22] = 32'h0;

        rst = 1;
        pc_write = 0;
        ir_write = 0;
        reg_write = 0;
        mem_write = 0;
        regwrite_ctrl = 0;
        mdr_write = 0;
        alu_in2_ctrl = 0;
        addrsrc_ctrl = 0;
        imm_ctrl = 3'b001; 
        alu_ctrl = 4'b0000;
        
        @(posedge clk);
        rst = 0;
       
        pc_write = 1;
        ir_write = 1;
        addrsrc_ctrl = 0; 
        
        @(posedge clk);
        
        pc_write = 0;
        ir_write = 0;
        alu_ctrl = 4'b0000;
        alu_in2_ctrl = 1;
        
        @(posedge clk);

        addrsrc_ctrl = 1;
        @(posedge clk);
 
        mem_write = 1;
        @(posedge clk);
        mem_write = 0;
        
        @(posedge clk);

        #1
        $display("SW x2, 8(x1)");
        $display("Expected Memory[22] = CAFEBABE");
        $display("Got      Memory[22] = %h", dut.mem_inst.regs[22]);
        
        if (dut.mem_inst.regs[22] == 32'hCAFEBABE)
            $display("RESULT: PASS");
        else
            $display("RESULT: FAIL");

        $finish;
    end
endmodule