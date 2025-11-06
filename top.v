module top ( 
    input gpio_2,
    input gpio_28,
    input gpio_38,
    input gpio_42, 
    input gpio_36,
    output gpio_43,
    output gpio_34,
    output gpio_37,
    output gpio_31,
    output gpio_46,
    output gpio_47,
    output gpio_45);

    wire rst;
    wire [3:0]rows;
    wire [3:0]cols;

    assign rst = gpio_2;
    assign rows[0] = gpio_28;
    assign rows[1] = gpio_38;
    assign rows[2] = gpio_42;
    assign rows[3] = gpio_36;
    assign cols[0] = gpio_43;
    assign cols[1] = gpio_34;
    assign cols[2] = gpio_37;
    assign cols[3] = gpio_31;

    SB_HFOSC  u_SB_HFOSC(.CLKHFPU(1'd1), .CLKHFEN(1'd1), .CLKHF(clk));

    parameter CUENTA = 60000;

    reg ser_clk;
    assign gpio_46 = ser_clk;
    reg[15:0] serialCount;
    reg prev_ser_clk;
    wire risingEdgeSerClk;

    always@(posedge clk) begin
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
    wire [3:0]digitRead;
    wire [1:0]operationRead;
    reg[1:0] numCounter;

    always @(posedge clk) begin
        if(rst || (operationPressed && bottonPressedPulse) || (equalsPressed && bottonPressedPulse)) begin
            numCounter <= 'd0;
        end else if(numberPressed && bottonPressedPulse) begin
            numCounter <= numCounter + 'd1;
        end
    end


    keyb_iface keyb_iface1(clk, rst, rows, cols,
             numberPressed, operationPressed, equalsPressed, bottonPressedPulse, 
             bottonPressedNow, digitRead, operationRead);

    wire[1:0] state;
    wire newOperation;

    fsm fsm1(clk, rst, bottonPressedPulse && operationPressed, bottonPressedPulse && equalsPressed, state, newOperation);

    wire [13:0]operator1Binary;
    wire [13:0]operator2Binary;
    wire [15:0]operator1BCD;
    wire [15:0]operator2BCD;
    wire [13:0]resultBinary;
    wire [15:0]resultBCD;
    

    ALU ALU1(clk, rst, operationRead, operationPressed, equalsPressed, operator1Binary, operator2Binary, resultBinary);

    binary_to_bcd binary_to_bcd1(resultBinary, resultBCD[3:0], resultBCD[7:4], resultBCD[11:8], resultBCD[15:12]);

    wire dataEnable;
    wire data;

    assign dataEnable = gpio_47;
    assign data = gpio_45;
    
    reg[13:0] actualDisplayBinary;
    reg[15:0] actualDisplayBCD;

    always @(posedge(clk))begin
        if(state == 'd0) begin
            actualDisplayBCD <= operator1BCD;
            
        end else if (state == 'd1) begin
            actualDisplayBCD <= operator2BCD;
        end else if (state == 'd2) begin
            actualDisplayBCD <= resultBCD;
        end
    end

    OpLogic OpLogic1(clk, rst, digitRead, numberPressed && bottonPressedPulse && (state == 'd0), numCounter,
                    newOperation, resultBinary, resultBCD, operator1Binary, operator1BCD);
    OpLogic OpLogic2(clk, rst, digitRead, numberPressed && bottonPressedPulse  && (state == 'd1), numCounter,
                    1'd0, 14'd0, 16'd0, operator2Binary, operator2BCD);
    display_out display_out1(clk, rst, risingEdgeSerClk, actualDisplayBCD, dataEnable, data);

    
endmodule