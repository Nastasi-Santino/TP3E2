module fsm (input clk, input rst, output reg [1:0] salida);
    localparam waitingNum1 = 0
    localparam waitingNum2 = 1

    reg [2:0] state;
    always @(posedge(clk)) begin
        if(rst) begin
            salida <= 'd0;
            state <= 'd0;
        end else begin
            case(state) begin
                STATE_START:
                    salida <= 'd1;
                    state <= STATE_EL_SEGUNDO;
                STATE_EL_SEGUNDO:
                    salida <= 'd2;
                    state <= STATE_START;
                end
            endcase
        end
    end
endmodule