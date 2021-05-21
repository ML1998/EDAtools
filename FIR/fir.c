/*
    Pipelined FIR implemented using C
        * 8-PAM：[-7,-5,-3, -1, 1, 3, 5,7], 
        * x4 upsampling,
        * filter coeff generated using MATLAB: h = round(rcosdesign(0.25,20,4)*2048)
*/

#include "svdpi.h"
#include "fir.h"
#include <math.h>
#include <stdio.h>

#define LENGTH 81

long long sigma2_sum = 0;

int rand();

int c_fir(int data, int delay)
{
    int k;    
    int h[LENGTH];
    
    /* Read filter parameters from file */
    FILE* file = fopen ("data.txt", "r");
    for (k = 0; k < LENGTH; k++) {
        fscanf (file, "%d", &h[k]);
    }

    /* Input: assign registers reversely 
        to ensure that they hold newest LENGTH cycles of data*/
    static int reg[LENGTH];
    for(k = LENGTH - 1; k >= 1; k--) {
        reg[k] = reg[k-1];
    }
    reg[0] = data;


    /* Filter: multiple and add */
    int tmp = 0;
    for (k = 0; k < LENGTH; k++) { 
        tmp += reg[k] * h[k];
    }
    sigma2_sum += tmp * tmp;

    /* Sat: limit between upper bound and lower bound */
    int tmp2 = tmp / 4;
    if (tmp2 > 32767) { 
        tmp2 = 32767;    
    } else if (tmp2 <= -32768) {
        tmp2 = -32768;   
    }
    /* Delay reg: using arrays */
    static int delay_reg[11];
    for (k = 10; k > 0; k--) {
        delay_reg[k] = delay_reg[k-1];
    }
    delay_reg[0] = tmp2;

    /* Cut and return   */
    return delay_reg[delay];
}


int main() 
{   
    int N = 8192;
    int source[4*N], shape[4*N];
    int i;

    /* Source features:
        - 8-PAM [-7,-5,-3, -1, 1, 3,5,7], 
        - x4 upsampling */
    for (i = 0; i < 4*N; i++) { 
        source[i] = i % 4 == 0 ? (rand() % 8) * 2 - 7 : 0; 
        shape[i] = c_fir(source[i], 1);
    }

    /*for (i = 0; i < 4*N; i++) {
        printf("%d,", source[i]);
    }
    printf("\n");

    double sigma2 = (double)sigma2_sum * 1.0 / 4 / N;

    printf("sigma = %f\n", sqrt(sigma2));*/
    
    return 0;
}