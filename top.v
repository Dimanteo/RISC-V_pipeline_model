`define WORD_WIDTH 2'b10

module top(input clk, reset,
           output [31:0] dataadr,
           output writesmem, pause);
    wire [31:0] pc, instr /*verilator public*/, readdata, writedata;
    // instantiate processor and memories
    rv32 rv32 (.clk(clk), .reset(reset), .pc(pc), 
               .instr(instr), .writesmem(writesmem), .pause(pause), 
               .aluout(dataadr), .writedata(writedata), .readdata(readdata));
    memory #(1 << 22) imem (.clk(clk), .we(0), .address(pc), 
                 .usignext(0), .width(`WORD_WIDTH),
                 .w_data(0), .r_data(instr));
    memory dmem (.clk(clk), .we(writesmem), .address(dataadr), 
                 .usignext(instr[14]), .width(instr[13:12]),
                 .w_data(writedata), .r_data(readdata));
endmodule