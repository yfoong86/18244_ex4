<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
The module will take in a go signal, from which it will start recognizing data on that clock edge.
Then it will keep reading data until finish is asserted, and output what the range
between the highest and lowest numbers are.

There will also be an error signal which will assert for the following reasons:
    - if go and finish are asserted together
    - if go is asserted twice
    - if finish is asserted before go

Explain how your project works
The project works using an FSM to keep track of if we are receiving values or if there is an error.
There is also combinational logic in order to include the value currently on the clock cycle
when finish is asserted.

## How to test
The module can be tested with a testbench that has a few valid and invalid
instructions. You can assert go, put a few values into data_in and check if the 
range is valid when finish is asserted. You can also try a few invalid
sequences to see if the error flag is working correctly.

Explain how to use your project
You can use the project to find the range between numbers that are being sent
into a module one at a time.

## External hardware
No external hardware is needed for the project.

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
