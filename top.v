module top ( 
    input rst,
    input [3:0]rows,
    output reg [3:0]cols);

    SB_HFOSC  u_SB_HFOSC(.CLKHFPU(1), .CLKHFEN(1), .CLKHF(clk));

    parameter CUENTA = 2000;

    reg ser_clk;
    reg[] serialCount;
    reg prev_ser_clk;
    wire risingEdgeSerClk;

    always(@posedge clk) begin
        if(rst == 'd1) begin
            serialCount <= 'd0;
            ser_clk <= 'd0;
        end else begin
            serialCount <= serialCount + 'd1;
            prev_ser_clk <= ser_clk;
            if (serialCount >= CUENTA) begin
                serialCount <= 'd0;
                ser_clk <= ~ser_clk;
            end
        end
    end

    assign risingEdgeSerClk = ser_clk && (~prev_ser_clk);


    wire numberPressed;
    wire operationPressed;
    wire equalsPressed;    
    wire bottonPressedPulse;
    wire bottonPressedNow;
    wire digitRead;
    wire [1:0]operationRead;
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
        display_out(clk, rst, risingEdgeSerClk, operator1BCD, dataEnable, data);
    end else if (state == 'd1) begin
        OpLogic(clk, rst, digitRead, numberPressed && bottonPressedPulse, numCounter, operator2Binary, operator2BCD);
        display_out(clk, rst, risingEdgeSerClk, operator2BCD, dataEnable, data);
    end

    reg [13:0]resultBinary;

    ALU(clk, rst, operationRead, operationPressed, equalsPressed, operator1Binary, operator2Binary, resultBinary);
    
    

endmodule