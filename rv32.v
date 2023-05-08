module rv32(input clk, reset,
            output [31:0] pc,
            input [31:0] instr,
            output writesmem, pause,
            output [31:0] aluout, writedata,
            input [31:0] readdata);
    wire memtoreg, branch, alusrc, regdst, regwrite,
         indirectbr, jump, invcond, uncond, genupimm, pcrel;
    wire [3:0] alucontrol;
    wire [2:0] itype;
    wire [31:0] simm, uimm;
    maindec md (.op(instr[6:0]),
                .funct3(instr[14:12]),
                .funct7(instr[31:25]),
                .memtoreg(memtoreg),
                .memwrite(writesmem),
                .alusrcimm(alusrc),
                .writesreg(regwrite),
                .indirectbr(indirectbr),
                .jump(jump),
                .pause(pause),
                .aluop(alucontrol), 
                .itype(itype),
                .invcond(invcond),
                .uncond(uncond),
                .genupimm(genupimm),
                .pcrel(pcrel));
    immdec immd(.instr(instr), .itype(itype), .simm(simm), .uimm(uimm));
    datapath dp(.clk(clk), .reset(reset), 
                .memtoreg(memtoreg),
                .alusrcimm(alusrc), 
                .writesreg(regwrite),
                .indirectbr(indirectbr),
                .jump(jump),
                .invcond(invcond),
                .uncond(uncond),
                .genupimm(genupimm),
                .pcrel(pcrel),
                .simm(simm),
                .uimm(uimm),
                .alucontrol(alucontrol),
                .pc(pc), 
                .instr(instr),
                .aluout(aluout),
                .writedata(writedata),
                .readdata(readdata));
endmodule