// EECS 270
// Lab 7:Four-Function Calculator Template
module FourFuncCalc
	#(parameter W = 11)			// Default bit width
	(Clock, Clear, Equals, Add, Subtract, Multiply, Divide, Number, Result, Overflow);
	localparam WW = 2 * W;		// Double width for Booth multiplier
	localparam BoothIter = $clog2(W);	// Width of Booth Counter
	input Clock;
	input Clear;				// C button
	input Equals;				// = button: displays result so far; does not repeat previous operation
	input Add;					// + button
	input Subtract;				// - button
	input Multiply;				// x button (multiply)
	input Divide;				// / button (division quotient)
	input [W-1:0] Number; 			// Must be entered in sign-magnitude on SW[W-1:0]
	output signed [W-1:0] Result;		// Calculation result in two's complement
	output Overflow;				// Indicates result can't be represented in W bits

  
//****************************************************************************************************
// Datapath Components
//****************************************************************************************************


//----------------------------------------------------------------------------------------------------
// Registers
// For each register, declare it along with the controller commands that
// are used to update its state following the example for register A
//----------------------------------------------------------------------------------------------------
	
	reg signed [W-1:0] A;			// Accumulator, otherwise known as M
	wire signed [W-1:0] R;
	reg signed [W-1:0] M;

	wire CLR_A, LD_A;			// CLR_A: A <= 0; LD_A: A <= Q
	
	wire LD_N;
	
	
	reg signed [W-1:0] N_TC;
	
	reg signed [W-1:0] N_SM;
	
	reg [BoothIter-1:0] MCTR;					// Iteration counter
	wire mCTR_DN;
	wire mCTR_CLR;	
	
	reg signed [WW+1:0] PM;
	wire M_LD;
	wire P_LD;
	wire PM_SH;
	
	

  
//----------------------------------------------------------------------------------------------------
// Number Converters
// Instantiate the three number converters following the example of SM2TC1
//----------------------------------------------------------------------------------------------------

	wire signed [W-1:0] NumberTC;	// Two's complement of Number
	SM2TC #(.width(W)) SM2TC1(Number, NumberTC);
	
	


//----------------------------------------------------------------------------------------------------
// MUXes
// Use conditional assignments to create the various MUXes
// following the example for MUX Y1
//----------------------------------------------------------------------------------------------------
	
	wire SEL_P;
	wire signed [W-1:0] Y1;
	wire signed [W-1:0] Y3;
	wire signed [W-1:0] Y2;	
	wire signed [W-1:0] Y5;	
	wire signed [W-1:0] Y6;	
	wire signed [W-1:0] Y4;	
	
	assign Y1 = SEL_P? PM[WW:W+1] : Y3;	// 1: Y1 = P; 0: Y1 = Y3
	

	assign Y3 = A;
	assign Y2 = NumberTC;
	
	wire SEL_N;

	assign Y6 = SEL_N? Y2 : Y5;
	
	wire SEL_M;

	assign Y4 = SEL_M? PM[W:1] : R;
	
	wire SEL_Q;

	assign Y5 = Y4;
	
	

  
//----------------------------------------------------------------------------------------------------
// Adder/Subtractor 
//----------------------------------------------------------------------------------------------------

	wire c0;					// 0: Add, 1: Subtract
	wire ovf;					// Overflow
	AddSub #(.W(W)) AddSub1(Y1, Y2, c0, R, ovf);
	wire PSgn = R[W-1] ^ ovf;		// Corrected P Sign on Adder/Subtractor overflow


//****************************************************************************************************
/* Datapath Controller
   Suggested Naming Convention for Controller States:
     All names start with X (since the tradtional Q connotes quotient in this project)
     XAdd, XSub, XMul, and XDiv label the start of these operations
     XA: Prefix for addition states (that follow XAdd)
     XS: Prefix for subtraction states (that follow XSub)
     XM: Prefix for multiplication states (that follow XMul)
     XD: Prefix for division states (that follow XDiv)
*/
//****************************************************************************************************


