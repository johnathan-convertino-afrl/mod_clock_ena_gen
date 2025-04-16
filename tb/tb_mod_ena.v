//******************************************************************************
// file:    tb_mod_ena.v
//
// author:  JAY CONVERTINO
//
// date:    2025/01/27
//
// about:   Brief
// Test bench for mod clock divide enable generator
//
// license: License MIT
// Copyright 2025 Jay Convertino
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
//******************************************************************************

`timescale 1ns/100ps

/*
 * Module: tb_mod_ena
 *
 * mod clock enable test bench
 *
 * Parameters:
 *
 * CLOCK_SPEED   - Clock speed
 * START_AT_ZERO - Set to 1 to enable start at zero.
 * DELAY         - Set to the number of clock cycles to delay the enable output signal.
 *
 */
module tb_mod_ena  #(
    parameter CLOCK_SPEED   = 2000000,
    parameter ENABLE_RATE   = 1000,
    parameter DELAY         = 0
  )();
  
  wire                      tb_dut_clk;
  wire                      tb_dut_rstn;

  reg [31:0]                avg_freq;
  reg [31:0]                ena_counter;
  reg [31:0]                clk_counter;
  reg [31:0]                loops;
  
  // fst dump command
  initial begin
    $dumpfile ("tb_mod_ena.fst");
    $dumpvars (0, tb_mod_ena);
    #1;
  end
  
  //Group: Instantiated Modules

  /*
   * Module: clk_stim
   *
   * Generate a 50/50 duty cycle set of clocks and reset.
   */
  clk_stimulus #(
    .CLOCKS(1),
    .CLOCK_BASE(CLOCK_SPEED),
    .CLOCK_INC(1000),
    .RESETS(1),
    .RESET_BASE(2000),
    .RESET_INC(100)
  ) clk_stim (
    .clkv(tb_dut_clk),
    .rstnv(tb_dut_rstn),
    .rstv()
  );
  

  /*
   * Module: dut
   *
   * Device under test, mod_clock_ena_gen
   */
  mod_clock_ena_gen #(
    .CLOCK_SPEED(CLOCK_SPEED),
    .DELAY(DELAY)
  ) dut (
    .clk(tb_dut_clk),
    .rstn(tb_dut_rstn),
    .start0(1'b1),
    .hold(1'b0),
    .rate(ENABLE_RATE),
    .ena(tb_dut_ena)
  );

  always @(posedge tb_dut_clk) begin
    if(tb_dut_rstn == 1'b0) begin
      ena_counter <= 0;
      clk_counter <= 0;
      loops       <= 1;
      avg_freq    <= 0;
    end else begin
      clk_counter <= clk_counter + 1;

      // SIM ONLY BLOCKING
      if(tb_dut_ena == 1'b1) begin
        ena_counter = ena_counter + 1;
      end

      if(loops >= 10)
      begin
        $finish();
      end

      if(clk_counter >= CLOCK_SPEED) begin
        avg_freq <= (ena_counter + avg_freq) / (loops == 1 ? 1 : 2);

        $display ("LOOP: %d, FREQUENCY: %d", loops, ena_counter);
        $strobe  ("AVG OUTPUT ENABLE FREQUENCY: %d", avg_freq);

        ena_counter <= 0;
        clk_counter <= 1;
        loops <= loops + 1;
      end
    end
  end

  
endmodule

