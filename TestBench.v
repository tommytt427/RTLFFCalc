`timescale 1ns/100ps
module TestBench();
	parameter WIDTH = 11; // Data bit width

    // Inputs and Outputs
	reg Clock;
	reg Clear; // C button
	reg Equals; // = button
	reg Add; // + button
	reg Subtract; // - button
	reg Multiply; // x button
	reg Divide; // Divide button
	reg [WIDTH-1:0] NumberSM; // Sign-magnitude number input
	wire signed [WIDTH-1:0] Result;
	wire Overflow;
	wire CantDisplay;
	wire [4:0] State;

	wire signed [WIDTH-1:0] NumberTC;
	SM2TC #(.width(WIDTH)) SM2TC1(NumberSM, NumberTC); // Sign-magnitude to two's complement conversion
	FourFuncCalc #(.W(WIDTH)) FFC(Clock, Clear, Equals, Add, Subtract, Multiply, Divide, NumberSM, Result, Overflow);

    // Define 10 ns Clock
	always #5 Clock = ~Clock;

	initial begin
		Clock = 0; Clear = 1;
		#20; Clear = 0;

/*        // Test case: 1 + 3 (equals) - 4 = 0
		#10; Equals = 1; NumberSM = 1;
		#10; Equals = 0;
		#20; Add = 1;
		#20; Add = 0;
		#20; Equals = 1; NumberSM = 3;
		#20; Equals = 0;
		#20; Subtract = 1;
		#20; Subtract = 0;
		#20; Equals = 1; NumberSM = 4;
		#20; Equals = 0;

        // Test case: 1023 + (-1023) = 0
		#10; Equals = 1; NumberSM = 1023;
		#10; Equals = 0;
		#20; Add = 1;
		#20; Add = 0;
		#20; Equals = 1; NumberSM = 'b11111111111; // -1023 in sign-magnitude
		#20; Equals = 0;

        // Test case: 1023 + 10 = 1033 (display overflow)
		#10; Equals = 1; NumberSM = 1023;
		#10; Equals = 0;
		#20; Add = 1;
		#20; Add = 0;
		#20; Equals = 1; NumberSM = 10;
		#20; Equals = 0;

*/        // Test case: 1 * 2 * 3
		#10; Equals = 1; NumberSM = 1;
		#10; Equals = 0;
		#20; Multiply = 1;
		#20; Multiply = 0;
		#20; Equals = 1; NumberSM = 2;
		#20; Equals = 0;
		#20; Multiply = 1;
		#20; Multiply = 0;
		#20; Equals = 1; NumberSM = 3;
		#20; Equals = 0;
		#(4*10*WIDTH);
/*
        // Test case: -2 * (-1)
		#10; Equals = 1; NumberSM = 11'b10000000010; // -2 in sign-magnitude
		#10; Equals = 0;
		#20; Multiply = 1;
		#20; Multiply = 0;
		#20; Equals = 1; NumberSM = 11'b10000000001; // -1 in sign-magnitude
		#20; Equals = 0;
		#(4*10*WIDTH);

        // Test case: 3 * 0
		#10; Equals = 1; NumberSM = 3;
		#10; Equals = 0;
		#20; Multiply = 1;
		#20; Multiply = 0;
		#20; Equals = 1; NumberSM = 0;
		 #20; Equals = 0;
		 #(4*10*WIDTH);
*/
		// End of simulation
		#100;
		$finish;
	end
endmodule


