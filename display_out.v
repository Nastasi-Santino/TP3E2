module display_out(
    input wire clk,
    input wire reset,
    input wire enable,
    input wire [15:0] bcd_in,
    //input wire data_ready, 
    //output wire data_sent,
    output wire data_out,
    output wire sending_data,
);

// Get the segments
wire [31:0] segment_data;

bcd2segments deco0 (bcd_in[3:0], segment_data[7:0]);
bcd2segments deco1 (bcd_in[7:4], segment_data[15:8]);
bcd2segments deco2 (bcd_in[11:8], segment_data[23:16]);
bcd2segments deco3 (bcd_in[15:12], segment_data[31:24]);

// Wait time (in periods of ser_clk) between serial data send (must be >32 to allow to send all bits!)
parameter [31:0] send_interval = 31'd160;
reg [31:0] interval_counter;
reg data_out_reg;
reg [31:0] segment_data_out;

always @(posedge clk) begin
    if (reset) begin
        interval_counter <= 0;
        data_out_reg <= 0;
        segment_data_out <= 0; 
    end else begin
        if (enable) begin
            if (interval_counter == 0)
                segment_data_out <= segment_data;

            if (interval_counter <= 31)
                data_out_reg <= segment_data_out[interval_counter];
            else   
                data_out_reg <= 0;

            if (interval_counter <= send_interval)
                interval_counter <= interval_counter + 1;
            else   
                interval_counter <= 0;
        end    
    end
end

assign sending_data = (interval_counter <= 32) && (interval_counter >= 1);
assign data_out = data_out_reg;

endmodule