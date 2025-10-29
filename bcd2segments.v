module bcd2segments #(
    parameter COMMON_ANODE = 1'b1  // 1: ánodo común (salidas activas en bajo), 0: cátodo común (activas en alto)
)(
    input  wire [3:0] bcd_in,
    output wire [7:0] segments     // {a, b, c, d, e, f, g, dp}
);

    // Mapa "activo en alto" para a..g (independiente del tipo de display)
    // Orden: a b c d e f g
    reg [6:0] seg_on;

    always @* begin
        case (bcd_in)
            4'd0: seg_on = 7'b1111110; // 0 -> a b c d e f
            4'd1: seg_on = 7'b0110000; // 1 -> b c
            4'd2: seg_on = 7'b1101101; // 2 -> a b d e g
            4'd3: seg_on = 7'b1111001; // 3 -> a b c d g
            4'd4: seg_on = 7'b0110011; // 4 -> b c f g
            4'd5: seg_on = 7'b1011011; // 5 -> a c d f g
            4'd6: seg_on = 7'b1011111; // 6 -> a c d e f g
            4'd7: seg_on = 7'b1110000; // 7 -> a b c
            4'd8: seg_on = 7'b1111111; // 8 -> a b c d e f g
            4'd9: seg_on = 7'b1111011; // 9 -> a b c d f g
            default: seg_on = 7'b0000000; // blanco para BCD > 9
        endcase
    end

    // Adaptación al tipo de display
    wire [6:0] ag_out = (COMMON_ANODE) ? ~seg_on : seg_on;

    // Punto decimal apagado
    wire       dp_out = (COMMON_ANODE) ? 1'b1 : 1'b0;

    // Salida en orden {a,b,c,d,e,f,g,dp}
    assign segments = {ag_out, dp_out};

endmodule
