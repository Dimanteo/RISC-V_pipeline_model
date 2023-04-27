module regfile(input clk, 
               input logic WE3,
               input [4:0] A1, A2, A3,
               input [31:0] WD3,
               output [31:0] RD1, RD2);
    reg [31:0] regs[31:0] /*verilator public*/;
    always @(posedge clk)
    begin
        if (WE3) regs[A3] <= WD3;
    end
    assign RD1 = (A1 != 0) ? regs[A1] : 0;
    assign RD2 = (A2 != 0) ? regs[A2] : 0;
endmodule