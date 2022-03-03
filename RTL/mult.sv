module mult (
    input logic signed [11:0]   a,
    input logic signed [4:0]    b,
    output logic signed [16:0]  out
);

assign out = a*b;

endmodule