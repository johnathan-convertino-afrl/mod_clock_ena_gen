//******************************************************************************
// file:    tb_cocotb.v
//
// author:  JAY CONVERTINO
//
// date:    2025/01/27
//
// about:   Brief
// Test bench wrapper for cocotb
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
 * Module: tb_cocotb
 *
 * Mod rate enable generator test bench
 *
 * Parameters:
 *
 *   CLOCK_SPEED      - This is the aclk frequency in Hz
 *   START_AT_ZERO    - Start counter at 0 if set. Otherwise start at CLOCK_SPEED/2.
 *   DELAY            - Delay the enable by a number of clock ticks
 *
 * Ports:
 *
 *   clk       - Clock used for enable generation
 *   rstn      - Negative reset for anything clocked on clk
 *   hold      - hold enable low and pause + reset count till hold removed (low).
 *   rate      - rate that enable pulse will be generated, must be less then the clock rate.
 *   ena       - positive enable that is pulsed high at enable rate.
 */
module tb_cocotb #(
    parameter CLOCK_SPEED   = 2000000,
    parameter START_AT_ZERO = 0,
    parameter DELAY         = 0
  )
  (
    input           clk,
    input           rstn,
    input           hold,
    input   [31:0]  rate,
    output          ena
  );

  // fst dump command
  initial begin
    $dumpfile ("tb_cocotb.fst");
    $dumpvars (0, tb_cocotb);
    #1;
  end
  
  //Group: Instantiated Modules

  /*
   * Module: dut
   *
   * Device under test, mod_clock_ena_gen
   */
  mod_clock_ena_gen #(
    .CLOCK_SPEED(CLOCK_SPEED),
    .START_AT_ZERO(START_AT_ZERO),
    .DELAY(DELAY)
  ) dut (
    .clk(clk),
    .rstn(rstn),
    .hold(hold),
    .rate(rate),
    .ena(ena)
  );
  
endmodule