//----------------------------------------------------------------------------------------------------
// Controller State and State Labels
// Replace ? with the size of the state registers X and X_Next after
// you know how many controller states are needed.
// Use localparam declarations to assign labels to numeric states.
// Here are a few "common" states to get you started.
//----------------------------------------------------------------------------------------------------

	reg [4:0] X, X_Next;

	localparam XInit		= 5'd0;	// Power-on state (A == 0)
	localparam XClear	= 5'd1;		// Pick numeric assignments
	localparam XLoadA	= 5'd2;
	localparam XResult	= 5'd3;
	
	localparam XAddState = 5'd4;
	localparam XALoadN = 5'd5;
	localparam XAddition = 5'd6;
	localparam Xovf = 5'd7;
	
	localparam XSubState = 5'd8;
	localparam XSubN = 5'd9;
	localparam XSubtract = 5'd10; //sub = funcsub
	localparam XSLoadN = 5'd11;
	
	localparam XMulState = 5'd12;
	localparam XMLoadN = 5'd13;
	localparam XMulAdd = 5'd14;
	localparam XMulSub = 5'd15;
	localparam XMulShift = 5'd16;
	localparam XMulMore = 5'd17;
	localparam XMulCheck = 5'd18;
	
	localparam XDone = 5'd19;
	localparam XMDone = 5'd20;
	

