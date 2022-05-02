module dnn 
import defines_pkg::*;
(
    input logic                 clk, 
    input logic                 rst_n,
    input logic signed [6:0]    x0, x1, x2, x3, 
    input logic signed [4:0]    w04, w05, w06, w07, w14, w15, w16, w17, w24, w25, w26, w27, w34, w35, w36, w37, w48, w58, w49, w59, w68, w69, w78, w79,
    input logic                 in_ready,
    input logic signed [14:0]   y4_n0_aggr, y5_n0_aggr, y6_n0_aggr, y7_n0_aggr, 
    input logic signed [14:0]   y4_n1_aggr, y5_n1_aggr, y6_n1_aggr, y7_n1_aggr, 
    input dnn_state_t           dnn_state, 

    output logic signed [12:0]  y4_relu, y5_relu, y6_relu, y7_relu, 
    output logic signed [20:0]  out0_n0, out1_n0, 
    output logic signed [20:0]  out0_n1, out1_n1, 
    output logic                out0_n0_ready, out1_n0_ready,
    output logic                out0_n1_ready, out1_n1_ready
);

logic signed [14:0] y4, y5, y6, y7;
logic signed [20:0]	mul1, mul2, mul3, mul4;
logic               out_comp_ready;
logic               out0_ready, out1_ready;

assign out0_n0_ready = out0_ready;
assign out0_n1_ready = out0_ready;
assign out1_n0_ready = out1_ready;
assign out1_n1_ready = out1_ready;

// Layer-1 calculations
// Uses 16 5*5 multipliers and 12 12-bit adders
always_ff @ (posedge clk, negedge rst_n) begin
	if (~rst_n) begin
	    out_comp_ready <= 1'b0;
		out0_ready <= 1'b0;
		out1_ready <= 1'b0;
	end
    else begin
		if (dnn_state != FINAL_OUT) begin
            mul1 <= x0*w04 + x1*w14 + x2*w24 + x3*w34;
            mul2 <= x0*w05 + x1*w15 + x2*w25 + x3*w35;
            mul3 <= x0*w06 + x1*w16 + x2*w26 + x3*w36;
            mul4 <= x0*w07 + x1*w17 + x2*w27 + x3*w37;
            out_comp_ready <= 1'b1;
		    out0_ready <= 1'b0;
		    out1_ready <= 1'b0;
		end else begin
		    mul1 <= y4_n0_aggr*w48 + y5_n0_aggr*w58 + y6_n0_aggr*w68 + y7_n0_aggr*w78;
		    mul2 <= y4_n0_aggr*w49 + y5_n0_aggr*w59 + y6_n0_aggr*w69 + y7_n0_aggr*w79;
		    mul3 <= y4_n1_aggr*w48 + y5_n1_aggr*w58 + y6_n1_aggr*w68 + y7_n1_aggr*w78;
		    mul4 <= y4_n1_aggr*w49 + y5_n1_aggr*w59 + y6_n1_aggr*w69 + y7_n1_aggr*w79;
		    out0_ready <= 1'b1;
		    out1_ready <= 1'b1;
		    out_comp_ready <= 1'b0;
		end
	end
end

assign y4 = out_comp_ready ? mul1[12:0] : 'b0;
assign y5 = out_comp_ready ? mul2[12:0] : 'b0;
assign y6 = out_comp_ready ? mul3[12:0] : 'b0;
assign y7 = out_comp_ready ? mul4[12:0] : 'b0;
        
assign y4_relu = y4[12] ? 0 : {1'b0, y4[11:0]};
assign y5_relu = y5[12] ? 0 : {1'b0, y5[11:0]};
assign y6_relu = y6[12] ? 0 : {1'b0, y6[11:0]};
assign y7_relu = y7[12] ? 0 : {1'b0, y7[11:0]};

always_latch begin
	if (out0_ready) begin
		out0_n0 <= mul1;
	end
end

always_latch begin
	if (out1_ready) begin
		out1_n0 <= mul2;
	end
end

always_latch begin
	if (out0_ready) begin
		out0_n1 <= mul3;
	end
end

always_latch begin
	if (out1_ready) begin
		out1_n1 <= mul4;
    end
end

endmodule
