module top(input clk, reset,
           output [31:0] writedata, dataadr,
           output writesmem, pause);
    wire [31:0] pc, instr /*verilator public*/, readdata;
    // instantiate processor and memories
    rv32 rv32 (.clk(clk), .reset(reset), .pc(pc), 
               .instr(instr), .writesmem(writesmem), .pause(pause), 
               .aluout(dataadr), .writedata(writedata), .readdata(readdata));
    memory imem (.clk(clk), .we(0), .address(pc), .w_data(0), .r_data(instr));
    memory dmem (.clk(clk), .we(writesmem), .address(dataadr), 
                 .w_data(writedata), .r_data(readdata));
endmodule