//----------------------------------------------------------------------------------------------------
// Controller State Transitions
// This is the part of the project that you need to figure out.
// It's best to use ModelSim to simulate and debug the design as it evolves.
// Check the hints in the lab write-up about good practices for using
// ModelSim to make this "chore" manageable.
// The transitions from XInit are given to get you started.
//----------------------------------------------------------------------------------------------------

	always @* begin
	case (X)
		XInit:
			if (Clear)
				X_Next <= XInit;
			else if (Equals)
				X_Next <= XLoadA;
			else if (Add)
				X_Next <= XAddState;
			else if (Subtract)
				X_Next <= XSubState;
			else if (Multiply)
			    X_Next <= XMulState;
			else
				X_Next <= XInit;
	
	XLoadA:
	X_Next = XResult;
	
	XALoadN:
	X_Next <= XAddition;
	
	XSLoadN:
	X_Next <= XSubtract;
	
	XMLoadN:
	if(Clear)
	X_Next <= XInit;
	else
	X_Next <= XMulCheck;
	
	
	
	XAddition:
	if(~ovf)
	X_Next <= XResult;
	else if (ovf)
	X_Next <= Xovf;
	
	
	XResult:
	if(Add)
	X_Next = XAddState;
	else if (Subtract)
	X_Next = XSubState;
	else if (Multiply)
	X_Next = XMulState;
	else
	X_Next = XResult;
	
	
	XAddState:
	if(Equals)
	X_Next <= XALoadN;
	else if (Subtract)
	X_Next <= XSubState;
	else if (Clear)
	X_Next <= XClear;
	else
	X_Next <= XAddState;
	
	
	XSubState:
	if(Equals)
	X_Next <= XSLoadN;
	else if (Add)
	X_Next <= XAddState;
	else if (Clear)
	X_Next <= XClear;
	else
	X_Next <= XSubState;
	
	
	XMulState:
	    if(Equals)
	    X_Next <= XMLoadN;
	    else if (Clear)
	    X_Next <= XClear;
		 else if (Add)
		 X_Next <= XAddState;
		 else if (Subtract)
		 X_Next <= XSubState;
	    else
	    X_Next <= XMulState;
	
	
	XSubtract:
	if(~ovf)
	X_Next <= XResult;
	else if (ovf)
	X_Next <= Xovf;
	
	
	Xovf:
	if(Clear)
	X_Next <= XClear;
	else
	X_Next <= Xovf;
	
	XClear:
	X_Next <= XInit;
	
	XDone:
	if(PM[W+1] ^ PM[W])
	X_Next <= Xovf;
	else
	X_Next <= XResult;
	
	XMDone:
	if((PM[WW: W+1] == 11'b11111111111) || (PM[WW: W+1] == 11'b0))
		X_Next <= XResult;
	else
		X_Next <= Xovf;
	
	
	    
	    
	
    XMulCheck:
        if(~PM[1] & PM[0])
				X_Next <= XMulAdd;
        else if (PM[1] & ~PM[0])
				X_Next <= XMulSub;
        else
				X_Next <= XMulShift;
        
        
    XMulAdd:
    X_Next <= XMulShift;
    
    XMulSub:
    X_Next <= XMulShift;
    
    XMulShift:
    X_Next <= XMulMore;
    
    XMulMore:
        if (MCTR == 'd0)
            X_Next <= XMDone;
        else
            X_Next <= XMulCheck;

	endcase
end
	
	
	
	
	
	
	
	
  
  
//----------------------------------------------------------------------------------------------------
// Initial state on power-on
// Here's a freebie!
//----------------------------------------------------------------------------------------------------

	initial begin
		X <= XClear;
		A <= 'd0;
		N_TC <= 'd0;
		N_SM <= 'd0;
		MCTR <= W;		//BoothIter'dW;
		PM <= 'd0;      			//WW+1'd0;
	end


//----------------------------------------------------------------------------------------------------
// Controller Commands to Datapath
// No freebies here!
// Using assign statements, you need to figure when the various controller
// commands are asserted in order to properly implement the datapath
// operations.
//----------------------------------------------------------------------------------------------------

assign LD_A = (X == XLoadA) || (X == XSubtract) || (X == XAddition) || (X == XMDone);
assign LD_N = (X == XALoadN) || (X == XInit) || (X == XSLoadN) || (X == XMLoadN);


assign SEL_N = (X == XLoadA);

assign c0 = (X == XSubtract) || (X == XMulSub);


assign CLR_A = (X == XClear);


assign PM_SH = (X == XMulShift);
assign MCTR_DN = (X == XMulShift);
assign M_LD = (X == XMLoadN);
assign P_LD = (X == XMulAdd) | (X == XMulSub);

assign SEL_M = (X == XMLoadN) || (X == XMulCheck) || (X == XMulAdd) || (X == XMulSub) || (X == XMulMore) || (X == XMDone) || (X == XMulShift);
assign SEL_Q = (X == XMLoadN) || (X == XMulCheck) || (X == XMulAdd) || (X == XMulSub) || (X == XMulMore) || (X == XMDone) || (X == XMulShift);
assign SEL_P = (X == XMLoadN) || (X == XMulCheck) || (X == XMulAdd) || (X == XMulSub) || (X == XMulMore) || (X == XMDone) || (X == XMulShift);

assign LD_M = (X == XMLoadN);
assign LD_P = (X == XMulAdd) || (X == XMulSub) || (X == XMulState);
assign AllDone = (X == XMDone);




//----------------------------------------------------------------------------------------------------  
// Controller State Update
//----------------------------------------------------------------------------------------------------

	always @(posedge Clock)
		if (Clear)
			X <= XClear;
		else
			X <= X_Next;

      
//----------------------------------------------------------------------------------------------------
// Datapath State Update
// This part too is your responsibility to figure out.
// But there is a hint to get you started.
//----------------------------------------------------------------------------------------------------
		wire signed [W:0] zero;
		assign zero = 'd0;
	
	always @(posedge Clock)
		begin
			N_TC <= LD_N ? NumberTC : N_TC;
			A <= CLR_A ? 'd0 : (LD_A? Y6: A);
			M <= LD_M ? A: M;
		end
		
		always @(posedge Clock)
			if(X == XMulState)
				begin
				PM[WW+1:W+1] <= 'd0;
				PM[0] <= 0;
				MCTR <= W;
				end
			else
				begin
					PM <= 
					(M_LD? $signed({zero, A, 1'b0}) :				// Load M
						(P_LD ? $signed({PSgn, R, PM[W:0]}) :	// Add/Sub
							(PM_SH ? PM >>> 1 :								// ASR
							 PM																	// Unchanged
							)        
						)
					);
		MCTR <= MCTR_DN ? MCTR - 1: MCTR;
		end
		
		assign P = AllDone ? PM[WW:1] : 'd0;
		

	

//---------------------------------------------------------------------------------------------------- 
// Calculator Outputs
// The two outputs are Result and Overflow, get it?
//----------------------------------------------------------------------------------------------------
	assign Result = A;
	assign Overflow = (X == Xovf);

endmodule





