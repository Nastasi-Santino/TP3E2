module OpLogic(
    input clk, 
    input rst,
|   input [3:0]digits;
    input newNumber;
    input opnumber;
    input [1:0]digitnumber;
    output reg [13:0]op1Binary;
    output reg [13:0]op2Binary;
    output reg [13:0]op1BCD;
    output reg [15:0]op2BCD;
)

localparam firstDigit = 2'd0;
localparam secondDigit = 2'd1;
localparam thirdDigit = 2'd2;
localparam fourthDigit = 2'd3;

always @(posedge clk) begin
    if(rst) begin
        output <= 'd0;
    end else begin
        if(newNumber) begin
            if(opnumber == 'd0) begin
                op1Binary <= op1Binary * 10 + digits;
                case (digitnumber)
                    firstDigit:
                        op1BCD[3:0] = digits;
                    secondDigit:
                        op1BCD[7:4] = digits;
                    thirdDigit:
                        op1BCD[11:8] = digits;
                    fourthDigit:
                        op1BCD[15:12] = digits;
                endcase
            end else if(opnumber == 'd1) begin
                op2Binary <= op2Binary * 10 + digits;
                case (digitnumber)
                    firstDigit:
                        op2BCD[3:0] = digits;
                    secondDigit:
                        op2BCD[7:4] = digits;
                    thirdDigit:
                        op2BCD[11:8] = digits;
                    fourthDigit:
                        op2BCD[15:12] = digits;
                endcase
            end
        end
    end
end



endmodule