//******************************************************************************
// file:    mod_clock_ena_gen.v
//
// author:  JAY CONVERTINO
//
// date:    2025/01/27
//
// about:   Brief
// Generate a enable signal at some rate that divides the clock. This can be
// any rate. This enable will not be a 50% clock cycle or as stable as a pll.
// This uses the mod algorithm. Essentially it adds the number of ticks till
// it reaches the clock rate and then saves the remainder and generates a 1
// cycle high pulse.
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
 * Module: mod_clock_ena_gen
 *
 * Mod rate enable generator
 *
 * Parameters:
 *
 *   CLOCK_SPEED      - This is the aclk frequency in Hz
 *   DELAY            - Delay the enable by a number of clock ticks
 *
 * Ports:
 *
 *   clk       - Clock used for enable generation
 *   rstn      - Negative reset for anything clocked on clk
 *   start0    - Start counter at rate if set. Otherwise set to CLOCK_SPEED/2+rate (midpoint).
 *   clr       - Clear counter back to start on active high asycronusly.
 *   hold      - hold enable low and pause + reset count till hold removed (low).
 *   rate      - rate that enable pulse will be generated, must be less then the clock rate.
 *   ena       - positive enable that is pulsed high at enable rate.
 */
module mod_clock_ena_gen #(
    parameter CLOCK_SPEED   = 2000000,
    parameter START_AT_ZERO = 0,
    parameter DELAY         = 0
  ) 
  (
    input           clk,
    input           rstn,
    input           start0,
    input           clr,
    input           hold,
    input   [31:0]  rate,
    output          ena
  );
  
  `include "util_helper_math.vh"

  reg [clogb2(CLOCK_SPEED):0] counter;
  
  reg r_ena = 0;
  
  //baud enable generator
  always @(posedge clk or posedge clr) begin
    if(rstn == 1'b0) begin
      counter <= (start0 ? rate : CLOCK_SPEED/2+rate);
      r_ena   <= 1'b0;
    end else if(clr == 1'b1) begin
      counter <= (start0 ? rate : CLOCK_SPEED/2+rate);
      r_ena   <= 1'b0;
    end else if(hold == 1'b1) begin
      counter <= counter;
      r_ena   <= r_ena;
    end else begin
      counter <= counter + rate;
      r_ena   <= 1'b0;
      
      if(counter >= CLOCK_SPEED) begin
        counter <= counter - CLOCK_SPEED + rate;
        r_ena   <= 1'b1;
      end
    end
  end
  
  //DELAY output of uart_ena
  generate
    if(DELAY > 0) begin : gen_DELAY_ENABLED
      //DELAYs
      reg [DELAY:0] DELAY_ena;
      
      assign ena = DELAY_ena[DELAY];
      
      always @(posedge clk) begin
        if(rstn == 1'b0) begin
          DELAY_ena <= 0;
        end else begin
          DELAY_ena <= {DELAY_ena[DELAY-1:0], r_ena};
        end
      end
    end else begin : gen_DELAY_DISABLED
      assign ena = r_ena;
    end
  endgenerate
endmodule
