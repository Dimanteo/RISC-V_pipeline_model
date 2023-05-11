module PCreg(input clk, reset, en, input[31:0] in, output [31:0] out);
    reg [31:0] pc /*verilator public*/;
    assign out = pc;
    always @(posedge clk) begin
        if (!reset && en) pc <= in;
        else if (reset) pc <= 0;
    end
endmodule