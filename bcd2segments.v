module bcd2segments (
    input wire [3:0] bcd_in,
    output wire [7:0] segments
);

    //ToDo: Replace with real code
    assign segments[7:4] = bcd_in[3:0];
    assign segments[3:0] = bcd_in[3:0];


endmodule