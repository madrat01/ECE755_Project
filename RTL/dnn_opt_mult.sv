module dnn_opt_mult (
    input logic                 clk, 
    input logic signed [4:0]    x0, x1, x2, x3, w04, w05, w06, w07, w14, w15, w16, w17, w24, w25, w26, w27, w34, w35, w36, w37, w48, w58, w49, w59, w68, w69, w78, w79,
    input logic                 in_ready, 
    output logic signed [16:0]  out0, out1, 
    output logic                out0_ready, out1_ready
);

typedef enum logic [1:0] {LAYER1_y4y5_MUL, LAYER1_y6y7_MUL, LAYER1_FINAL_ADD, OUTPUT_MUL} dnn_state_t;

logic signed [11:0] y4_p2, y5_p2;
logic signed [11:0] y4_p3, y5_p3, y6_p3, y7_p3;
logic signed [11:0] y4_relu_p4, y5_relu_p4, y6_relu_p4, y7_relu_p4;

logic signed [4:0]  x0_p2, x1_p2, x2_p2, x3_p2, w06_p2, w07_p2, w16_p2, w17_p2, w26_p2, w27_p2, w36_p2, w37_p2, w48_p2, w58_p2, w49_p2, w59_p2, w68_p2, w69_p2, w78_p2, w79_p2;
logic signed [4:0]  w48_p3, w58_p3, w49_p3, w59_p3, w68_p3, w69_p3, w78_p3, w79_p3;
logic signed [4:0]  w48_p4, w58_p4, w49_p4, w59_p4, w68_p4, w69_p4, w78_p4, w79_p4;

logic signed [11:0] multiplicand1, multiplicand2, multiplicand3, multiplicand4;
logic signed [4:0]  multiplier1, multiplier2, multiplier3, multiplier4, multiplier5, multiplier6, multiplier7, multiplier8;
logic signed [16:0] mul1_out, mul2_out, mul3_out, mul4_out, mul5_out, mul6_out, mul7_out, mul8_out;

logic signed [16:0] mac1, mac2;

logic               out_comp_ready_p5;

dnn_state_t         dnn_state;
    
logic signed [16:0]  out0_dly, out1_dly; 
logic                out0_ready_dly, out1_ready_dly;

// FSM
always_ff @ (posedge clk) begin
    case (dnn_state)
        LAYER1_y4y5_MUL     : dnn_state <= in_ready ? LAYER1_y6y7_MUL : dnn_state;
        LAYER1_y6y7_MUL     : dnn_state <= LAYER1_FINAL_ADD;
        LAYER1_FINAL_ADD    : dnn_state <= OUTPUT_MUL;
        OUTPUT_MUL          : dnn_state <= LAYER1_y4y5_MUL;
        default             : dnn_state <= LAYER1_y4y5_MUL;
    endcase
end

// Assign multiplicand and multiplier based on current state
assign multiplicand1 = dnn_state == LAYER1_y6y7_MUL ? {{7{x0_p2[4]}}, x0_p2} : // Layer-1 y6, y7
                       dnn_state == OUTPUT_MUL      ? y4_relu_p4             : // Output calc y
                                                      {{7{x0[4]}}, x0};        // Layer-1 y4, y5

assign multiplicand2 = dnn_state == LAYER1_y6y7_MUL ? {{7{x1_p2[4]}}, x1_p2} :  // Layer-1 y6, y7
                       dnn_state == OUTPUT_MUL      ? y5_relu_p4             :  // Output y5
                                                      {{7{x1[4]}}, x1};         // Layer-1 y4, y5

assign multiplicand3 = dnn_state == LAYER1_y6y7_MUL ? {{7{x2_p2[4]}}, x2_p2} :  // Layer-1 y6, y7
                       dnn_state == OUTPUT_MUL      ? y6_relu_p4             :  // Output y6
                                                      {{7{x2[4]}}, x2};         // Layer-1 y4, y5

assign multiplicand4 = dnn_state == LAYER1_y6y7_MUL ? {{7{x3_p2[4]}}, x3_p2} :  // Layer-1 y6, y7
                       dnn_state == OUTPUT_MUL      ? y7_relu_p4             :  // Output y7
                                                      {{7{x3[4]}}, x3};         // Layer-1 y4, y5

assign multiplier1   = dnn_state == LAYER1_y6y7_MUL ? w06_p2 :  // Layer-1 y6 x0*w06
                       dnn_state == OUTPUT_MUL      ? w48_p4 :  // Output out0 y4*w48
                                                      w04;      // Layer-1 y4 x0*w04

assign multiplier2   = dnn_state == LAYER1_y6y7_MUL ? w16_p2 :  // Layer-1 y6 x1*w16
                       dnn_state == OUTPUT_MUL      ? w58_p4 :  // Output out0 y5*w58
                                                      w14;      // Layer-1 y4 x1*w14

assign multiplier3   = dnn_state == LAYER1_y6y7_MUL ? w26_p2 :  // Layer-1 y6 x2*w26
                       dnn_state == OUTPUT_MUL      ? w68_p4 :  // Output out0 y6*w68
                                                      w24;      // Layer-1 y4 x2*w24

assign multiplier4   = dnn_state == LAYER1_y6y7_MUL ? w36_p2 :  // Layer-1 y6 x3*w36
                       dnn_state == OUTPUT_MUL      ? w78_p4 :  // Output out0 y7*w78
                                                      w34;      // Layer-1 y4 x3*w34

