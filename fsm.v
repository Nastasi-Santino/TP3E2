module fsm (
    input clk, 
    input rst,
    input opRecived,
    input eqRecived,
    output reg [1:0] salida,
    output reg newOperation);

    localparam waitingNum1 = 2'd0;
    localparam waitingNum2 = 2'd1;
    localparam showingResult = 2'd2;

    reg [1:0] state;
    always @(posedge(clk)) begin
        if(rst) begin
            salida <= 'd0;
            state <= 'd0;
        end else begin
            case(state) 
                waitingNum1: begin
                    salida <= 'd0;
                    newOperation <= 'd0;
                    if(opRecived == 'd1) begin
                        state = 2'd1;
                    end
                end
                waitingNum2: begin
                    salida <= 'd1;
                    newOperation <= 'd0;
                    if(eqRecived == 1'd1) begin
                        state <= 2'd2;
                    end
                end
                showingResult: begin
                    salida <= 'd2;
                    newOperation <= 'd0;
                    if(opRecived == 1'd1) begin
                        newOperation <= 'd1;
                        state <= 2'd1;
                    end
                end
            endcase
        end
    end
endmodule