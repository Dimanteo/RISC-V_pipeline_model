module sl2(input [31:0] x, output [31:0] y);
    assign y = {x[29:0], 2'b00};
endmodule