module SM2TC
	#(parameter width = 11)
	(SM, TC);
	input [width-1:0] SM;
	output [width-1:0] TC;

	wire [width-2:0] tmp;                 // Magnitude
	assign tmp = ~(SM[width-2:0]) + 'b1;  // Flip bits and add 1
 	assign TC = SM[width-1] ?             // Negative
                (tmp == 0 ?             // Negative zero
                  'd0 :                 // Convert to "positive" zero          
                  {1'b1, tmp}):         // Prepend negative sign
                SM;                     // Positive
endmodule
