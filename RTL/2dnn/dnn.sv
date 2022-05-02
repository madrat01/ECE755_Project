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

logic signed [14:0] multiplicand1, multiplicand2, multiplicand3, multiplicand4, multiplicand5, multiplicand6, multiplicand7, multiplicand8;
logic signed [4:0]  multiplier1, multiplier2, multiplier3, multiplier4, multiplier5, multiplier6, multiplier7, multiplier8;
logic signed [4:0]  multiplier9, multiplier10, multiplier11, multiplier12, multiplier13, multiplier14, multiplier15, multiplier16;

// Assign multiplicand and multiplier based on current state
assign multiplicand1 = dnn_state == FINAL_OUT       ? y4_n0_aggr             : // Output calc y
                                                      {{8{x0[6]}}, x0};        // Layer-1 y4, y5

assign multiplicand2 = dnn_state == FINAL_OUT       ? y5_n0_aggr             :  // Output y5
                                                      {{8{x1[6]}}, x1};         // Layer-1 y4, y5

assign multiplicand3 = dnn_state == FINAL_OUT       ? y6_n0_aggr             :  // Output y6
                                                      {{8{x2[6]}}, x2};         // Layer-1 y4, y5

assign multiplicand4 = dnn_state == FINAL_OUT       ? y7_n0_aggr             :  // Output y7
                                                      {{8{x3[6]}}, x3};         // Layer-1 y4, y5

assign multiplicand5 = dnn_state == FINAL_OUT       ? y4_n1_aggr             : // Output calc y
                                                      {{8{x0[6]}}, x0};        // Layer-1 y4, y5

assign multiplicand6 = dnn_state == FINAL_OUT       ? y5_n1_aggr             :  // Output y5
                                                      {{8{x1[6]}}, x1};         // Layer-1 y4, y5

assign multiplicand7 = dnn_state == FINAL_OUT       ? y6_n1_aggr             :  // Output y6
                                                      {{8{x2[6]}}, x2};         // Layer-1 y4, y5

assign multiplicand8 = dnn_state == FINAL_OUT       ? y7_n1_aggr             :  // Output y7
                                                      {{8{x3[6]}}, x3};         // Layer-1 y4, y5

assign multiplier1   = dnn_state == FINAL_OUT       ? w48 :  // Layer-1 y6 x0*w06
                                                      w04;      // Layer-1 y4 x0*w04

assign multiplier2   = dnn_state == FINAL_OUT       ? w58 :  // Output out0 y5*w58
                                                      w14;      // Layer-1 y4 x1*w14

assign multiplier3   = dnn_state == FINAL_OUT       ? w68 :  // Output out0 y6*w68
                                                      w24;      // Layer-1 y4 x2*w24

assign multiplier4   = dnn_state == FINAL_OUT       ? w78 :  // Output out0 y7*w78
                                                      w34;      // Layer-1 y4 x3*w34

assign multiplier5   = dnn_state == FINAL_OUT       ? w49 :  // Output out0 y4*w48
                                                      w05;      // Layer-1 y5 x0*w05

assign multiplier6   = dnn_state == FINAL_OUT       ? w59 :  // Output out0 y5*w58
                                                      w15;      // Layer-1 y5 x1*w15

assign multiplier7   = dnn_state == FINAL_OUT       ? w69 :  // Output out0 y6*w68
                                                      w25;      // Layer-1 y5 x2*w25

assign multiplier8   = dnn_state == FINAL_OUT       ? w79 :  // Output out0 y6*w68
                                                      w35;      // Layer-1 y5 x2*w25

assign multiplier9   = dnn_state == FINAL_OUT       ? w48 :  // Layer-1 y6 x0*w06
                                                      w06;      // Layer-1 y4 x0*w04

assign multiplier10  = dnn_state == FINAL_OUT       ? w58 :  // Output out0 y5*w58
                                                      w16;      // Layer-1 y4 x1*w14

assign multiplier11  = dnn_state == FINAL_OUT       ? w68 :  // Output out0 y6*w68
                                                      w26;      // Layer-1 y4 x2*w24

assign multiplier12  = dnn_state == FINAL_OUT       ? w78 :  // Output out0 y7*w78
                                                      w36;      // Layer-1 y4 x3*w34

assign multiplier13  = dnn_state == FINAL_OUT       ? w49 :  // Output out0 y4*w48
                                                      w07;      // Layer-1 y5 x0*w05

assign multiplier14  = dnn_state == FINAL_OUT       ? w59 :  // Output out0 y5*w58
                                                      w17;      // Layer-1 y5 x1*w15

assign multiplier15  = dnn_state == FINAL_OUT       ? w69 :  // Output out0 y6*w68
                                                      w27;      // Layer-1 y5 x2*w25

assign multiplier16  = dnn_state == FINAL_OUT       ? w79 :  // Output out0 y6*w68
                                                      w37;      // Layer-1 y5 x2*w25


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
            out_comp_ready <= 1'b1;
		    out0_ready <= 1'b0;
		    out1_ready <= 1'b0;
		end else begin
		    out0_ready <= 1'b1;
		    out1_ready <= 1'b1;
		    out_comp_ready <= 1'b0;
		end
	end
end

always_ff @ (posedge clk) begin
    // y4, y5, out0
    mul1 <= multiplicand1 * multiplier1 + multiplicand2 * multiplier2 + multiplicand3 * multiplier3 + multiplicand4 * multiplier4;
    mul2 <= multiplicand1 * multiplier5 + multiplicand2 * multiplier6 + multiplicand3 * multiplier7 + multiplicand4 * multiplier8;
    
    mul3 <= multiplicand5 * multiplier9 + multiplicand6 * multiplier10 + multiplicand7 * multiplier11 + multiplicand8 * multiplier12;
    mul4 <= multiplicand5 * multiplier13 + multiplicand6 * multiplier14 + multiplicand7 * multiplier15 + multiplicand8 * multiplier16;
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
