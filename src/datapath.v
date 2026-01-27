(* DONT_TOUCH = "TRUE" *)
module datapath(
    input clk,
    input rst,
    input pc_write,
    input mem_write,
    input ir_write,
    input reg_write,
    input mdr_write,
    input [2:0] imm_ctrl,
    input [3:0] alu_ctrl,
    input alu_in2_ctrl,
    input alu_in1_ctrl,
    input [1:0]regwrite_ctrl,
    input addrsrc_ctrl,
    output [31:0] instr_to_fsm,
    input pc_write_ctrl,
    output t_branch,
    output debug
    
    );
    
    
    wire [31:0] pc_next, pc;
    wire [31:0] mem_readout, mem_writein, mem_addrin;
    wire [31:0] instreg_out, datareg_out;
    wire [31:0] rs1_readout, rs2_readout, rs1_regout, rs2_regout;
    reg [31:0] reg_writein;
    wire [31:0] imm_out, alu_in1, alu_in2, alu_result, alu_regout;
    reg [31:0] old_pc;
    
    reg [31:0] final_load_data;
    wire [2:0] funct3 = instreg_out[14:12]; 
    assign debug = pc[0];
    always @(*) begin
        case(funct3)
            3'b000: final_load_data = {{24{datareg_out[7]}}, datareg_out[7:0]};   // LB
            3'b001: final_load_data = {{16{datareg_out[15]}}, datareg_out[15:0]}; // LH
            3'b010: final_load_data = datareg_out;                                // LW
            3'b100: final_load_data = {24'b0, datareg_out[7:0]};                  // LBU
            3'b101: final_load_data = {16'b0, datareg_out[15:0]};                 // LHU
            default: final_load_data = datareg_out;
        endcase
    end
    
 
    
    
    assign mem_addrin = addrsrc_ctrl ? alu_regout : pc;
    assign mem_writein = rs2_regout;
    assign pc_next = pc_write_ctrl?alu_regout:pc + 32'd4;
    
    always @(*)begin
        case(regwrite_ctrl)
            2'b00: reg_writein = alu_regout;
            
            
            2'b01: reg_writein = final_load_data;
            
            2'b10: reg_writein = pc;
        endcase
    end    
    
    assign alu_in1 = alu_in1_ctrl?      old_pc:rs1_regout;
    assign alu_in2 = alu_in2_ctrl ? imm_out : rs2_regout;

    pc pc_inst (.clk(clk), .pc_write(pc_write), .pc_next(pc_next), .pc(pc), .rst(rst));
    
    memory mem_inst (.address(mem_addrin), .write_data(mem_writein), .read_data(mem_readout), .clk(clk), .mem_write(mem_write), .funct3(funct3));
    
    gen_reg instrreg (.en(ir_write), .clk(clk), .in(mem_readout), .out(instreg_out));
    
    gen_reg datareg (.en(mdr_write), .clk(clk), .in(mem_readout), .out(datareg_out));
    
    regfile rf (.rs1(instreg_out[19:15]), .rs2(instreg_out[24:20]), .rd(instreg_out[11:7]), .write_data_in(reg_writein), .reg_write(reg_write), .clk(clk), .rs1_read_o(rs1_readout), .rs2_read_o(rs2_readout));

    immgen immgen_inst(.instr(instreg_out), .imm_ctrl(imm_ctrl), .imm(imm_out));
    
    gen_reg rs1_reg (.en(1'b1), .clk(clk), .in(rs1_readout), .out(rs1_regout));
    gen_reg rs2_reg (.en(1'b1), .clk(clk), .in(rs2_readout), .out(rs2_regout));
    
    alu alu_inst (.alu_ctrl(alu_ctrl), .a(alu_in1), .b(alu_in2), .alu_result(alu_result), .t_branch(t_branch));
    
    gen_reg alu_out_reg (.en(1'b1), .clk(clk), .in(alu_result), .out(alu_regout));
    
    assign instr_to_fsm = instreg_out;
    
    always @(posedge clk)
        if(pc_write)
            old_pc <= pc;
       
endmodule