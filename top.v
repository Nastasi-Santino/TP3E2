module top ( 
    input rst,
    input [3:0]rows,
    output reg [3:0]cols);

    SB_HFOSC  u_SB_HFOSC(.CLKHFPU(1), .CLKHFEN(1), .CLKHF(clk));
    SB_LFOSC u_SB_LFOSC(.CLKLFPU(1), :CLKLFEN(1), .CLKLF(ser_clk));

    wire numberPressed;
    wire operationPressed;
    wire equalsPressed;    
    wire bottonPressedPulse;
    wire bottonPressedNow;
    wire digitRead;
    wire operationRead;
    reg[1:0] numCounter;

    always @(posedge clk) begin
        if(rst || (operationPressed && bottonPressedPulse) || (equalsPressed && bottonPressedPulse)) begin
            numCounter <= 'd0;
        end else if(numberPressed && bottonPressedPulse) begin
            numCounter <= numCounter + 'd1;
        end
    end


    keyb_iface(clk, rst, rows, cols,
             numberPressed, operationPressed, equalsPressed, bottonPressedPulse, 
             bottonPressedNow, digitRead, operationRead);

    wire[1:0] state;

    fsm(clk, rst, bottonPressedPulse && operationPressed, bottonPressedPulse && equalsPressed, state);

    wire [13:0]operator1Binary;
    wire [13:0]operator2Binary;
    wire [15:0]operator1BCD;
    wire [15:0]operator2BCD;

    wire dataEnable;
    wire data;

    if(state == 'd0) begin
        OpLogic(clk, rst, digitRead, numberPressed && bottonPressedPulse, numCounter, operator1Binary, operator1BCD);
        display_out(clk, ser_clk, rst, 1'd1, operator1BCD, dataEnable, data);
    end else if (state == 'd1) begin
        OpLogic(clk, rst, digitRead, numberPressed && bottonPressedPulse, numCounter, operator2Binary, operator2BCD);
        display_out(clk, ser_clk, rst, 1'd1, operator2BCD, dataEnable, data);
    end


    
    

endmodule