##################Compress Bitstream############################
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LED[*]}]
#pl led
set_property PACKAGE_PIN H9 [get_ports {GPIO_LED[0]}]
set_property PACKAGE_PIN B11 [get_ports {GPIO_LED[1]}]
set_property PACKAGE_PIN B10 [get_ports {GPIO_LED[2]}]
set_property PACKAGE_PIN C11 [get_ports {GPIO_LED[3]}]