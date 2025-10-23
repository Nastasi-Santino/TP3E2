module keyb_iface(
    input  wire        clk,
    input  wire        reset,
    output reg  [3:0]  cols, 
    input  wire [3:0]  rows,
    output reg         is_number,
    output reg         is_op,
    output reg         is_eq,
    output wire        any_btn,      // ya sincronizado
    output reg  [3:0]  num_val,
    output reg  [1:0]  op_val
);

    //==========================================================
    // 1) Barrido de columnas (ring counter)
    //==========================================================
    always @(posedge clk) begin
        if (reset) begin
            cols <= 4'b0000;
        end else begin
            if (cols == 4'b0000)
                cols <= 4'b0001;
            else
                cols <= cols << 1;
        end
    end

    //==========================================================
    // 2) Sincronización de filas (anti-metaestabilidad)
    //==========================================================
    reg [3:0] rows_ff1, rows_ff2;
    always @(posedge clk) begin
        if (reset) begin
            rows_ff1 <= 4'b0000;
            rows_ff2 <= 4'b0000;
        end else begin
            rows_ff1 <= rows;
            rows_ff2 <= rows_ff1;
        end
    end

    assign any_btn = |rows_ff2;  // OR de filas sincronizadas

    //==========================================================
    // 3) Codificador -> índice (columna y fila)
    //==========================================================
    reg [1:0] col_idx;
    reg [1:0] row_idx;

    always @* begin
        case (cols)
            4'b0001: col_idx = 2'd0;
            4'b0010: col_idx = 2'd1;
            4'b0100: col_idx = 2'd2;
            4'b1000: col_idx = 2'd3;
            default: col_idx = 2'd0;   // opcional: 2'bxx
        endcase

        case (rows_ff2)
            4'b0001: row_idx = 2'd0;
            4'b0010: row_idx = 2'd1;
            4'b0100: row_idx = 2'd2;
            4'b1000: row_idx = 2'd3;
            default: row_idx = 2'd0;   // opcional: 2'bxx
        endcase
    end

    // Mapping elegido: [3:2] = col, [1:0] = row
    wire [3:0] btn_id = {col_idx, row_idx};

    //==========================================================
    // 4) Debounce: contador saturado + 'latched'
    //    Ajustá CUENTA a tu reloj y tiempo de rebote.
    //==========================================================
    localparam integer CUENTA = 50000;                // ~1 ms @ 50 MHz (ajustá)
    localparam integer CW     = $clog2(CUENTA + 1);

    reg [CW-1:0] cont;
    reg          latched;

    reg [3:0] btn_store;   // tecla estable (tras debounce)

    always @(posedge clk) begin
        if (reset) begin
            cont      <= {CW{1'b0}};
            latched   <= 1'b0;
            btn_store <= 4'd0;
        end else begin
            if (any_btn) begin
                if (cont < CUENTA)
                    cont <= cont + 1'b1;

                if ((cont >= CUENTA) && !latched) begin
                    btn_store <= btn_id;   // captura una vez
                    latched   <= 1'b1;     // no re-disparar hasta soltar
                end
            end else begin 
                cont      <= {CW{1'b0}};
                latched   <= 1'b0;
                btn_store <= 4'd0;         // o mantené último si preferís
            end
        end
    end


    //decodifico los valores posibles
    parameter [3:0] BTN_0 =    4'b0111;    //0000 0000 0000 0100;
    parameter [3:0] BTN_1 =    4'b0000;    //1000 0000 0000 0000;
    parameter [3:0] BTN_2 =    4'b0100;    //0100 0000 0000 0000;
    parameter [3:0] BTN_3 =    4'b1000;    //0010 0000 0000 0000;
    parameter [3:0] BTN_4 =    4'b0001;    //0000 1000 0000 0000;
    parameter [3:0] BTN_5 =    4'b0101;    //0000 0100 0000 0000;
    parameter [3:0] BTN_6 =    4'b1001;    //0000 0010 0000 0000;
    parameter [3:0] BTN_7 =    4'b0010;    //0000 0000 1000 0000;
    parameter [3:0] BTN_8 =    4'b0110;    //0000 0000 0100 0000;
    parameter [3:0] BTN_9 =    4'b1010;    //0000 0000 0010 0000;
    parameter [3:0] BTN_PLUS = 4'b1100;    //0001 0000 0000 0000;
    parameter [3:0] BTN_MIN =  4'b1101;    //0000 0001 0000 0000;
    parameter [3:0] BTN_EQ =   4'b1111;    //0000 0000 0000 0001;

    //genero las salidas en base a los botones
    always @(btn_store)
    begin
        case (btn_store)
            BTN_0: begin 
                is_number <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val = 4'd0;
                op_val = 2'd0;
            end
            BTN_1: begin 
                is_number <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val = 4'd1;
                op_val = 2'd0;
            end
            BTN_2: begin 
                is_number <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val = 4'd2;
                op_val = 2'd0;
            end
            BTN_3: begin 
                is_number <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val = 4'd3;
                op_val = 2'd0;
            end
            BTN_4: begin 
                is_number <= 1;
                is_eq <= 0;
                is_op <= 0;
                num_val = 4'd4;
                op_val = 2'd0;
            end

            //.... etc.

            BTN_PLUS: begin 
                is_number <= 0;
                is_eq <= 0;
                is_op <= 1;
                num_val = 4'd0;
                op_val = 2'd1;
            end
            BTN_MIN: begin 
                is_number <= 0;
                is_eq <= 0;
                is_op <= 1;
                num_val = 4'd0;
                op_val = 2'd2;
            end


            BTN_EQ: begin 
                is_number <= 0;
                is_eq <= 1;
                is_op <= 0;
                num_val = 4'd0;
                op_val = 2'd0;
            end

        endcase
    end

endmodule
 