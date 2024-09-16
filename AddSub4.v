module AddSub4(A, B, Co, R, ovf);

input [3:0] A, B;
input Co;
output [3:0] R;
output ovf;

wire [3:0] B_comp;
wire [4:0] carry;

assign B_comp = (Co) ? (~B) : B;

assign carry[0] = Co;


FA addsub1(.a(A[0]), .b(B_comp[0]), .cin(carry[0]), .s(R[0]), .cout(carry[1]));
FA addsub2(.a(A[1]), .b(B_comp[1]), .cin(carry[1]), .s(R[1]), .cout(carry[2]));
FA addsub3(.a(A[2]), .b(B_comp[2]), .cin(carry[2]), .s(R[2]), .cout(carry[3]));
FA addsub4(.a(A[3]), .b(B_comp[3]), .cin(carry[3]), .s(R[3]), .cout(carry[4]));

assign ovf = (carry[4] ^ carry[3]);
endmodule
