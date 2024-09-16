// ModelSim allows the use of "generate".
// This module defines a parameterized W-bit RCA adder/dubtsctor
module AddSub
	#(parameter W = 16)			// Default width
	(A, B, c0, S, ovf);
	input [W-1:0] A, B;			// W-bit unsigned inputs
	input c0;								// Carry-in
	output [W-1:0] S;				// W-bit unsigned output
	output ovf;							// Overflow signal

	wire [W:0] c;						// Carry signals
	assign c[0] = c0;

// Instantiate and "chain" W full adders 
	genvar i;
	generate
		for (i = 0; i < W; i = i + 1)
			FullAdder FA[W-1:0](A[i], B[i] ^ c[0], c[i], S[i], c[i+1]);
	endgenerate

// Overflow
		assign ovf = c[W-1] ^ c[W];
endmodule

// W-bit Booth Multiplier
module BoothMul
	#(parameter W = 16)								// Default bit width
	(Clock, Reset, Start, M, Q, P);
	localparam WW = 2 * W;						// Double bit width
	localparam BoothIter = $clog2(W);	// Width of Booth counter
	input Clock;
	input Reset;											// To initial state
	input Start;											// Start new multiplication
	input signed [W-1:0] Q;						// Multiplicand
	input signed [W-1:0] M;						// Multiplier
	output signed [WW-1:0] P;					// Product

// Datapath Components
	reg signed [WW+1:0] PM;						// Product/Multiplier double register
	wire M_LD;												// Load multiplier
	wire P_LD;												// Load product
	wire PM_ASR;											// Arithmetic Shift Right of PM

	reg [BoothIter-1:0] CTR;					// Iteration counter
	wire CTR_DN;											// Count down

	wire c0;
	wire ovf;
	wire signed [W-1:0] R;
	AddSub #(.W(W)) AddSub1(PM[WW:W+1], Q, c0, R, ovf);
	wire PSgn = R[W-1] ^ ovf;					// Corrected P Sign on Adder/Subtractor overflow

// Datapath Controller
	reg [2:0] State, State_Next;
	localparam Init		= 3'd0;
	localparam Load		= 3'd1;
	localparam Check	= 3'd2;
	localparam Add		= 3'd3;
	localparam Sub		= 3'd4;
	localparam Next		= 3'd5;
	localparam More		= 3'd6;
	localparam Done		= 3'd7;

 // Controller State Transitions
	always @*
	begin
		case(State)
			Init:
				if (Start)
					State_Next <= Load;
				else
					State_Next <= Init;

			Load:	State_Next <= Check;
			
			Check:
				if (~PM[1] & PM[0])
						State_Next <= Add;
				else if (PM[1] & ~PM[0])
						State_Next <= Sub;
				else
						State_Next <= Next;

			Add: State_Next <= Next;

			Sub: State_Next <= Next;

			Next: State_Next <= More;

			More:
				if (CTR == 'd0)
						State_Next <= Done;
				else
						State_Next <= Check;

			Done: State_Next <= Init;
		endcase
	end

 // Initial State
	initial
	begin
		State <= Init;
		PM <= 'd0;
		CTR <= W;
	end

// Controller State Update
	always @(posedge Clock)
		if (Reset)
			State <= Init;
		else
			State <= State_Next;

// Controller Output Logic
	assign M_LD			= (State == Load);
	assign P_LD			= (State == Add) | (State == Sub);
	assign PM_ASR 	= (State == Next);
	assign CTR_DN 	= (State == Next);
	assign c0 			= (State == Sub);
	assign AllDone	= (State == Done);

// Datapath State Update
	wire signed [W:0] ZERO; 					// (W+1)-bit 0 since `(W+1)'d0 does not work
	assign ZERO = 'd0;
	always @(posedge Clock)
		if (Reset)
			begin
				PM[WW+1:W+1] <= 'd0;
				PM[0] <= 0;
				CTR <= W;
			end
		else
			begin
				PM <=
					(M_LD? $signed({ZERO, M, 1'b0}) :				// Load M
						(P_LD ? $signed({PSgn, R, PM[W:0]}) :	// Add/Sub
							(PM_ASR ? PM >>> 1 :								// ASR
							 PM																	// Unchanged
							)        
						)
					);
				CTR <= CTR_DN ? CTR - 1 : CTR;
			end

// Datapath Output Logic
	assign P = AllDone? PM[WW:1] : 'd0;
endmodule

// BoothMul TestBench
`timescale 1ns/100ps
module BoothMulTestBench();
	parameter W = 8;							// Data bit width
	localparam WW = 2 * W;

	reg Clock;
	always #5 Clock = ~Clock;

	reg Reset;
	reg Start;

	reg signed [W-1:0] Q, M;
	wire signed [WW-1:0] P;

	BoothMul #(.W(W)) BM(Clock, Reset, Start, M, Q, P);

	initial begin
		Clock = 0; Reset = 1;
		#10;
		Reset = 0;
		M = 'd7; Q = -'d8;
		Start = 1;
		#10;
		Start = 0;
		#(4 * W * 10);
		M = 'd7; Q = -'d6;
		Start = 1;
		#10;
		Start = 0;
		#(4 * W * 10);
		M = 'd13; Q = -'d10;
		Start = 1;
		#10;
		Start = 0;
		#(4 * W * 10);
		M = 'd15; Q = 'd15;
		Start = 1;
		#10;
		Start = 0;
		#(4 * W * 10);
	end
endmodule


