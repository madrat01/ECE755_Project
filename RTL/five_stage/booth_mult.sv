module booth_mult (
    input logic                 clk,
    input logic                 rst_n,
    input logic                 mult_en,
    input logic signed [14:0]   multiplicand,
    input logic signed [4:0]    multiplier,

    output logic                mult_out_valid,
    output logic signed [19:0]  mult_out
);

logic [2:0]         booth_p1, booth_p2, booth_p3;
logic [2:0]         booth_v_p1, booth_v_p2, booth_v_p3;
logic               mult_valid_p1, mult_valid_p2, mult_valid_p3;
logic signed [6:0]  multiplier_booth_p1, multiplier_booth_p2, multiplier_booth_p3;
logic signed [14:0] multiplicand_p1, multiplicand_p2, multiplicand_p3;
logic signed [15:0] pp1, pp2, pp3;
logic signed [17:0] pp2_f;

assign mult_valid_p1 = mult_en;

always_ff @ (posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        mult_valid_p2 <= 1'b0;
        mult_valid_p3 <= 1'b0;
    end else begin
        mult_valid_p2 <= mult_valid_p1;
        mult_valid_p3 <= mult_valid_p2;
    end
end

assign multiplicand_p1 = multiplicand;

always_ff @ (posedge clk) begin
    multiplicand_p2 <= multiplicand_p1;
    multiplicand_p3 <= multiplicand_p2;
end

assign multiplier_booth_p1 = {multiplier[4], multiplier, 1'b0};

always_ff @ (posedge clk) begin
    multiplier_booth_p2 <= multiplier_booth_p1;
    multiplier_booth_p3 <= multiplier_booth_p2;
end

assign booth_p1 = multiplier_booth_p1[2:0];
assign booth_p2 = multiplier_booth_p2[4:2];
assign booth_p3 = multiplier_booth_p3[6:4];

//always_ff @ (posedge clk) begin
//    $display("multiplicand_p1 %b multiplicand_p2 %b multiplicand_p3 %b", multiplicand_p1, multiplicand_p2, multiplicand_p3);
//    $display("multiplier_booth_p1 %b multiplier_booth_p2 %b multiplier_booth_p3 %b", multiplier_booth_p1, multiplier_booth_p2, multiplier_booth_p3);
//    $display("pp1 %b pp2 %b pp3 %b pp2_f %b mult_out %b %h", pp1, pp2, pp3, pp2_f, mult_out, mult_out);
//end

assign booth_v_p1 = booth_p1 & {3{mult_valid_p1}};
assign booth_v_p2 = booth_p2 & {3{mult_valid_p2}};
assign booth_v_p3 = booth_p3 & {3{mult_valid_p3}};

always_ff @ (posedge clk) begin
    case (booth_v_p1)
        3'b001  :  pp1 <= multiplicand; 
        3'b010  :  pp1 <= multiplicand; 
        3'b011  :  pp1 <= multiplicand << 1;
        3'b100  :  pp1 <= -(multiplicand << 1);
        3'b101  :  pp1 <= -multiplicand;
        3'b110  :  pp1 <= -multiplicand;
        default :  pp1 <= 0;
    endcase
end

always_comb begin
    case (booth_v_p2)
        3'b001  :  pp2 = multiplicand_p2; 
        3'b010  :  pp2 = multiplicand_p2; 
        3'b011  :  pp2 = multiplicand_p2 << 1;
        3'b100  :  pp2 = -(multiplicand_p2 << 1);
        3'b101  :  pp2 = -multiplicand_p2;
        3'b110  :  pp2 = -multiplicand_p2;
        default :  pp2 = 0;
    endcase
end

always_ff @ (posedge clk)
    pp2_f <= {pp2, 2'b00} + {{2{pp1[15]}}, pp1};

always_comb begin
    case (booth_v_p3)
        3'b001  :  pp3 = multiplicand_p3; 
        3'b010  :  pp3 = multiplicand_p3; 
        3'b011  :  pp3 = multiplicand_p3 << 1;
        3'b100  :  pp3 = -(multiplicand_p3 << 1);
        3'b101  :  pp3 = -multiplicand_p3;
        3'b110  :  pp3 = -multiplicand_p3;
        default :  pp3 = 0;
    endcase
end

assign mult_out = {pp3, 4'b0000} + {{2{pp2_f[17]}}, pp2_f};

assign mult_out_valid = mult_valid_p3;

endmodule