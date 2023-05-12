`define WORD_WIDTH 2'b10

module top(input clk, reset,
           output [31:0] dataadr,
           output memWE, validOut);
    wire [31:0] pc, instr /*verilator public*/, readdata, writedata;
    wire [2:0] memcontrol;
    // instantiate processor and memories
    rv32 rv32 (.clk(clk), .reset(reset), .pc(pc),
               .fetchI(instr), .memWE(memWE),
               .memcontrol(memcontrol), .validOut(validOut),
               .aluout(dataadr), .writedata(writedata), .readdata(readdata));
    memory #(1 << 22) imem (.clk(clk), .we(0), .address(pc), 
                 .usignext(0), .width(`WORD_WIDTH),
                 .w_data(0), .r_data(instr));
    memory dmem (.clk(clk), .we(memWE), .address(dataadr), 
                 .usignext(memcontrol[2]), .width(memcontrol[1:0]),
                 .w_data(writedata), .r_data(readdata));
endmodule