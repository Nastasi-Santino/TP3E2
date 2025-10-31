module keyb_iface(
    input  wire        clk,
    input  wire        reset, 
    input  wire [3:0]  rows,
    output reg  [3:0]  cols,
    output reg         is_number,
    output reg         is_op,
    output reg         is_eq,
    output reg         btn_pressed,  // pulso 1 clk cuando se valida
    output wire        any_btn,      // nivel: hay alguna fila activa (sincronizada)
    output reg  [3:0]  num_val,
    output reg  [1:0]  op_val
);
    //==========================================================
    // 1) Barrido de columnas (ring counter)
    //==========================================================
    reg first_col;
    always @(posedge clk) begin
        if (reset) begin
            cols      <= 4'b0001;
            first_col <= 1'b1;
        end else begin
            if (cols == 4'b1000) begin
                cols      <= 4'b0001;
                first_col <= 1'b1;
            end else begin
                cols      <= cols << 1;
                first_col <= 1'b0;
            end
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

    assign any_btn = |rows_ff2;

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
            default: col_idx = 2'd0;
        endcase

        case (rows_ff2)
            4'b0001: row_idx = 2'd0;
            4'b0010: row_idx = 2'd1;
            4'b0100: row_idx = 2'd2;
            4'b1000: row_idx = 2'd3;
            default: row_idx = 2'd0;
        endcase
    end

    // Mapping elegido: [3:2] = col, [1:0] = row
    wire [3:0] btn_id = {col_idx, row_idx};

    //==========================================================
    // 4) Debounce robusto + captura y pulso btn_pressed (1 clk)
    //==========================================================
    localparam integer CUENTA = 50000;                // ~1 ms @ 50 MHz (ajustá)
    localparam integer CW     = $clog2(CUENTA + 1);

    reg [CW-1:0] cont;
    reg          latched;      // ya se validó una tecla y se "bloquea" hasta soltar
    reg [3:0]    btn_store;    // tecla estable tras debounce

    always @(posedge clk) begin
        if (reset) begin
            cont        <= {CW{1'b0}};
            latched     <= 1'b0;
            btn_store   <= 4'd0;
            btn_pressed <= 1'b0;
        end else begin
            // default: pulso de un ciclo
            btn_pressed <= 1'b0;

            if (any_btn) begin
                // acumula hasta superar el umbral
                if (cont < CUENTA)
                    cont <= cont + 1'b1;

                // dispara una sola vez cuando supera umbral y no estaba "latched"
                if ((cont >= CUENTA) && !latched) begin
                    btn_store   <= btn_id;   // captura la tecla válida
                    latched     <= 1'b1;     // no re-disparar hasta soltar
                    btn_pressed <= 1'b1;     // **pulso 1 clk** al validar
                end

                // opción adicional: al "cierre de vuelta" considerá consumido
                if (first_col) begin
                    // no hace falta nada extra aquí, el pulso ya fue de 1 clk
                end
            end else begin
                // al soltar: limpiar para permitir próxima detección
                cont      <= {CW{1'b0}};
                latched   <= 1'b0;
                btn_store <= 4'd0;
            end
        end
    end

    //==========================================================
    // 5) Decodificación sincronizada al pulso btn_pressed
    //==========================================================
    // Asignaciones de botones (del mapeo {col,row})
    localparam [3:0] BTN_0    = 4'b0111;
    localparam [3:0] BTN_1    = 4'b0000;
    localparam [3:0] BTN_2    = 4'b0100;
    localparam [3:0] BTN_3    = 4'b1000;
    localparam [3:0] BTN_4    = 4'b0001;
    localparam [3:0] BTN_5    = 4'b0101;
    localparam [3:0] BTN_6    = 4'b1001;
    localparam [3:0] BTN_7    = 4'b0010;
    localparam [3:0] BTN_8    = 4'b0110;
    localparam [3:0] BTN_9    = 4'b1010;
    localparam [3:0] BTN_PLUS = 4'b1100;
    localparam [3:0] BTN_MIN  = 4'b1101;
    localparam [3:0] BTN_EQ   = 4'b1111;

    // Registro del botón “salida” (opcional, útil para debug)
    reg [3:0] btn_out;

    always @(posedge clk) begin
        if (reset) begin
            btn_out   <= 4'd0;
            is_number <= 1'b0;
            is_op     <= 1'b0;
            is_eq     <= 1'b0;
            num_val   <= 4'd0;
            op_val    <= 2'd0;
        end else if (btn_pressed) begin
            // actualizar solo cuando hay un nuevo valor validado
            btn_out <= btn_store;

            case (btn_store)
                BTN_0: begin is_number<=1; is_eq<=0; is_op<=0; num_val<=4'd0; op_val<=2'd0; end
                BTN_1: begin is_number<=1; is_eq<=0; is_op<=0; num_val<=4'd1; op_val<=2'd0; end
                BTN_2: begin is_number<=1; is_eq<=0; is_op<=0; num_val<=4'd2; op_val<=2'd0; end
                BTN_3: begin is_number<=1; is_eq<=0; is_op<=0; num_val<=4'd3; op_val<=2'd0; end
                BTN_4: begin is_number<=1; is_eq<=0; is_op<=0; num_val<=4'd4; op_val<=2'd0; end
                BTN_5: begin is_number<=1; is_eq<=0; is_op<=0; num_val<=4'd5; op_val<=2'd0; end
                BTN_6: begin is_number<=1; is_eq<=0; is_op<=0; num_val<=4'd6; op_val<=2'd0; end
                BTN_7: begin is_number<=1; is_eq<=0; is_op<=0; num_val<=4'd7; op_val<=2'd0; end
                BTN_8: begin is_number<=1; is_eq<=0; is_op<=0; num_val<=4'd8; op_val<=2'd0; end
                BTN_9: begin is_number<=1; is_eq<=0; is_op<=0; num_val<=4'd9; op_val<=2'd0; end
                BTN_PLUS: begin is_number<=0; is_eq<=0; is_op<=1; num_val<=4'd0; op_val<=2'd0; end
                BTN_MIN:  begin is_number<=0; is_eq<=0; is_op<=1; num_val<=4'd0; op_val<=2'd1; end
                BTN_EQ:   begin is_number<=0; is_eq<=1; is_op<=0; num_val<=4'd0; op_val<=2'd0; end
                default:  begin is_number<=0; is_eq<=0; is_op<=0; num_val<=4'd0; op_val<=2'd0; end
            endcase
        end
        // Si NO hay nuevo pulso, se conservan los últimos valores.
    end

endmodule
