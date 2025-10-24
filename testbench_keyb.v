`timescale 1ns/10ps

module testbench_keyb();
  reg clk, reset;
  wire [3:0] rows_in;
  reg press_btn21;
  reg press_btn33;
  reg press_btn00;
  reg press_btn30;
  
  wire [3:0] cols_out;
  
  wire is_num, is_op, is_eq, press;
  wire [3:0] num_val;
  wire [1:0] op_val;
  wire btn_pressed;
  wire btn_press_col;
  wire [7:0] btn_id;
  
  keyb_controller keyb_ctrl1(clk, reset, cols_out, rows_in, btn_press_col, btn_id);
  keyb_decoder keyb_decode1(clk, reset, btn_press_col, btn_id, is_num, is_op, is_eq, num_val, op_val, btn_pressed);
  //keyb_iface keyb1(clk, reset, cols_out, rows_in, is_num, is_op, is_eq, btn_pressed, num_val, op_val);

  // Simulo los switches del teclado
  assign rows_in[0] = (press_btn00 && cols_out[0])  ;
  assign rows_in[1] = 0;
  assign rows_in[2] = (press_btn21 && cols_out[1]);
  assign rows_in[3] = (press_btn33 && cols_out[3]) || (press_btn30 && cols_out[0]);  

  initial begin
    clk <= 0;
    reset <= 1;
    //rows_in <= 4'b0000;
    press_btn21 = 0;  // 6
    press_btn30 = 0;  // +
    press_btn33 = 0;  // 1
    press_btn00 = 0;  // =
  end
  
  always begin
    #5 clk <= ~clk;
  end
  
  
  initial begin
    
    $dumpfile("1.vcd");
    $dumpvars(2);
    #7 reset = 0;
    
    #100 press_btn21 <= 1;
    #500 press_btn21 <= 0;
    #300 press_btn30 <= 1;
    #400 press_btn30 <= 0;
    #300 press_btn33 <= 1;
    #20 press_btn33 <= 0;
    #50 press_btn33 <= 1;
    #40 press_btn33 <= 0;
    #40 press_btn33 <= 1;
    #100 press_btn33 <= 0;
    #10 press_btn33 <= 1;
    #600 press_btn33 <= 0;
    #300 press_btn00 <= 1;
    #400 press_btn00 <= 0;

    #200 $finish;
  end
  
endmodule