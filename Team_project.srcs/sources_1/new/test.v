`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2021 08:18:40 PM
// Design Name: 
// Module Name: test
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


module test(
    input clock,
    input toggle,
    output [3:0] Anode_Activate,
    output [6:0] LED_out
    );
    //reg reset = 0;
    //assign reset
    
    //always @ (posedge toggle)
    
    //begin
    //    reset <= 1; #10
    //    reset <= 0;
    //end
    Seven_segment_LED_Display_Controller test1(clock, toggle, Anode_Activate, LED_out);
endmodule
