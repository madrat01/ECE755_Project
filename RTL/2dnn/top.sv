module top 
import defines_pkg::*;
(
    input logic                 clk,
    input logic                 rst_n,
    input logic signed [4:0]    x0_node0, x1_node0, x2_node0, x3_node0, 
    input logic signed [4:0]    x0_node1, x1_node1, x2_node1, x3_node1, 
    input logic signed [4:0]    x0_node2, x1_node2, x2_node2, x3_node2, 
    input logic signed [4:0]    x0_node3, x1_node3, x2_node3, x3_node3,
    input logic signed [4:0]    w04, w14, w24, w34,
    input logic signed [4:0]    w05, w15, w25, w35,
    input logic signed [4:0]    w06, w16, w26, w36,
    input logic signed [4:0]    w07, w17, w27, w37,
    input logic signed [4:0]    w48, w58, w68, w78,
    input logic signed [4:0]    w49, w59, w69, w79,
    input logic                 in_ready,
    output logic signed [20:0]  out0_node0, out1_node0,
    output logic signed [20:0]  out0_node1, out1_node1,
    output logic signed [20:0]  out0_node2, out1_node2,
    output logic signed [20:0]  out0_node3, out1_node3,
    output logic                out10_ready_node0, out11_ready_node0, 
    output logic                out10_ready_node1, out11_ready_node1, 
    output logic                out10_ready_node2, out11_ready_node2, 
    output logic                out10_ready_node3, out11_ready_node3
); 

//      Node 0
//     /      \
// Node 1    Node 2
//     \      /
//      Node 3

// | -------------- P1 --------------- | ------------- P2 ---------------- | ------------- P3 -----------  | ------- P4 ------ |
// | - X aggregate for all DNNs        | - X aggr inputs for DNN2 and DNN3 | - Y outputs for DNN2 and DNN3 | - Final outputs   |
// | - X aggr inputs for DNN0 and DNN1 | - Y outputs for DNN0 and DNN1 are |   are available               |                   |
// |                                   |   available                       | - Y aggregate for all DNNs    |                   |
// |                                   |                                   | - Y aggr inputs for all DNNs  |                   |
// Output latency = 3 cycles.
// E.g. Input in_ready can rise in the negedge of clk 0. Output ready at negedge of clk 3.

// FSM
// DNN0_DNN1_Y_OUT = p1 & p4 = DNN0, DNN1 Y output in next cycle
// DNN1_DNN2_Y_OUT = p2 = DNN2, DNN3 Y output in next cycle
// FINAL_OUT       = p3 = Final output multiplication, output in next cyle (output coincides with DNN0_DNN1_Y_OUT)

logic signed [6:0]  x0_node0_aggr_p1, x1_node0_aggr_p1, x2_node0_aggr_p1, x3_node0_aggr_p1;
logic signed [6:0]  x0_node1_aggr_p1, x1_node1_aggr_p1, x2_node1_aggr_p1, x3_node1_aggr_p1;
logic signed [6:0]  x0_node2_aggr_p1, x1_node2_aggr_p1, x2_node2_aggr_p1, x3_node2_aggr_p1;
logic signed [6:0]  x0_node3_aggr_p1, x1_node3_aggr_p1, x2_node3_aggr_p1, x3_node3_aggr_p1;
logic signed [6:0]  x0_node2_aggr_p2, x1_node2_aggr_p2, x2_node2_aggr_p2, x3_node2_aggr_p2;
logic signed [6:0]  x0_node3_aggr_p2, x1_node3_aggr_p2, x2_node3_aggr_p2, x3_node3_aggr_p2;

logic signed [6:0]  x0_dnn0_in, x1_dnn0_in, x2_dnn0_in, x3_dnn0_in;
logic signed [6:0]  x0_dnn1_in, x1_dnn1_in, x2_dnn1_in, x3_dnn1_in;
    
logic signed [14:0]  y4_node0_aggr_p3, y5_node0_aggr_p3, y6_node0_aggr_p3, y7_node0_aggr_p3; 
logic signed [12:0]  y4_node0_p3, y5_node0_p3, y6_node0_p3, y7_node0_p3;
logic signed [14:0]  y4_node1_aggr_p3, y5_node1_aggr_p3, y6_node1_aggr_p3, y7_node1_aggr_p3; 
logic signed [12:0]  y4_node1_p3, y5_node1_p3, y6_node1_p3, y7_node1_p3;
logic signed [14:0]  y4_node2_aggr_p3, y5_node2_aggr_p3, y6_node2_aggr_p3, y7_node2_aggr_p3; 
logic signed [12:0]  y4_node2_p3, y5_node2_p3, y6_node2_p3, y7_node2_p3;
logic signed [14:0]  y4_node3_aggr_p3, y5_node3_aggr_p3, y6_node3_aggr_p3, y7_node3_aggr_p3; 
logic signed [12:0]  y4_node3_p3, y5_node3_p3, y6_node3_p3, y7_node3_p3;

