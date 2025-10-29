module top (
    input clk, 
    input rst,
    input [3:0]rows),
    output reg [3:0]cols;

    wire numberPressed;
    wire operationPressed;
    wire equalsPressed;    
    wire bottonPressedPulse;
    wire bottonPressedNow;
    wire digitRead;
    wire operationRead;

    keyb_iface(clk, rst, rows, cols,
             numberPressed, operationPressed, equalsPressed, bottonPressedPulse, 
             bottonPressedNow, digitRead, operationRead);

endmodule