module ALU(
    input clk, 
    input rst,
    input[1:0]operationVal, 
    input opEnable,
    input eqEnable,
    input[13:0]operator1,
    input[13:0]operator2,
    output reg[13:0]result); 

localparam  add = 0;
localparam  sub = 1;
localparam  mult = 2;
localparam  div = 3;


always @(posedge clk) begin
    if(rst) begin
        result <= 'd0;    
    end else begin
        if(opEnable) begin
            case(operationVal)
                add: result <= operator1 + operator2;
                sub: result <= operator1 - operator2;
                mult: result <= operator1 * operator2;
                div: begin 
                    if(operator2 != 'd0) begin
                        result <= operator1 / operator2;
                    end else begin
                        result = 'd9999;
                    end
                end
            endcase
        end
    end
end



endmodule