logic signed [12:0]  y4_dnn0_out, y5_dnn0_out, y6_dnn0_out, y7_dnn0_out;
logic signed [12:0]  y4_dnn1_out, y5_dnn1_out, y6_dnn1_out, y7_dnn1_out;

dnn_state_t         dnn_state, next_dnn_state;

logic               in_ready_dly, in_ready_rise;

// Determine when in_ready rises, Start GNN calculation only when in_ready rises
always_ff @ (posedge clk, negedge rst_n)
    if (~rst_n)
        in_ready_dly <= 'b0;
    else
        in_ready_dly <= in_ready;

assign in_ready_rise = ~in_ready_dly & in_ready;

// Aggregated i/p features
// Aggregate x_inputs for DNNs
always_comb begin
    x0_node0_aggr_p1 = 0;  
    x1_node0_aggr_p1 = 0;
    x2_node0_aggr_p1 = 0;
    x3_node0_aggr_p1 = 0;
    
    x0_node1_aggr_p1 = 0;
    x1_node1_aggr_p1 = 0;
    x2_node1_aggr_p1 = 0;
    x3_node1_aggr_p1 = 0;
    
    x0_node2_aggr_p1 = 0;
    x1_node2_aggr_p1 = 0;
    x2_node2_aggr_p1 = 0;
    x3_node2_aggr_p1 = 0;
    
    x0_node3_aggr_p1 = 0;
    x1_node3_aggr_p1 = 0;
    x2_node3_aggr_p1 = 0;
    x3_node3_aggr_p1 = 0;
    if (dnn_state == DNN0_DNN1_Y_OUT) begin
        x0_node0_aggr_p1 = x0_node0 + x0_node1 + x0_node2;
        x1_node0_aggr_p1 = x1_node0 + x1_node1 + x1_node2;
        x2_node0_aggr_p1 = x2_node0 + x2_node1 + x2_node2;
        x3_node0_aggr_p1 = x3_node0 + x3_node1 + x3_node2;
        
        x0_node1_aggr_p1 = x0_node0 + x0_node1 + x0_node3;
        x1_node1_aggr_p1 = x1_node0 + x1_node1 + x1_node3;
        x2_node1_aggr_p1 = x2_node0 + x2_node1 + x2_node3;
        x3_node1_aggr_p1 = x3_node0 + x3_node1 + x3_node3;
        
        x0_node2_aggr_p1 = x0_node0 + x0_node2 + x0_node3;
        x1_node2_aggr_p1 = x1_node0 + x1_node2 + x1_node3;
        x2_node2_aggr_p1 = x2_node0 + x2_node2 + x2_node3;
        x3_node2_aggr_p1 = x3_node0 + x3_node2 + x3_node3;
        
        x0_node3_aggr_p1 = x0_node1 + x0_node2 + x0_node3;
        x1_node3_aggr_p1 = x1_node1 + x1_node2 + x1_node3;
        x2_node3_aggr_p1 = x2_node1 + x2_node2 + x2_node3;
        x3_node3_aggr_p1 = x3_node1 + x3_node2 + x3_node3;
    end
end

// DNN2 and DNN3 X_aggr inputs in cycle 2
always_ff @ (posedge clk) begin
    x0_node2_aggr_p2 <= x0_node2_aggr_p1;
    x1_node2_aggr_p2 <= x1_node2_aggr_p1;
    x2_node2_aggr_p2 <= x2_node2_aggr_p1;
    x3_node2_aggr_p2 <= x3_node2_aggr_p1;
    
    x0_node3_aggr_p2 <= x0_node3_aggr_p1;
    x1_node3_aggr_p2 <= x1_node3_aggr_p1;
    x2_node3_aggr_p2 <= x2_node3_aggr_p1;
    x3_node3_aggr_p2 <= x3_node3_aggr_p1;
end

// P1 - X inputs are for DNN0 and DNN1; P2 - X inputs are for DNN2 and DNN3
assign x0_dnn0_in = dnn_state == DNN2_DNN3_Y_OUT ? x0_node2_aggr_p2 : x0_node0_aggr_p1;
assign x1_dnn0_in = dnn_state == DNN2_DNN3_Y_OUT ? x1_node2_aggr_p2 : x1_node0_aggr_p1;
assign x2_dnn0_in = dnn_state == DNN2_DNN3_Y_OUT ? x2_node2_aggr_p2 : x2_node0_aggr_p1;
assign x3_dnn0_in = dnn_state == DNN2_DNN3_Y_OUT ? x3_node2_aggr_p2 : x3_node0_aggr_p1;

