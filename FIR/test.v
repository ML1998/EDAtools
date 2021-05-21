/*
    Test and Compare the result of FIR implemented using HDL and C
*/

module test;
    reg clk;
    reg nrst;

    /* Init clk and nrst */
    initial begin
        clk     <= 1'b0;
        nrst    <= 1'b0;
        #10 nrst <= 1'b1;
    end

    always @(*) begin
        #1 clk <= ~clk;        
    end

    /* Counter: x4 upsampling */
    reg [1:0] cnt;
    always @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            cnt <= 0;
        end
        else begin
            cnt <= cnt + 2'b1;
        end
    end

    /* Source: 8-PAM & upsampling
    /   x 0 0 0, x 0 0 0, ......
        where x belongs to [-7,-5,-3, -1, 1, 3,5,7] */
	reg signed[3:0] src;
	always @(posedge clk) begin
        	if(~nrst) begin 
                src <= 0;
            end
        	else if(cnt == 0) begin
                src <= ($random % 8) * 2 - 7; 
            end
            else begin
                src <= 0; 
        	end
        end;

    /*Two FIRs: 
        shape0: HDL implementation, shape1:C implementation*/
    
    wire [15:0] shape0;
    reg  [15:0] shape1;
    v_fir fir_0(clk, nrst, src, shape0);    // HDL implementation

    import "DPI-C" function int c_fir(      // Make C function visible to verilog code
        input int data,
        input int delay
    );
    always @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            shape1 <= 0;
        end
        else begin
            shape1 <= c_fir(src, 10);       // C implementation
        end
    end
    
endmodule