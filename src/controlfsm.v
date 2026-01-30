`timescale 1ns / 1ps
(* DONT_TOUCH = "TRUE" *)

module control_fsm(
    input clk,
    input rst,
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg pc_write,
    output reg mem_write,
    output reg ir_write,
    output reg reg_write,
    output reg mdr_write,
    output reg [2:0] imm_ctrl,
    output reg [3:0] alu_ctrl,
    output reg alu_in2_ctrl,
    output reg alu_in1_ctrl,
    output reg [1:0]regwrite_ctrl,
    output reg addrsrc_ctrl,
    output reg pc_write_ctrl,
    input t_branch
    );
    
    reg [2:0] state, next_state;
    parameter S_IF = 3'b000, S_ID = 3'b001, S_EX = 3'b010, S_MW = 3'b011, S_WB = 3'b100;
    
    always @(posedge clk) begin
        if(rst)
            state <= S_IF;
        else 
            state <= next_state;
    end
    
    always @(*) begin
        case(state)
            S_IF: next_state = S_ID;
            S_ID: next_state = S_EX;
            S_EX: begin
                case(opcode)
                    7'b0110011: next_state = S_WB;
                    7'b0010011: next_state = S_WB;
                    7'b1100111: next_state = S_WB; // JALR
                    7'b1101111: next_state = S_WB; //JAL
                    7'b0100011: next_state = S_MW;
                    7'b0000011: next_state = S_MW;
                    
                    default:    next_state = S_IF; //includes b-type
                endcase 
            end
            S_MW: begin
                case(opcode)
                    7'b0100011: next_state = S_IF;
                    7'b0000011: next_state = S_WB;
                    default:    next_state = S_IF;
                endcase 
            end
            S_WB: next_state = S_IF;      
            default: next_state = S_IF;
        endcase
    end
    
    always @(*) begin
        pc_write      = 0; 
        mem_write     = 0; 
        ir_write      = 0;
        reg_write     = 0; 
        mdr_write     = 0; 
        imm_ctrl      = 0;
        alu_ctrl      = 0; 
        alu_in2_ctrl  = 0; 
        alu_in1_ctrl  = 0;
        regwrite_ctrl = 0; 
        addrsrc_ctrl  = 0;
        pc_write_ctrl = 0;
        
        case(state)
            S_IF: begin
                ir_write = 1;
                pc_write = 1;   
            end
            S_ID: begin
                ir_write = 0;
                pc_write = 0;

                alu_in1_ctrl = 1;
                alu_in2_ctrl = 1;
                
                imm_ctrl = 3'b011;
                alu_ctrl = 3'b000;

            end
            S_EX: begin
                case(opcode)
                    7'b0110011: begin
                        alu_in1_ctrl = 0;
                        alu_in2_ctrl = 0;
                        alu_ctrl = {funct7[5], funct3};
                    end
                    7'b0010011: begin
                        alu_in1_ctrl = 0;
                        alu_in2_ctrl = 1;
                        imm_ctrl     = 3'b000;
                        if (funct3 == 3'b101 && funct7[5] == 1)
                            alu_ctrl = {1'b1, funct3};
                        else
                            alu_ctrl = {1'b0, funct3};
                    end
                    7'b0100011: begin  
                        alu_in2_ctrl = 1;
                        imm_ctrl     = 3'b001;
                        alu_ctrl = 4'b0000;
                    end
                    7'b0000011: begin
                        alu_in2_ctrl = 1;
                        imm_ctrl     = 3'b000;
                        alu_ctrl = 4'b0000;
                    end
                    
                    7'b1100111: begin //JALR
                        alu_in1_ctrl = 0; //rs1
                        alu_in2_ctrl = 1; //imm offset
    
                        imm_ctrl     = 3'b000;
                        alu_ctrl = 4'b0000;
                        
                        
                        
                    
                    end
                    
                    
                   7'b1101111: begin //jal
                        alu_in1_ctrl = 1;
                        alu_in2_ctrl = 1; //imm offset
                        alu_ctrl = 4'b0000;
                        imm_ctrl     = 3'b100; 
                        
                        
                   end
                   
                   7'b1100011: begin //b-type
              
                    alu_in1_ctrl = 0; 
                    alu_in2_ctrl = 0; 
                    
                    case(funct3)
                        3'b000: alu_ctrl = 4'b1010; // BEQ
                        3'b001: alu_ctrl = 4'b1011; // BNE
                        3'b100: alu_ctrl = 4'b1100; // BLT
                        3'b101: alu_ctrl = 4'b1101; // BGE
                        3'b110: alu_ctrl = 4'b1110; // BLTU
                        3'b111: alu_ctrl = 4'b1111; // BGEU
                        
                        default: alu_ctrl = 4'b0000;
                        
                    endcase
                    
                     case(t_branch)
                        1'b0: pc_write_ctrl = 0;
                        
                        1'b1: begin
                            pc_write_ctrl = 1;
                            pc_write = 1;
                            end
                            
                        default : pc_write_ctrl = 0;
                    endcase
                   
                end
                
                  
                     
                       

                endcase
            end
            S_MW: begin
                case(opcode)
                    7'b0100011: begin
                        mem_write = 1;
                        addrsrc_ctrl = 1;
                    end
                    7'b0000011: begin
                        mdr_write = 1;
                        addrsrc_ctrl = 1;
                    end
                endcase
            end
            
            S_WB: begin
                case(opcode)
                    7'b0110011, 7'b0010011: begin
                        reg_write     = 1;
                        regwrite_ctrl = 2'b00;
                    end
                    7'b0000011: begin
                        regwrite_ctrl = 2'b01;
                        reg_write = 1;
                    end
                    
                    7'b1100111, 7'b1101111: begin //jalr and jal
                       reg_write = 1;
                       regwrite_ctrl = 2'b10;
                       pc_write_ctrl = 1;
                       pc_write = 1;
     
                    end
                    
                    
                endcase
            end
        endcase
    end
endmodule