assign x0_dnn1_in = dnn_state == DNN2_DNN3_Y_OUT ? x0_node3_aggr_p2 : x0_node1_aggr_p1;
assign x1_dnn1_in = dnn_state == DNN2_DNN3_Y_OUT ? x1_node3_aggr_p2 : x1_node1_aggr_p1;
assign x2_dnn1_in = dnn_state == DNN2_DNN3_Y_OUT ? x2_node3_aggr_p2 : x2_node1_aggr_p1;
assign x3_dnn1_in = dnn_state == DNN2_DNN3_Y_OUT ? x3_node3_aggr_p2 : x3_node1_aggr_p1;

// Aggregate layer-1 outputs
always_comb begin
    y4_node0_aggr_p3 = 0;
    y5_node0_aggr_p3 = 0;
    y6_node0_aggr_p3 = 0;
    y7_node0_aggr_p3 = 0;

    y4_node1_aggr_p3 = 0;
    y5_node1_aggr_p3 = 0;
    y6_node1_aggr_p3 = 0;
    y7_node1_aggr_p3 = 0;

    y4_node2_aggr_p3 = 0;
    y5_node2_aggr_p3 = 0;
    y6_node2_aggr_p3 = 0;
    y7_node2_aggr_p3 = 0;

    y4_node3_aggr_p3 = 0;
    y5_node3_aggr_p3 = 0;
    y6_node3_aggr_p3 = 0;
    y7_node3_aggr_p3 = 0;
    if (dnn_state == FINAL_OUT) begin
        // NOTs to satisfy hold time constraint
        y4_node0_aggr_p3 = ~y4_node0_p3 + ~y4_node1_p3 + y4_dnn0_out; //y4_node2_p3;
        y5_node0_aggr_p3 = ~y5_node0_p3 + ~y5_node1_p3 + y5_dnn0_out; //y5_node2_p3;
        y6_node0_aggr_p3 = ~y6_node0_p3 + ~y6_node1_p3 + y6_dnn0_out; //y6_node2_p3;
        y7_node0_aggr_p3 = ~y7_node0_p3 + ~y7_node1_p3 + y7_dnn0_out; //y7_node2_p3;

        y4_node1_aggr_p3 = ~y4_node0_p3 + ~y4_node1_p3 + y4_dnn1_out; //y4_node3_p3;
        y5_node1_aggr_p3 = ~y5_node0_p3 + ~y5_node1_p3 + y5_dnn1_out; //y5_node3_p3;
        y6_node1_aggr_p3 = ~y6_node0_p3 + ~y6_node1_p3 + y6_dnn1_out; //y6_node3_p3;
        y7_node1_aggr_p3 = ~y7_node0_p3 + ~y7_node1_p3 + y7_dnn1_out; //y7_node3_p3;

        y4_node2_aggr_p3 = ~y4_node0_p3 + y4_dnn0_out + y4_dnn1_out; //y4_node2_p3 + y4_node3_p3;
        y5_node2_aggr_p3 = ~y5_node0_p3 + y5_dnn0_out + y5_dnn1_out; //y5_node2_p3 + y5_node3_p3;
        y6_node2_aggr_p3 = ~y6_node0_p3 + y6_dnn0_out + y6_dnn1_out; //y6_node2_p3 + y6_node3_p3;
        y7_node2_aggr_p3 = ~y7_node0_p3 + y7_dnn0_out + y7_dnn1_out; //y7_node2_p3 + y7_node3_p3;

        y4_node3_aggr_p3 = ~y4_node1_p3 + y4_dnn0_out + y4_dnn1_out; //y4_node2_p3 + y4_node3_p3;
        y5_node3_aggr_p3 = ~y5_node1_p3 + y5_dnn0_out + y5_dnn1_out; //y5_node2_p3 + y5_node3_p3;
        y6_node3_aggr_p3 = ~y6_node1_p3 + y6_dnn0_out + y6_dnn1_out; //y6_node2_p3 + y6_node3_p3;
        y7_node3_aggr_p3 = ~y7_node1_p3 + y7_dnn0_out + y7_dnn1_out; //y7_node2_p3 + y7_node3_p3;
    end
end

// NOTs to satisfy hold time constraint
always_ff @ (posedge clk) begin
    if (dnn_state == DNN2_DNN3_Y_OUT) begin
        y4_node0_p3 <= ~y4_dnn0_out;
        y5_node0_p3 <= ~y5_dnn0_out;
        y6_node0_p3 <= ~y6_dnn0_out;
        y7_node0_p3 <= ~y7_dnn0_out;
        
        y4_node1_p3 <= ~y4_dnn1_out;
        y5_node1_p3 <= ~y5_dnn1_out;
        y6_node1_p3 <= ~y6_dnn1_out;
        y7_node1_p3 <= ~y7_dnn1_out;
    end else begin
        y4_node0_p3 <= 'bx;
        y5_node0_p3 <= 'bx;
        y6_node0_p3 <= 'bx;
        y7_node0_p3 <= 'bx;
    
        y4_node1_p3 <= 'bx;
        y5_node1_p3 <= 'bx;
        y6_node1_p3 <= 'bx;
        y7_node1_p3 <= 'bx;
    end
