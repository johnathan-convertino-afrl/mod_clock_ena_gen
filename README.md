# MOD CLOCK ENABLE GENERATOR
### Simple core that generates a enable pulse of some rate derived from the clock.

![image](docs/manual/img/AFRL.png)

---

  author: Jay Convertino   
  
  date: 2025.01.27
  
  details: Divide a clock to a slower rate. The output is an enable synced to the clock rate.
  
  license: MIT   
   
  Actions:  

  [![Lint Status](../../actions/workflows/lint.yml/badge.svg)](../../actions)  
  [![Manual Status](../../actions/workflows/manual.yml/badge.svg)](../../actions)  
  
---

### Version
#### Current
  - V1.0.1 - Bug in setting start, caused incorrect enable rate.

#### Previous
  - V1.0.0 - initial release

### DOCUMENTATION
  For detailed usage information, please navigate to one of the following sources. They are the same, just in a different format.

  - [mod_clock_ena_gen.pdf](docs/manual/mod_clock_ena_gen.pdf)
  - [github page](https://johnathan-convertino-afrl.github.io/mod_clock_ena_gen/)

### PARAMETERS

*   CLOCK_SPEED      - This is the aclk frequency in Hz
*   START_AT_ZERO    - Start counter at rate if set. Otherwise start at CLOCK_SPEED/2.
*   DELAY            - Delay the enable by a number of clock ticks

### COMPONENTS
#### SRC

* mod_clock_ena_gen.v
  
#### TB

* tb_mod_ena.v
* tb_cocotb
  
### FUSESOC

* fusesoc_info.core created.
* Simulation uses icarus to run data through the core. Verification added, will auto end sim when done.

#### Targets

* RUN WITH: (fusesoc run --target=sim VENDER:CORE:NAME:VERSION)
  - default (for IP integration builds)
  - lint
  - sim
  - sim_cocotb
