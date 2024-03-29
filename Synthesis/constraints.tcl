## Clock with frequency of 200ns = 5 MHz
## 1.88 = 532 MHz
## 1.90 = 526 MHz
## 1.94 = 515 MHz
## 2.00 = 500 MHz
## 2.08 = 480 MHz
## 2.22 = 450 MHz
## 2.50 = 400 MHz
create_clock -name "clk" -period 2.22 -waveform { 0 1.11 } { clk }
set_dont_touch_network [find port clk]

## Pointer to all inputs except clk
set prim_inputs [remove_from_collection [all_inputs] [find port clk]]
## Pointer to all inputs except clk and rst_n
set prim_inputs_no_rst [remove_from_collection $prim_inputs [find port rst_n]]
## Set clk uncertainty (skew)
set_clock_uncertainty 0.15 clk

## Set input delay & drive on all inputs
set_input_delay -clock clk 0.25 [copy_collection $prim_inputs_no_rst]
## rst_n goes to many places so don't touch
set_dont_touch_network [find port rst_n]

## Set output delay & load on all outputs
set_output_delay -clock clk 0.5 [all_outputs]
set_load 0.1 [all_outputs]

## Wire load model allows it to estimate internal parasitics 
set_wire_load_model -name TSMC32K_Lowk_Conservative -library tcbn45gsbwptc

## Max transition time is important for Hot-E reasons 
set_max_transition 0.1 [current_design]
