module binary_to_bcd #( // Ancho de la entrada binaria
    input  wire                  clk,
    input  wire [13:0]  binary_in,
    output reg  [3:0]            bcd_hundreds,
    output reg  [3:0]            bcd_tens,
    output reg  [3:0]            bcd_units
);

    // Registro interno para el proceso de conversión.
    // Necesitamos 3 dígitos BCD (12 bits) y el binario original (8 bits).
    // Tamaño total: 12 (BCD) + 8 (BIN) = 20 bits.
    reg [BIN_WIDTH + 11:0] bcd_shifter;

    integer i;

    // Lógica combinacional para la conversión
    always @* begin
        // 1. Inicialización: Colocar el binario en la parte baja del registro.
        bcd_shifter = {20'b0, binary_in}; // Limpiamos la parte BCD y cargamos el binario.

        // 2. Algoritmo "Double Dabble": Iterar por cada bit de la entrada binaria.
        for (i = 0; i < BIN_WIDTH; i = i + 1) begin

            // 2a. Comprobar cada dígito BCD (unidades, decenas, centenas) antes de desplazar.
            // Si algún dígito es mayor que 4 (0100), se le suma 3.
            // La comprobación se hace en los bits que corresponderán a los BCD tras el desplazamiento.
            
            // Comprobar dígito de unidades (bits 11:8 del shifter)
            if (bcd_shifter[11:8] > 4) begin
                bcd_shifter[11:8] = bcd_shifter[11:8] + 3;
            end

            // Comprobar dígito de decenas (bits 15:12 del shifter)
            if (bcd_shifter[15:12] > 4) begin
                bcd_shifter[15:12] = bcd_shifter[15:12] + 3;
            end

            // Comprobar dígito de centenas (bits 19:16 del shifter)
            if (bcd_shifter[19:16] > 4) begin
                bcd_shifter[19:16] = bcd_shifter[19:16] + 3;
            end

            // 2b. Desplazar todo el registro un bit a la izquierda.
            bcd_shifter = bcd_shifter << 1;
        end

        // 3. Asignar los resultados a las salidas.
        // Los dígitos BCD quedan en la parte alta del registro.
        bcd_hundreds = bcd_shifter[19:16];
        bcd_tens     = bcd_shifter[15:12];
        bcd_units    = bcd_shifter[11:8];
    end

endmodule