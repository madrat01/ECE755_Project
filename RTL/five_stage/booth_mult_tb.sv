module booth_mult_tb ();

logic clk, rst_n;
logic mult_en;
logic signed [14:0]    multiplicand;
logic signed [4:0]     multiplier;

logic                  mult_out_valid;
logic signed [18:0]    mult_out;

booth_mult bm (.*);

initial begin
    clk = 1'b0;
end

always begin
    #10 clk = ~clk;
end

initial begin
    rst_n = 0;
    @ (posedge clk);
    @ (negedge clk);
    rst_n = 1;
    multiplier = -16;
    multiplicand = 9216;
    mult_en = 1;
    @ (negedge clk);
    mult_en = 0;
    @ (posedge clk);
    @ (negedge clk);
    $display("mult_out %d mult_out_valid %h multiplier = %d multiplicand = %d", mult_out, mult_out_valid, multiplier , multiplicand);
    //`for (int i = 0; i > -17; i--) begin
    //`    for (int j = 0; j > -17; j--) begin
    //`        multiplier = i;
    //`        multiplicand = j;
    //`        mult_en = 1;
    //`        @ (negedge clk);
    //`        mult_en = 0;
    //`        @ (posedge clk);
    //`        @ (negedge clk);
    //`        if (mult_out !== i*j)
    //`            $display("WRONG mult_out %d mult_out_valid %h i = %d j = %d", mult_out, mult_out_valid, i , j);
    //`    end
    //`end
    @ (posedge clk);
    $stop();
end

endmodule