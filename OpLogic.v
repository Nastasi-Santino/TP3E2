module OpLogic(
    input clk, 
    input rst,
    input [3:0]digits,
    input newNumber,
    input [1:0]digitnumber,
    input newOperation,
    input [13:0] prevResultBinary,
    input [15:0] prevResultBCD,
    output reg [13:0]opBinary,
    output reg [15:0]opBCD
);

localparam firstDigit = 2'd0;
localparam secondDigit = 2'd1;
localparam thirdDigit = 2'd2;
localparam fourthDigit = 2'd3;

always @(posedge clk) begin
    if(rst == 'd1) begin
        opBinary <= 'd0;
        opBCD <= 'd0;
    end else begin
        if(newNumber) begin
            opBinary <= opBinary * 10 + digits;
            case (digitnumber)
                firstDigit:
                    opBCD[3:0] = digits;
                secondDigit:
                    opBCD[7:4] = digits;
                thirdDigit:
                    opBCD[11:8] = digits;
                fourthDigit:
                    opBCD[15:12] = digits;
            endcase
        end else if(newOperation) begin
            opBCD <= prevResultBCD;
            opBinary <= prevResultBinary;
        end
    end
end



endmodule