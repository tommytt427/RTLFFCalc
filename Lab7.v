module Lab7(
    input CLOCK_50,  // Main clock
    input [3:0] KEY, // Push-buttons
    input [17:0] SW, // Switches
    output [6:0] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, // 7-segment displays
    output [8:0] LEDG // Overflow LED, corrected array declaration
);


assign LEDG[8] = overflow;

wire clear, equals, add, subtract, multiply, divide;
assign clear = SW[17] & ~KEY[0];
assign equals = SW[17] & ~KEY[3];
assign add = ~SW[17] & ~KEY[3];
assign subtract = ~SW[17] & ~KEY[2];
assign multiply = ~SW[17] & ~KEY[1];
assign divide = ~SW[17] & ~KEY[0];

wire [10:0] number_input;
assign number_input = SW[10:0]; 

    wire [36:0] Clock;
    Clock_Div clock_divider(
        .CLK_in(CLOCK_50), // Assuming CLOCK_50 is the main clock input to this module
        .CLKS_out(Clock)
    );

wire signed [10:0] result;
wire overflow;

wire ROVF;
wire NOVF;


FourFuncCalc calculator (
    .Clock(Clock[22]),
    .Clear(clear),
    .Equals(equals),
    .Add(add),
    .Subtract(subtract),
    .Multiply(multiply),
    .Divide(divide),
    .Number(number_input),
    .Result(result),
    .Overflow(overflow)
);

Binary_to_7SEG display_number (
    .N(number_input),
    .Encoding(0), 
    .Sign(HEX7), 
    .D2(HEX6),
    .D1(HEX5),
    .D0(HEX4),
    .TooLarge(NOVF)
);

Binary_to_7SEG display_result (
    .N(result),
    .Encoding(1), 
    .Sign(HEX3), 
    .D2(HEX2),
    .D1(HEX1),
    .D0(HEX0),
    .TooLarge(ROVF)
);


endmodule
