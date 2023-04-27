module memory # (parameter SIZE = 1024, parameter WORD = 32)
            (input clk, we,
            input [31:0] address,
            input [WORD - 1:0] w_data,
            output [WORD - 1:0] r_data);
    reg [WORD - 1:0] storage[SIZE] /*verilator public*/;
    wire [31:2] /* verilator lint_off WIDTHTRUNC */ aligned = address[31:2];
    assign r_data = storage[aligned];
    always @(posedge clk) 
    begin
        if (we) begin
            storage[aligned][WORD - 1:0] <= w_data[WORD - 1:0];
        end
    end
endmodule