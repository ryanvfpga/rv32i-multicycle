(* DONT_TOUCH = "TRUE" *)

module cpu(
    input clk,
    input rst,
    output debug_o
    
);  
    wire debug;
    wire pc_write, mem_write, ir_write, reg_write, mdr_write;
    wire alu_in2_ctrl, alu_in1_ctrl, addrsrc_ctrl;
    wire [2:0] imm_ctrl;
    wire [3:0] alu_ctrl;
    wire [31:0] instr_wire;
    wire [1:0]regwrite_ctrl;
    wire pc_write_ctrl;
    wire t_branch;

    control_fsm controller (
        .clk(clk),
        .rst(rst),
        .opcode(instr_wire[6:0]),
        .funct3(instr_wire[14:12]),
        .funct7(instr_wire[31:25]),
        .pc_write(pc_write),
        .mem_write(mem_write),
        .ir_write(ir_write),
        .reg_write(reg_write),
        .mdr_write(mdr_write),
        .imm_ctrl(imm_ctrl),
        .alu_ctrl(alu_ctrl),
        .alu_in2_ctrl(alu_in2_ctrl),
        .alu_in1_ctrl(alu_in1_ctrl),
        .regwrite_ctrl(regwrite_ctrl),
        .addrsrc_ctrl(addrsrc_ctrl),
        .pc_write_ctrl(pc_write_ctrl),
        .t_branch(t_branch)
    );

    datapath dp (
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
        .alu_in1_ctrl(alu_in1_ctrl),
        .regwrite_ctrl(regwrite_ctrl),
        .addrsrc_ctrl(addrsrc_ctrl),
        .instr_to_fsm(instr_wire),
        .pc_write_ctrl(pc_write_ctrl),
        .t_branch(t_branch),
        .debug(debug)
        
        
    );
    
    assign debug_o = debug;
endmodule