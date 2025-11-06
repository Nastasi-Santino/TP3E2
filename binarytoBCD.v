// Conversión binario -> BCD usando "double dabble" (shift-add-3)
// - Parametrizable en ancho binario y cantidad de dígitos BCD.
// - Versión combinacional (sin clk). Si querés registrar salidas, ver nota al final.

module binary_to_bcd #(
    parameter integer BIN_WIDTH = 14,  // ancho de binary_in (por defecto 14 bits)
    parameter integer DIGITS    = 4    // número de dígitos BCD a generar (4 => miles..unidades)
)(
    input  wire [BIN_WIDTH-1:0] binary_in,
    output reg  [3:0]           bcd_thousands,
    output reg  [3:0]           bcd_hundreds,
    output reg  [3:0]           bcd_tens,
    output reg  [3:0]           bcd_units
);
    // Ancho del shifter: BIN + 4*DIGITS (los 4*DIGITS más altos guardan los BCD)
    localparam integer SHIFT_WIDTH = BIN_WIDTH + 4*DIGITS;

    // Registro interno de corrimiento
    reg [SHIFT_WIDTH-1:0] shifter;

    integer i; // recorre los bits binarios
    integer d; // recorre los dígitos BCD

    always @* begin
        // 1) Inicialización: BCD en cero (parte alta) y el binario en la parte baja
        shifter = { {4*DIGITS{1'b0}}, binary_in };

        // 2) Double Dabble: por cada bit del binario
        for (i = 0; i < BIN_WIDTH; i = i + 1) begin
            // 2a) Para cada dígito BCD: si > 4, sumar 3
            for (d = 0; d < DIGITS; d = d + 1) begin
                if (shifter[BIN_WIDTH + 4*d +: 4] > 4)
                    shifter[BIN_WIDTH + 4*d +: 4] = shifter[BIN_WIDTH + 4*d +: 4] + 3;
            end
            // 2b) Desplazar todo 1 bit a la izquierda
            shifter = shifter << 1;
        end

        // 3) Extraer los dígitos BCD (orden: unidades, decenas, centenas, miles)
        bcd_units     = shifter[BIN_WIDTH +  0 +: 4];
        bcd_tens      = shifter[BIN_WIDTH +  4 +: 4];
        bcd_hundreds  = shifter[BIN_WIDTH +  8 +: 4];
        bcd_thousands = shifter[BIN_WIDTH + 12 +: 4];
    end

endmodule
