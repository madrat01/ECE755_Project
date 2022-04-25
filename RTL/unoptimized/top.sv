module top (
    input logic                 clk,
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
    output logic                out0_ready_node0, out1_ready_node0, 
    output logic                out0_ready_node1, out1_ready_node1, 
    output logic                out0_ready_node2, out1_ready_node2, 
    output logic                out0_ready_node3, out1_ready_node3
); 

//      Node 0
//     /      \
// Node 1    Node 2
//     \      /
//      Node 3

logic signed [6:0]  x0_node0_aggr, x1_node0_aggr, x2_node0_aggr, x3_node0_aggr;
logic signed [6:0]  x0_node1_aggr, x1_node1_aggr, x2_node1_aggr, x3_node1_aggr;
logic signed [6:0]  x0_node2_aggr, x1_node2_aggr, x2_node2_aggr, x3_node2_aggr;
logic signed [6:0]  x0_node3_aggr, x1_node3_aggr, x2_node3_aggr, x3_node3_aggr;
    
logic signed [16:0]  y4_node0_aggr, y5_node0_aggr, y6_node0_aggr, y7_node0_aggr; 
logic signed [14:0]  y4_node0, y5_node0, y6_node0, y7_node0;
logic signed [16:0]  y4_node1_aggr, y5_node1_aggr, y6_node1_aggr, y7_node1_aggr; 
logic signed [14:0]  y4_node1, y5_node1, y6_node1, y7_node1;
logic signed [16:0]  y4_node2_aggr, y5_node2_aggr, y6_node2_aggr, y7_node2_aggr; 
logic signed [14:0]  y4_node2, y5_node2, y6_node2, y7_node2;
logic signed [16:0]  y4_node3_aggr, y5_node3_aggr, y6_node3_aggr, y7_node3_aggr; 
logic signed [14:0]  y4_node3, y5_node3, y6_node3, y7_node3;

// Aggregated i/p features
// Aggregate x_inputs

assign  x0_node0_aggr = x0_node0 + x0_node1 + x0_node2;
assign  x1_node0_aggr = x1_node0 + x1_node1 + x1_node2;
assign  x2_node0_aggr = x2_node0 + x2_node1 + x2_node2;
assign  x3_node0_aggr = x3_node0 + x3_node1 + x3_node2;

assign  x0_node1_aggr = x0_node0 + x0_node1 + x0_node3;
assign  x1_node1_aggr = x1_node0 + x1_node1 + x1_node3;
assign  x2_node1_aggr = x2_node0 + x2_node1 + x2_node3;
assign  x3_node1_aggr = x3_node0 + x3_node1 + x3_node3;

assign  x0_node2_aggr = x0_node0 + x0_node2 + x0_node3;
assign  x1_node2_aggr = x1_node0 + x1_node2 + x1_node3;
assign  x2_node2_aggr = x2_node0 + x2_node2 + x2_node3;
assign  x3_node2_aggr = x3_node0 + x3_node2 + x3_node3;

assign  x0_node3_aggr = x0_node1 + x0_node2 + x0_node3;
assign  x1_node3_aggr = x1_node1 + x1_node2 + x1_node3;
assign  x2_node3_aggr = x2_node1 + x2_node2 + x2_node3;
assign  x3_node3_aggr = x3_node1 + x3_node2 + x3_node3;

// Aggregate layer-1 outputs
assign  y4_node0_aggr = y4_node0 + y4_node1 + y4_node2;
assign  y5_node0_aggr = y5_node0 + y5_node1 + y5_node2;
assign  y6_node0_aggr = y6_node0 + y6_node1 + y6_node2;
assign  y7_node0_aggr = y7_node0 + y7_node1 + y7_node2;

assign  y4_node1_aggr = y4_node0 + y4_node1 + y4_node3;
assign  y5_node1_aggr = y5_node0 + y5_node1 + y5_node3;
assign  y6_node1_aggr = y6_node0 + y6_node1 + y6_node3;
assign  y7_node1_aggr = y7_node0 + y7_node1 + y7_node3;

assign  y4_node2_aggr = y4_node0 + y4_node2 + y4_node3;
assign  y5_node2_aggr = y5_node0 + y5_node2 + y5_node3;
assign  y6_node2_aggr = y6_node0 + y6_node2 + y6_node3;
assign  y7_node2_aggr = y7_node0 + y7_node2 + y7_node3;

assign  y4_node3_aggr = y4_node1 + y4_node2 + y4_node3;
assign  y5_node3_aggr = y5_node1 + y5_node2 + y5_node3;
assign  y6_node3_aggr = y6_node1 + y6_node2 + y6_node3;
assign  y7_node3_aggr = y7_node1 + y7_node2 + y7_node3;