end

// FSM
always_ff @ (posedge clk, negedge rst_n)
    if (~rst_n)
        dnn_state <= DNN0_DNN1_Y_OUT;
    else
        dnn_state <= next_dnn_state;

always_comb begin
    next_dnn_state = dnn_state;
    case (dnn_state)
        DNN0_DNN1_Y_OUT     : next_dnn_state = in_ready_rise ? DNN2_DNN3_Y_OUT : dnn_state;
        DNN2_DNN3_Y_OUT     : next_dnn_state = FINAL_OUT;
        default             : next_dnn_state = DNN0_DNN1_Y_OUT;
    endcase
end

dnn node0 (
    //Inputs
    .clk            (clk),
    .rst_n          (rst_n),
    .in_ready       (in_ready),
    .x0(x0_dnn0_in), .x1(x1_dnn0_in), .x2(x2_dnn0_in), .x3(x3_dnn0_in), 
    .w04(w04), .w14(w14), .w24(w24), .w34(w34), 
    .w05(w05), .w15(w15), .w25(w25), .w35(w35),
    .w06(w06), .w16(w16), .w26(w26), .w36(w36),
    .w07(w07), .w17(w17), .w27(w27), .w37(w37),
    .w48(w48), .w58(w58), .w68(w68), .w78(w78),
    .w49(w49), .w59(w59), .w69(w69), .w79(w79),
    .y4_n0_aggr(y4_node0_aggr_p3),
    .y5_n0_aggr(y5_node0_aggr_p3),
    .y6_n0_aggr(y6_node0_aggr_p3),
    .y7_n0_aggr(y7_node0_aggr_p3),
    .y4_n1_aggr(y4_node1_aggr_p3),
    .y5_n1_aggr(y5_node1_aggr_p3),
    .y6_n1_aggr(y6_node1_aggr_p3),
    .y7_n1_aggr(y7_node1_aggr_p3),
    .dnn_state (dnn_state),

    // Outputs
    .y4_relu (y4_dnn0_out), .y5_relu (y5_dnn0_out), .y6_relu (y6_dnn0_out), .y7_relu (y7_dnn0_out),
    .out0_n0(out0_node0), .out1_n0(out1_node0),
    .out0_n1(out0_node1), .out1_n1(out1_node1),
    .out0_n0_ready(out10_ready_node0), .out1_n0_ready(out11_ready_node0),
    .out0_n1_ready(out10_ready_node1), .out1_n1_ready(out11_ready_node1)
);

dnn node1 (
    //Inputs
    .clk            (clk),
    .rst_n          (rst_n),
    .in_ready       (in_ready),
    .x0(x0_dnn1_in), .x1(x1_dnn1_in), .x2(x2_dnn1_in), .x3(x3_dnn1_in), 
    .w04(w04), .w14(w14), .w24(w24), .w34(w34), 
    .w05(w05), .w15(w15), .w25(w25), .w35(w35),
    .w06(w06), .w16(w16), .w26(w26), .w36(w36),
    .w07(w07), .w17(w17), .w27(w27), .w37(w37),
    .w48(w48), .w58(w58), .w68(w68), .w78(w78),
    .w49(w49), .w59(w59), .w69(w69), .w79(w79),
    .y4_n0_aggr(y4_node2_aggr_p3),
    .y5_n0_aggr(y5_node2_aggr_p3),
    .y6_n0_aggr(y6_node2_aggr_p3),
    .y7_n0_aggr(y7_node2_aggr_p3),
    .y4_n1_aggr(y4_node3_aggr_p3),
    .y5_n1_aggr(y5_node3_aggr_p3),
    .y6_n1_aggr(y6_node3_aggr_p3),
    .y7_n1_aggr(y7_node3_aggr_p3),
    .dnn_state (dnn_state),
    
    // Outputs
    .y4_relu (y4_dnn1_out), .y5_relu (y5_dnn1_out), .y6_relu (y6_dnn1_out), .y7_relu (y7_dnn1_out),
    .out0_n0(out0_node2), .out1_n0(out1_node2),
    .out0_n1(out0_node3), .out1_n1(out1_node3),
    .out0_n0_ready(out10_ready_node2), .out1_n0_ready(out11_ready_node2),
    .out0_n1_ready(out10_ready_node3), .out1_n1_ready(out11_ready_node3)
);

endmodule
