# DC script practice
Write a DC script according to the following circuit diagram

![Circuit Diagram](https://github.com/ML1998/EDAtools/blob/main/DCscript/DCscript.jpg)

Assuming that the standard cell library used is `std.db`, the memory library used is `ram.db`.


Each module in the figure is a module, the top-level module name is `top.v`, and **top** has a global asynchronous clock **nrst**. 

The circuit timing requirements are as follows:
1. **CLK** clock cycle is 4ns, **DMAclk** clock cycle is 5ns
2. The input and output ports are the *synchronization signals* of the corresponding color clock domain
3. The *driving logic* of the input port is assumed to be the output of a *D flip-flop*
4. The *output load* is *20 inverter fan out*
5. The delay of **MUL** logic allows 2 cycles to complete


