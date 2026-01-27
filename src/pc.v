`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.11.2025 15:30:14
// Design Name: 
// Module Name: pc
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
module pc(
    input clk,
    input pc_write,
    input [31:0]pc_next,
    output reg [31:0]pc,
    input rst
    );
    
    always @(posedge clk, posedge rst)begin
        if(rst)
            pc <= 32'd0;
        else if(pc_write)
            pc <= pc_next;
       end
    
endmodule
