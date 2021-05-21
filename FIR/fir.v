/*
    Pipelined FIR implemented using HDL
        * 8-PAM：[-7,-5,-3, -1, 1, 3,5,7], 
        * x4 upsampling,
        * filter coeff generated using MATLAB: h = round(rcosdesign(0.25,20,4)*2048)
*/

module v_fir(
    input                       clk,
    input                       nrst,
    input signed        [3:0]   data,
    
    output reg signed   [15:0]  shape
);

    import "DPI-C" function int c_fir(
        input int data,
        input int delay
    );

    parameter N = 81;

    /* filter coefficient */
    reg signed [11:0] h[0:(N-1)/2];          
  
    assign h[0] = 0;      assign h[1] = -3;     assign h[2] = -3;     assign h[3] = -1;     assign h[4] = 3; 
    assign h[5] = 4;      assign h[6] = 1;      assign h[7] = -3;     assign h[8] = -5;     assign h[9] = -3; 
    assign h[10] = 3;     assign h[11] = 7;     assign h[12] = 5;     assign h[13] = -1;    assign h[14] = -8;
    assign h[15] = -8;    assign h[16] = -2;    assign h[17] = 7;     assign h[18] = 10;    assign h[19] = 3; 
    assign h[20] = -8;    assign h[21] = -12;   assign h[22] = -3;    assign h[23] = 13;    assign h[24] = 22;
    assign h[25] = 10;    assign h[26] = -19;   assign h[27] = -44;   assign h[28] = -38;   assign h[29] = 6;
    assign h[30] = 67;    assign h[31] = 96;    assign h[32] = 54;    assign h[33] = -56;   assign h[34] = -174;
    assign h[35] = -203;  assign h[36] = -66;   assign h[37] = 244;   assign h[38] = 637;   assign h[39] = 966;
    assign h[40] = 1094;

    /* data register */
    reg signed [15:0] data_reg[0:N-1];  

    integer k;
    always @(posedge clk or negedge nrst) begin
        if (~nrst) begin
            for (k = 0; k < N; k = k + 1) begin
                data_reg[k] <= 0;
            end
        end
        else begin
            for (k = 1; k < N; k = k + 1) begin
                data_reg[k] <= data_reg[k-1];
            end
            data_reg[0] <= data;
        end
    end
        
    /* multiple and add */
    reg signed [19:0] mul[0:N-1];

    always @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            for (k = 0; k < N; k = k + 1) begin
                mul[k] <= 0;
            end
        end
        else begin
            for (k = 0; k < (N + 1)/2; k = k + 1) begin
                mul[k] <= data_reg[k] * h[k];
            end
            for (k = (N + 1)/2; k < N; k = k + 1) begin
                mul[k] <= data_reg[k] * h[N-1-k];
            end
        end
    end

    /* sum0: pipeline stage-0 */
    reg signed [20:0] sum0 [0:(N-1)/2];
    always @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            for (k = 0; k < (N - 1)/2; k = k + 1) begin
                sum0[k] <= 0;
            end
        end
        else begin
            for (k = 0; k < (N - 1)/2; k = k + 1) begin
                sum0[k] <= mul[2*k] + mul[2*k+1];
            end
            sum0[(N - 1)/2] <= mul[N - 1];
        end
    end
            
    /* sum1: pipeline stage-1 */
    reg signed  [21:0]  sum1[0:(N-1)/4];
    always @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            for (k = 0; k < (N - 1)/4; k = k + 1) begin
                sum1[k] <= 0;
            end
        end
        else begin
            for (k = 0; k < (N - 1)/4; k = k + 1) begin
                sum1[k] <= sum0[2*k] + sum0[2*k+1];
            end
            sum1[(N - 1)/4] <= sum0[(N - 1)/2];
        end
    end

    /* sum2: pipeline stage-2 */
    reg signed  [22:0]  sum2[0:(N-1)/8];
    always @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            for (k = 0; k < (N - 1)/8; k = k + 1) begin
                sum2[k] <= 0;
            end
        end
        else begin
            for (k = 0; k < (N - 1)/8; k = k + 1) begin
                sum2[k] <= sum1[2*k] + sum1[2*k+1];
            end
            sum2[(N - 1)/8] <= sum1[(N - 1)/4];
        end
    end

    /* sum3: pipeline stage-3 */
    reg signed  [23:0]  sum3[0:(N-1)/16];
    always@(posedge clk or negedge nrst) begin
        if(~nrst) begin
            for (k = 0; k < (N - 1)/16; k = k + 1) begin
                sum3[k] <= 0;
            end
        end
        else begin
            for (k = 0; k < (N - 1)/16; k = k + 1) begin
                sum3[k] <= sum2[2*k] + sum2[2*k+1];
            end
            sum3[(N - 1)/16] <= sum2[(N - 1)/8];
        end
    end

    /* sum4: pipeline stage-4 */
    reg signed  [24:0]  sum4[0:2];
    always@(posedge clk or negedge nrst) begin
        if(~nrst) begin
            for (k = 0; k <= 2; k = k + 1) begin
                sum4[k] <= 0;
            end
        end
        else begin
            for (k = 0; k <= 2; k = k + 1) begin
                sum4[k] <= sum3[2*k] + sum3[2*k+1];
            end
        end
    end

    /* sum5: pipeline stage-5 */
    reg signed  [25:0]  sum5[0:1];
    always@(posedge clk or negedge nrst) begin
        if(~nrst) begin
            sum5[0] <= 0;
            sum5[1] <= 0;
        end
        else begin
            sum5[0] <= sum4[0] + sum4[1];
            sum5[1] <= sum4[2];
        end
    end

    /* sum6: pipeline stage-6 */
    reg signed  [26:0]  sum6;
    always@(posedge clk or negedge nrst) begin
        if(~nrst) begin
            sum6 <= 0;
        end
        else begin
            sum6 <= sum5[0] + sum5[1];
        end
    end

    /* Divide by 4 */
    reg signed [24:0] sum_div;
    always@(posedge clk or negedge nrst) begin
        sum_div <= sum6[26:2];
    end

    /* Saturation limit and out */
    always @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            shape <= 0;
        end
        else begin
            shape <= sat(sum_div);
        end
    end
    
    function [15:0] sat;
        input signed[24-1:0] x;
        begin
            if (x > 32767) begin
                sat = 32767;
            end
            else if (x < -32768) begin
                sat = -32768;
            end 
            else begin
                sat = x;
            end
        end
    endfunction

endmodule
