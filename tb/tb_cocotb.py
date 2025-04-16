#******************************************************************************
# file:    tb_cocotb.py
#
# author:  JAY CONVERTINO
#
# date:    2025/01/27
#
# about:   Brief
# Cocotb test bench
#
# license: License MIT
# Copyright 2025 Jay Convertino
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#
#******************************************************************************

import random
import itertools

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer, Event
from cocotb.binary import BinaryValue
from cocotb.utils import get_sim_time
from cocotbext.axi import AxiStreamBus, AxiStreamSource, AxiStreamSink, AxiStreamMonitor, AxiStreamFrame

# Function: random_bool
# Return a infinte cycle of random bools
#
# Returns: List
def random_bool():
  temp = []

  for x in range(0, 256):
    temp.append(bool(random.getrandbits(1)))

  return itertools.cycle(temp)

# Function: start_clock
# Start the simulation clock generator.
#
# Parameters:
#   dut - Device under test passed from cocotb test function
def start_clock(dut):
  cocotb.start_soon(Clock(dut.clk, int(1000000000/dut.CLOCK_SPEED.value), units="ns").start())

# Function: reset_dut
# Cocotb coroutine for resets, used with await to make sure system is reset.
#
# Parameters:
#   dut - Device under test passed from cocotb.
async def reset_dut(dut):
  dut.rstn.value = 0
  await Timer(5, units="ns")
  dut.rstn.value = 1

# Function: count_pulses
# Cocotb task to count pulses from a output.
async def count_pulses(dut):
  #eat extra pulse do to START at
  count = dut.START_AT_ZERO.value-1

  init_time = get_sim_time('ms')

  while((get_sim_time('ms') - init_time) < 10):
    await RisingEdge(dut.ena)
    count += 1

  count *= 100

  print(f"INFO: Enable rate from counter: {count}")
  print(f"INFO: Enable rate target: {dut.rate.value.integer}")
  print(f"INFO: Deviation: {count/dut.rate.value.integer-1:.2%}")
  assert dut.rate.value.integer >= count*0.95, "Final output rate is less then 95% of the target."
  assert dut.rate.value.integer <= count*1.05, "Final output rate is greater then 105% of the target."

# Function: speed_test
# Test various speeds of the output enable
#
# Parameters:
#   dut - Device under test passed from cocotb.
@cocotb.test()
async def speed_test(dut):

    start_clock(dut)

    await reset_dut(dut)

    dut.hold.value = 1;

    for x in range(2400, 256000, 2400):

        dut.hold.value = 1;

        dut.rate.value = x;

        await RisingEdge(dut.clk)

        dut.hold.value = 0;

        await count_pulses(dut)

    await RisingEdge(dut.clk)

# Function: in_reset
# Coroutine that is identified as a test routine. This routine tests if device stays
# in unready state when in reset.
#
# Parameters:
#   dut - Device under test passed from cocotb.
@cocotb.test()
async def in_reset(dut):

    start_clock(dut)

    dut.rstn.value = 0

    await Timer(10, units="ns")

    assert dut.ena.value.integer == 0, "enable is 1!"

# Function: no_clock
# Coroutine that is identified as a test routine. This routine tests if no ready when clock is lost
# and device is left in reset.
#
# Parameters:
#   dut - Device under test passed from cocotb.
@cocotb.test()
async def no_clock(dut):

    dut.rstn.value = 0

    dut.clk.value = 0

    await Timer(10, units="ns")

    assert dut.ena.value.integer == 0, "enable is 1!"

