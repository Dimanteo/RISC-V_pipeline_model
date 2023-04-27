module rv32(input clk, reset,
            output [31:0] pc,
            input [31:0] instr,
            output writesmem, pause,
            output [31:0] aluout, writedata,
            input [31:0] readdata);
    wire memtoreg, branch, alusrc, regdst, regwrite, jump;
    wire [2:0] alucontrol;
    wire zero, brtaken;
    controller c(.op(instr[6:0]), 
                 .funct3(instr[14:12]),
                 .funct7(instr[31:25]),
                 .zero(zero),
                 .memtoreg(memtoreg),
                 .memwrite(writesmem),
                 .brtaken(brtaken),
                 .alusrc(alusrc), 
                 .regdst(regdst),
                 .writesreg(regwrite),
                 .jump(jump),
                 .pause(pause),
                 .alucontrol(alucontrol));
    datapath dp(clk, reset, memtoreg, brtaken,
                alusrc, regwrite, jump,
                zero, pc, instr,
                aluout, writedata, readdata);
endmodule