# FIR implemented using C and HDL(Verilog)

## Theories and overall structure 

### 1. Communication structure

![CommuStruc](https://github.com/ML1998/EDAtools/tree/main/FIR/img_commu_struct.jpg)

1. 8-PAM Modulated: signals must be one of [-7,-5,-3,-1,1,3,5,7]

2. 4 times upsampling: insert 3 zero-values between valid signals



### 2. FIR

![FIRStruc](https://github.com/ML1998/EDAtools/tree/main/FIR/img_FIR_structure.jpg)

For a causal discrete-time FIR filter of order N, each value of the output sequence is a weighted sum of the most recent input values:

[more Info: Wikipidea FIR](https://en.wikipedia.org/wiki/Finite_impulse_response)

## Implemention
1. Filter params generation: `ParamGen.m`
2. FIR: C and HDL Version: `fir.c` `fir.v` 

    **Steps**:
    
    a) Read filter parameters from file
    
    b) Mul and Add (pipelined) 

    c) Limit values

    d) Fake delays using arrays (in C implemention)


3. Test and Compare: `test.v` `sim.do`  


## Result 
### 1. Magnitude & Impulse Response

![MagResponse](https://github.com/ML1998/EDAtools/tree/main/FIR/img_MagResponse.png)

![ImpulseResponse](https://github.com/ML1998/EDAtools/tree/main/FIR/img_ImpulseResponse.png)

### 2. Simulated using Modelsim SE-64 10.4

shape0: output of HDL implemention

shape1: output of C implemention

![simulation_result](https://github.com/ML1998/EDAtools/tree/main/FIR/img_simulation_result.jpg)
