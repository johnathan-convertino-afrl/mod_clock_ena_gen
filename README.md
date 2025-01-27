# MOD CLOCK ENABLE GENERATOR
### Simple core that generates a enable pulse of some rate derived from the clock.

![image](docs/manual/img/AFRL.png)

---

   author: Jay Convertino   
   
   date: 2025.01.27
   
   details: Divide a clock to a slower rate. The output is an enable synced to the clock rate.
   
   license: MIT   
   
---

### Version
#### Current
  - V1.0.0 - initial release

#### Previous
  - none

### DOCUMENTATION
  For detailed usage information, please navigate to one of the following sources. They are the same, just in a different format.

  - [mod_clock_ena_gen.pdf](docs/manual/mod_clock_ena_gen.pdf)
  - [github page](https://johnathan-convertino-afrl.github.io/mod_clock_ena_gen/)

### DEPENDENCIES
#### Build

  - AFRL:utility:helper:1.0.0

#### Simulation

  - AFRL:utility:sim_helper

### PARAMETERS

*   CLOCK_SPEED      - This is the aclk frequency in Hz
*   START_AT_ZERO    - Start counter at 0 if set. Otherwise start at CLOCK_SPEED/2.
*   DELAY            - Delay the enable by a number of clock ticks

### COMPONENTS
#### SRC

* mod_clock_ena_gen.v
  
#### TB

* tb_mod_ena.v
  
### FUSESOC

* fusesoc_info.core created.
* Simulation uses icarus to run data through the core. Verification added, will auto end sim when done.

#### Targets

* RUN WITH: (fusesoc run --target=sim VENDER:CORE:NAME:VERSION)
  - default (for IP integration builds)
  - sim
  - sim_cocotb
