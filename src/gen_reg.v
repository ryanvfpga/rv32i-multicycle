`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.11.2025 15:33:23
// Design Name: 
// Module Name: gen_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

(* DONT_TOUCH = "TRUE" *)
module gen_reg(
    input en,
    input clk,
    output reg [31:0]out,
    input [31:0]in
    );
    
    always @(posedge clk)begin
        if(en)
            out <= in;

    end
    
    
endmodule
