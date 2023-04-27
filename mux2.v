module mux2 # (parameter WIDTH = 8)
        (input [WIDTH - 1:0] f, t,
        input cond,
        output reg [WIDTH -1:0] y);
    assign y = cond ? t : f;
endmodule