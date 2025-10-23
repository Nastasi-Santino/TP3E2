module OpLogic(
    input clk, 
    input rst,
|   input [3:0]digits;
    input newNumber;
    output reg [13:0]num; 
)

always @(posedge clk) begin
    if(rst) begin
        output <= 'd0;
    end else begin
        if(newNumber) begin
            num <= num * 10 + digits;
        end
    end
end



endmodule