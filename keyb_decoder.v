module keyb_decoder(
        input wire [7:0] btn_id,
        output reg is_number,
        output reg is_op,
        output reg is_eq,
        output reg [3:0] num_val,
        output reg [1:0] op_val 
);


    //decodifico los valores posibles - 8 bits donde los primeros 4 son la col y los siguientes la fila
    parameter [7:0] BTN_0 =    8'b01000001;    //0000 0000 0000 0100;
    parameter [7:0] BTN_1 =    8'b10001000;    //1000 0000 0000 0000;
    parameter [7:0] BTN_2 =    8'b01001000;    //0100 0000 0000 0000;
    parameter [7:0] BTN_3 =    8'b00101000;    //0010 0000 0000 0000;
    parameter [7:0] BTN_4 =    8'b10000100;    //0000 1000 0000 0000;
    parameter [7:0] BTN_5 =    8'b01000100;    //0000 0100 0000 0000;
    parameter [7:0] BTN_6 =    8'b00100100;    //0000 0010 0000 0000;
    parameter [7:0] BTN_7 =    8'b10000010;    //0000 0000 1000 0000;
    parameter [7:0] BTN_8 =    8'b01000010;    //0000 0000 0100 0000;
    parameter [7:0] BTN_9 =    8'b00100010;    //0000 0000 0010 0000;
    parameter [7:0] BTN_PLUS = 8'b00011000;    //0001 0000 0000 0000;
    parameter [7:0] BTN_MIN =  8'b00010100;    //0000 0001 0000 0000;
    parameter [7:0] BTN_EQ =   8'b00010001;    //0000 0000 0000 0001;

    //genero las salidas en base a los botones
    always @(*) begin
        case (btn_id)
            BTN_0: begin 
                is_number <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd0;
                op_val <= 2'd0;
            end
            BTN_1: begin 
                is_number <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd1;
                op_val <= 2'd0;
            end
            BTN_2: begin 
                is_number <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd2;
                op_val <= 2'd0;
            end
            BTN_3: begin 
                is_number <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd3;
                op_val <= 2'd0;
            end
            BTN_4: begin 
                is_number <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd4;
                op_val <= 2'd0;
            end
            BTN_5: begin 
                is_number <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd5;
                op_val <= 2'd0;
            end
            BTN_6: begin 
                is_number <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd6;
                op_val <= 2'd0;
            end
            BTN_7: begin 
                is_number <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd7;
                op_val <= 2'd0;
            end
            BTN_8: begin 
                is_number <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd8;
                op_val <= 2'd0;
            end
            BTN_9: begin 
                is_number <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd9;
                op_val <= 2'd0;
            end
                                                                
            BTN_PLUS: begin 
                is_number <= 0;
                is_eq <= 0;
                is_op <= 1;
                num_val <= 4'd0;
                op_val <= 2'd1;
            end
            BTN_MIN: begin 
                is_number <= 0;
                is_eq <= 0;
                is_op <= 1;
                num_val <= 4'd0;
                op_val <= 2'd2;
            end


            BTN_EQ: begin 
                is_number <= 0;
                is_eq <= 1;
                is_op <= 0;
                num_val <= 4'd0;
                op_val <= 2'd0;
            end

            default: begin
                is_number <= 0;
                is_eq <= 0;
                is_op <= 0;
                num_val <= 4'd0;
                op_val <= 2'd0;
            end
        endcase

    end

endmodule