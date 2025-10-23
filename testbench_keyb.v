// Code your testbench here
// or browse Examples
module testbench();
  reg clk, reset;
  reg [3:0] rows_in;
  reg press_btn21;
  
  wire [3:0] cols_out;
  
  wire is_num, is_op, is_eq, press;
  wire [3:0] num_val;
  wire [1:0] op_val;
  
  keyb_iface keyb01(clk, reset, cols_out, rows_in, is_num,
                    is_op, is_eq, press, num_val, op_val);
  
  initial begin
    clk <= 0;
    reset <= 1;
    rows_in <= 4'b0000;
    press_btn21 = 0;
  end
  
  always begin
    #5 clk <= ~clk;
    #1 rows_in[2] <= press_btn21 && cols_out[1];
  end

  
  initial begin
    
    $dumpfile("1.vcd");
    $dumpvars(1);
    #7 reset = 0;
    
    #100 press_btn21 <= 1;
    #500 press_btn21 <= 0;

    #100 $finish;
  end
  
endmodule