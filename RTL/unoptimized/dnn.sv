module dnn (
    input logic                 clk, 
    input logic                 rst_n,
    input logic signed [6:0]    x0, x1, x2, x3, 
    input logic signed [4:0]    w04, w05, w06, w07, w14, w15, w16, w17, w24, w25, w26, w27, w34, w35, w36, w37, w48, w58, w49, w59, w68, w69, w78, w79,
    input logic                 in_ready,
    input logic signed [16:0]   y4_aggr, y5_aggr, y6_aggr, y7_aggr, 
    output logic signed [14:0]  y4_relu, y5_relu, y6_relu, y7_relu, 
    output logic signed [20:0]  out0, out1, 
    output logic                out0_ready, out1_ready
);

logic signed [14:0] y4, y5, y6, y7;
logic signed [20:0]	mul1, mul2, mul3, mul4;
logic               out_comp_ready;

// Layer-1 calculations
// Uses 16 5*5 multipliers and 12 12-bit adders
always_ff @ (posedge clk, negedge rst_n) begin
	if (~rst_n) begin
	    out_comp_ready <= 1'b0;
		out0_ready <= 1'b0;
		out1_ready <= 1'b0;
	end
    else begin
		if (in_ready & ~out_comp_ready) begin
            mul1 <= x0*w04 + x1*w14 + x2*w24 + x3*w34;
            mul2 <= x0*w05 + x1*w15 + x2*w25 + x3*w35;
            mul3 <= x0*w06 + x1*w16 + x2*w26 + x3*w36;
            mul4 <= x0*w07 + x1*w17 + x2*w27 + x3*w37;
            out_comp_ready <= 1'b1;
		    out0_ready <= 1'b0;
		    out1_ready <= 1'b0;
		end else if (out_comp_ready) begin
		    mul1 <= y4_aggr*w48 + y5_aggr*w58 + y6_aggr*w68 + y7_aggr*w78;
		    mul2 <= y4_aggr*w49 + y5_aggr*w59 + y6_aggr*w69 + y7_aggr*w79;
		    mul3 <= 'bx;
		    mul4 <= 'bx;
		    out0_ready <= 1'b1;
		    out1_ready <= 1'b1;
		    out_comp_ready <= 1'b0;
		end
		else begin
            out_comp_ready <= 1'b0;
		    out0_ready <= 1'b0;
		    out1_ready <= 1'b0;
		    mul1 <= 'bx;
		    mul2 <= 'bx;
		    mul3 <= 'bx;
		    mul4 <= 'bx;
		end
	end
end

assign y4 = out_comp_ready ? mul1[14:0] : 'b0;
assign y5 = out_comp_ready ? mul2[14:0] : 'b0;
assign y6 = out_comp_ready ? mul3[14:0] : 'b0;
assign y7 = out_comp_ready ? mul4[14:0] : 'b0;
        
assign y4_relu = y4[14] ? 0 : y4;
assign y5_relu = y5[14] ? 0 : y5;
assign y6_relu = y6[14] ? 0 : y6;
assign y7_relu = y7[14] ? 0 : y7;

always_latch begin
	if (out0_ready) begin
		out0 <= mul1;
	end
end

always_latch begin
	if (out1_ready) begin
		out1 <= mul2;
	end
end

endmodule