assign multiplier5   = dnn_state == LAYER1_y6y7_MUL ? w07_p2 :  // Layer-1 y7 x0*w07
                       dnn_state == OUTPUT_MUL      ? w49_p4 :  // Output out0 y4*w48
                                                      w05;      // Layer-1 y5 x0*w05

assign multiplier6   = dnn_state == LAYER1_y6y7_MUL ? w17_p2 :  // Layer-1 y7 x1*w17
                       dnn_state == OUTPUT_MUL      ? w59_p4 :  // Output out0 y5*w58
                                                      w15;      // Layer-1 y5 x1*w15

assign multiplier7   = dnn_state == LAYER1_y6y7_MUL ? w27_p2 :  // Layer-1 y7 x2*w27
                       dnn_state == OUTPUT_MUL      ? w69_p4 :  // Output out0 y6*w68
                                                      w25;      // Layer-1 y5 x2*w25

assign multiplier8   = dnn_state == LAYER1_y6y7_MUL ? w37_p2 :  // Layer-1 y7 x3*w37
                       dnn_state == OUTPUT_MUL      ? w79_p4 :  // Output out0 y7*w78
                                                      w35;      // Layer-1 y5 x3*w35

// Flop these multiplication outputs to be added in the next cycle
always_ff @(posedge clk) begin
    // y4, y5, out0
    mul1_out <= multiplicand1 * multiplier1;
    mul2_out <= multiplicand2 * multiplier2;
    mul3_out <= multiplicand3 * multiplier3;
    mul4_out <= multiplicand4 * multiplier4;
    // y6, y7, out1
    mul5_out <= multiplicand1 * multiplier5;
    mul6_out <= multiplicand2 * multiplier6;
    mul7_out <= multiplicand3 * multiplier7;
    mul8_out <= multiplicand4 * multiplier8;
end

// MAC for the 8 multiplications done, single node has 4 mults
assign mac1 = mul1_out + mul2_out + mul3_out + mul4_out;
assign mac2 = mul5_out + mul6_out + mul7_out + mul8_out;

// Assign y5, y5, y6, y7 based on the current state
// LAYER1_y6y7_MUL -> y4, y5 MAC has been done
// LAYER1_FINAL_ADD -> y6, y7 MAC has been done
// LAYER1_FINAL_ADD -> y6, y7 MAC has been done
assign y4_p2 = dnn_state == LAYER1_y6y7_MUL ? mac1 : 17'b0;
assign y5_p2 = dnn_state == LAYER1_y6y7_MUL ? mac2 : 17'b0;
assign y6_p3 = dnn_state == LAYER1_FINAL_ADD ? mac1 : 17'b0;
assign y7_p3 = dnn_state == LAYER1_FINAL_ADD ? mac2 : 17'b0;

// y4 y5 outputs to p3 to ReLu
always_ff @(posedge clk) begin
    y4_p3 <= y4_p2;
    y5_p3 <= y5_p2;
end

// ReLu(x) = max (0, x)
always_ff @(posedge clk) begin
    y4_relu_p4 <= ~{12{y4_p3[11]}} & y4_p3;
    y5_relu_p4 <= ~{12{y5_p3[11]}} & y5_p3;
    y6_relu_p4 <= ~{12{y6_p3[11]}} & y6_p3;
    y7_relu_p4 <= ~{12{y7_p3[11]}} & y7_p3;
end 

// Flop x inputs to calculate y6 and y7 in cycle 2
always_ff @ (posedge clk) begin
    x0_p2 <= x0;
    x1_p2 <= x1;
    x2_p2 <= x2;
    x3_p2 <= x3;
end

// Weights for y6 and y7 flopped, y6 y7 calculated in pipeline stage 2
always_ff @ (posedge clk) begin
    w06_p2 <= w06;
    w16_p2 <= w16;
    w26_p2 <= w26;
    w36_p2 <= w36;
    w07_p2 <= w07;
    w17_p2 <= w17;
    w27_p2 <= w27;
    w37_p2 <= w37;
end

// Flop output calculation weights to multiply in the cycle 4 (after layer-1 additions are done in cycle 3)
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

always_ff @ (posedge clk) begin
    w48_p3 <= w48_p2;
    w58_p3 <= w58_p2;
    w49_p3 <= w49_p2;
    w59_p3 <= w59_p2;
    w68_p3 <= w68_p2;
    w69_p3 <= w69_p2;
    w78_p3 <= w78_p2;
    w79_p3 <= w79_p2;
end

always_ff @ (posedge clk) begin
    w48_p4 <= w48_p3;
    w58_p4 <= w58_p3;
    w49_p4 <= w49_p3;
    w59_p4 <= w59_p3;
    w68_p4 <= w68_p3;
    w69_p4 <= w69_p3;
    w78_p4 <= w78_p3;
    w79_p4 <= w79_p3;
end

// Output completes in the next cycle
always_ff @ (posedge clk) begin
    out_comp_ready_p5 <= dnn_state == OUTPUT_MUL;
end

// Assign out and out_ready when output MAC is completed (cycle 5)
assign out0 = {17{out_comp_ready_p5}} & mac1;
assign out1 = {17{out_comp_ready_p5}} & mac2;
assign out0_ready = out_comp_ready_p5;
assign out1_ready = out_comp_ready_p5; 

endmodule