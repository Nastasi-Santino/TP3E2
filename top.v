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
            prev_ser_clk <= 'd0;
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
    reg = newOperation;

    fsm(clk, rst, bottonPressedPulse && operationPressed, bottonPressedPulse && equalsPressed, state, newOperation);

    reg [13:0]operator1Binary;
    wire [13:0]operator2Binary;
    reg [15:0]operator1BCD;
    wire [15:0]operator2BCD;
    wire [13:0]resultBinary;
    wire [15:0]resultBCD;
    

    ALU(clk, rst, operationRead, operationPressed, equalsPressed, operator1Binary, operator2Binary, resultBinary);

    binary_to_bcd(resultBinary, resultBCD[0:3], resultBCD[4:7], resultBCD[8:11], resultBCD[12:15]);

    always @(posedge clk) begin
        if(rst == 'd1) begin
            newOperation <= 'd0;
            operator1Binary <= 'd0;
            operator1BCD <= 'd0;
        end else begin   
            if(newOperation == 'd1) begin
                operator1Binary <= resultBinary;
                operator1BCD <= resultBCD;
                newOperation <= 'd0;
            end
        end
    end

    wire dataEnable;
    wire data;

    if(state == 'd0) begin
        OpLogic(clk, rst, digitRead, numberPressed && bottonPressedPulse, numCounter, operator1Binary, operator1BCD);
        display_out(clk, rst, risingEdgeSerClk, operator1BCD, dataEnable, data);
    end else if (state == 'd1) begin
        OpLogic(clk, rst, digitRead, numberPressed && bottonPressedPulse, numCounter, operator2Binary, operator2BCD);
        display_out(clk, rst, risingEdgeSerClk, operator2BCD, dataEnable, data);
    end else if (state == 'd2) begin
        display_out(clk, rst, risingEdgeSerClk, reusltBCD, dataEnable, data);
    end



    
    
    

endmodule