dnn node0 (
    .clk            (clk),
    .in_ready       (in_ready),
    .x0(x0_node0_aggr), .x1(x1_node0_aggr), .x2(x2_node0_aggr), .x3(x3_node0_aggr), 
    .w04(w04), .w14(w14), .w24(w24), .w34(w34), 
    .w05(w05), .w15(w15), .w25(w25), .w35(w35),
    .w06(w06), .w16(w16), .w26(w26), .w36(w36),
    .w07(w07), .w17(w17), .w27(w27), .w37(w37),
    .w48(w48), .w58(w58), .w68(w68), .w78(w78),
    .w49(w49), .w59(w59), .w69(w69), .w79(w79),
    .y4_aggr (y4_node0_aggr), .y5_aggr (y5_node0_aggr), .y6_aggr (y6_node0_aggr), .y7_aggr (y7_node0_aggr),
    .y4_relu (y4_node0), .y5_relu (y5_node0), .y6_relu (y6_node0), .y7_relu (y7_node0),
    .out0(out0_node0), .out1(out1_node0),
    .out0_ready(out0_ready_node0), .out1_ready(out1_ready_node0)
);

dnn node1 (
    .clk            (clk),
    .in_ready       (in_ready),
    .x0(x0_node1_aggr), .x1(x1_node1_aggr), .x2(x2_node1_aggr), .x3(x3_node1_aggr), 
    .w04(w04), .w14(w14), .w24(w24), .w34(w34), 
    .w05(w05), .w15(w15), .w25(w25), .w35(w35),
    .w06(w06), .w16(w16), .w26(w26), .w36(w36),
    .w07(w07), .w17(w17), .w27(w27), .w37(w37),
    .w48(w48), .w58(w58), .w68(w68), .w78(w78),
    .w49(w49), .w59(w59), .w69(w69), .w79(w79),
    .y4_aggr (y4_node1_aggr), .y5_aggr (y5_node1_aggr), .y6_aggr (y6_node1_aggr), .y7_aggr (y7_node1_aggr),
    .y4_relu (y4_node1), .y5_relu (y5_node1), .y6_relu (y6_node1), .y7_relu (y7_node1),
    .out0(out0_node1), .out1(out1_node1),
    .out0_ready(out0_ready_node1), .out1_ready(out1_ready_node1)
);

dnn node2 (
    .clk            (clk),
    .in_ready       (in_ready),
    .x0(x0_node2_aggr), .x1(x1_node2_aggr), .x2(x2_node2_aggr), .x3(x3_node2_aggr), 
    .w04(w04), .w14(w14), .w24(w24), .w34(w34), 
    .w05(w05), .w15(w15), .w25(w25), .w35(w35),
    .w06(w06), .w16(w16), .w26(w26), .w36(w36),
    .w07(w07), .w17(w17), .w27(w27), .w37(w37),
    .w48(w48), .w58(w58), .w68(w68), .w78(w78),
    .w49(w49), .w59(w59), .w69(w69), .w79(w79),
    .y4_aggr (y4_node2_aggr), .y5_aggr (y5_node2_aggr), .y6_aggr (y6_node2_aggr), .y7_aggr (y7_node2_aggr),
    .y4_relu (y4_node2), .y5_relu (y5_node2), .y6_relu (y6_node2), .y7_relu (y7_node2),
    .out0(out0_node2), .out1(out1_node2),
    .out0_ready(out0_ready_node2), .out1_ready(out1_ready_node2)
);

dnn node3 (
    .clk            (clk),
    .in_ready       (in_ready),
    .x0(x0_node3_aggr), .x1(x1_node3_aggr), .x2(x2_node3_aggr), .x3(x3_node3_aggr), 
    .w04(w04), .w14(w14), .w24(w24), .w34(w34), 
    .w05(w05), .w15(w15), .w25(w25), .w35(w35),
    .w06(w06), .w16(w16), .w26(w26), .w36(w36),
    .w07(w07), .w17(w17), .w27(w27), .w37(w37),
    .w48(w48), .w58(w58), .w68(w68), .w78(w78),
    .w49(w49), .w59(w59), .w69(w69), .w79(w79),
    .y4_aggr (y4_node3_aggr), .y5_aggr (y5_node3_aggr), .y6_aggr (y6_node3_aggr), .y7_aggr (y7_node3_aggr),
    .y4_relu (y4_node3), .y5_relu (y5_node3), .y6_relu (y6_node3), .y7_relu (y7_node3),
    .out0(out0_node3), .out1(out1_node3),
    .out0_ready(out0_ready_node3), .out1_ready(out1_ready_node3)
);

endmodule