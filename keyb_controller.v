module keyb_controller(
        input clk,
        input reset,
        output reg [3:0] cols, 
        input wire [3:0] rows,
        output reg btn_pressed,
        output reg [7:0] btn_out      
);

    reg first_col;
    reg btn_press_internal;

    
    //Ring counter para seleccionar columnas
    always @(posedge clk) begin
        if (reset) begin
            cols <= 4'b0001;
            first_col <= 1;
        end
        else begin
            if (cols == 4'b1000) begin
                cols <= 4'b0001;
                first_col <= 1;
            end
            else begin
                cols <= cols << 1;
                first_col <= 0;
            end
        end
    end

    wire [7:0] btn_id;

    //Armo el valor que recibo, combino col y fila
    assign btn_id[7:4] = cols;
    assign btn_id[3:0] = rows;
 
    //reg para 'guardar' el valor
    reg [7:0] btn_store;

    //indica que se presiono un boton
    assign any_btn = rows[0] || rows [1] || rows [2] || rows[3];

    //guardo el valor que leo de fila y col
    always @(posedge clk) begin
        if (reset) begin
            btn_store <= 8'd0;
            btn_press_internal <= 0;
        end
        else begin
            if (any_btn) begin
                btn_store <= btn_id;
                btn_press_internal <= 1;
            end
            else if (first_col) begin
                btn_store <= 8'd0;
                btn_press_internal <= 0;                
            end
        end
        
    end

    always @(posedge clk) begin
        if (first_col) begin
            if (btn_press_internal) begin
                btn_out <= btn_store;
                btn_pressed <= 1;
            end
            else if (!btn_press_internal) begin
                btn_out <= 8'd0;
                btn_pressed <= 0;
            end
        end
    end


endmodule
 