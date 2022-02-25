module dnn_gnn (
    input logic                 clk, 
    input logic signed [5:0]    x0, x1, x2, x3, 
    input logic signed [4:0]    w04, w05, w06, w07, w14, w15, w16, w17, w24, w25, w26, w27, w34, w35, w36, w37, w48, w58, w49, w59, w68, w69, w78, w79,
    input logic                 in_ready,
    input logic signed [12:0]   y4_aggr, y5_aggr, y6_aggr, y7_aggr, 
    output logic signed [12:0]  y4, y5, y6, y7, 
    output logic signed [16:0]  out0, out1, 
    output logic                out0_ready, out1_ready
);

logic signed [12:0] y4_relu, y5_relu, y6_relu, y7_relu;
logic               out_comp_ready;

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
        
assign y4_relu = y4_aggr[12] ? 0 : y4_aggr;
assign y5_relu = y5_aggr[12] ? 0 : y5_aggr;
assign y6_relu = y6_aggr[12] ? 0 : y6_aggr;
assign y7_relu = y7_aggr[12] ? 0 : y7_aggr;

always_ff @ (posedge clk) begin
    if (out_comp_ready) begin
        out0 <= y4_relu*w48 + y5_relu*w58 + y6_relu*w68 + y7_relu*w78;
        out1 <= y4_relu*w49 + y5_relu*w59 + y6_relu*w69 + y7_relu*w79;
        out0_ready <= 1'b1;
        out1_ready <= 1'b1;
    end
    else begin
        out0_ready <= 1'b0;
        out1_ready <= 1'b0;
    end
end

endmodule