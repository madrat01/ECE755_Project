module dnn (
    input logic                 clk, 
    input logic signed [6:0]    x0, x1, x2, x3, 
    input logic signed [4:0]    w04, w05, w06, w07, w14, w15, w16, w17, w24, w25, w26, w27, w34, w35, w36, w37, w48, w58, w49, w59, w68, w69, w78, w79,
    input logic                 in_ready,
    input logic signed [16:0]   y4_aggr, y5_aggr, y6_aggr, y7_aggr, 
    output logic signed [14:0]  y4_relu, y5_relu, y6_relu, y7_relu, 
    output logic signed [20:0]  out0, out1, 
    output logic                out0_ready, out1_ready
);

logic signed [14:0] y4, y5, y6, y7;
logic               out_comp_ready;
logic signed [4:0]  w48_p2, w58_p2, w49_p2, w59_p2, w68_p2, w69_p2, w78_p2, w79_p2; //Flopped version of output calculation weights

// Layer-1 calculations
// Uses 16 5*5 multipliers and 12 12-bit adders
always_ff @ (posedge clk) begin
    if (in_ready) begin
        y4 <= x0*w04 + x1*w14 + x2*w24 + x3*w34;
        y5 <= x0*w05 + x1*w15 + x2*w25 + x3*w35;
        y6 <= x0*w06 + x1*w16 + x2*w26 + x3*w36;
        y7 <= x0*w07 + x1*w17 + x2*w27 + x3*w37;
        out_comp_ready <= 1'b1;
    end else
        out_comp_ready <= 1'b0;
end

// Flop output calculation weights to multiply in the cycle 2 (after in_ready)
always_ff @ (posedge clk) begin
    w48_p2 <= w48;
    w58_p2 <= w58;
    w49_p2 <= w49;
    w59_p2 <= w59;
    w68_p2 <= w68;
    w69_p2 <= w69;
    w78_p2 <= w78;
    w79_p2 <= w79;
end
        
assign y4_relu = y4[14] ? 0 : y4;
assign y5_relu = y5[14] ? 0 : y5;
assign y6_relu = y6[14] ? 0 : y6;
assign y7_relu = y7[14] ? 0 : y7;

// Output calculations
// Uses 8 12*5 multipliers and 6 17-bit adders
always_ff @ (posedge clk) begin
    if (out_comp_ready) begin
        out0 <= y4_aggr*w48_p2 + y5_aggr*w58_p2 + y6_aggr*w68_p2 + y7_aggr*w78_p2;
        out1 <= y4_aggr*w49_p2 + y5_aggr*w59_p2 + y6_aggr*w69_p2 + y7_aggr*w79_p2;
        out0_ready <= 1'b1;
        out1_ready <= 1'b1;
    end
    else begin
        out0_ready <= 1'b0;
        out1_ready <= 1'b0;
    end
end

endmodule