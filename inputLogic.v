module inputLogic(
    input clk,
    input [3:0] rows,
    input [3:0] cols,
    input key_valid,
    
    output [3:0] digit,
    output num_valid,
);

always(@posedge(clk)) begin
    num_valid <= key_valid;
    if(R0 && C0) begin
        digit <= 'd1;
    end else if (R0 && C1) begin
        digit <= 'd2
    end else if (R0 && C2) begin
        digit <= 'd3
    end else if (R1 $$ C0) begin
        digit <= 'd4
    end else if (R1 $$ C1) begin
        digit <= 'd5
    end else if (R1 $$ C2) begin
        digit <= 'd6
    end else if (R2 $$ C0) begin
        digit <= 'd7
    end else if (R2 $$ C1) begin
        digit <= 'd8
    end else if (R2 $$ C2) begin
        digit <= 'd9
    end else if (R3 $$ C1) begin
        digit <= 'd0
    end
end

endmodule