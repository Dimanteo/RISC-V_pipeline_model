module signext(input [11:0] si, output [31:0] wi);
    assign wi = {{20{si[11]}}, si};
endmodule