module fsm (
    input clk, 
    input rst,
    input opRecived,
    input eqRecived,
    output reg [1:0] salida);
    localparam waitingNum1 = 2'd0
    localparam waitingNum2 = 2'd1
    localparam showingResult = 2'd2

    reg [1:0] state;
    always @(posedge(clk)) begin
        if(rst) begin
            salida <= 'd0;
            state <= 'd0;
        end else begin
            case(state) 
                waitingNum1:
                    salida <= 'd0;
                    if(opRecived == 1'd1) begin
                        state = 2'd1;
                    end
                waitingNum2:
                    salida <= 'd1;
                    if(eqRecived == 1'd1) begin
                        state = 2'd2;
                end
                showingResult:
                    salida <= 'd2
                    if(opRecived == 1'd1) begin
                        state = 2'd1;
                    end
            endcase
        end
    end
endmodule