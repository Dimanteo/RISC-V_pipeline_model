module datapath(input clk, reset, memtoreg, alusrcimm, writesreg, indirectbr,
                        jump, invcond, uncond, genupimm, pcrel,
                input [31:0] simm, uimm,
                input [3:0] alucontrol,
                output [31:0] pc /*verilator public*/,
                input [31:0]  instr,
                output [31:0] aluout, writedata,
                input [31:0] readdata);
    wire [4:0] rd = instr[11:7];
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [2:0] funct3 = instr[14:12];
    wire [31:0] pcnext, pcplus4, indirectTarget, jumpTarget;
    wire [31:0] srca, srcb;
    wire [31:0] result;
    wire brtaken;

    // next PC logic
    flopr #(32) pcreg(clk, reset, pcnext, pc);
    adder pcadd1 (pc, 32'b100, pcplus4);
    assign indirectTarget = aluout & 32'hfffffffe;
    assign jumpTarget = indirectbr ? indirectTarget : (pc + simm);
    mux2 #(32) jumpmux(pcplus4, jumpTarget, jump & (uncond || brtaken), pcnext);
    assign brtaken = invcond ? !(aluout == 0) : aluout == 0;

    // register file logic
    regfile rf(clk, writesreg, rs1, rs2, rd, result, srca, writedata);
    assign result = memtoreg ? readdata
        : genupimm ?  (pcrel ? uimm + pc : uimm)
        : jump ? pcplus4 : aluout;

    // ALU logic
    mux2 #(32) srcbmux(writedata, simm, alusrcimm, srcb);
    alu alu(srca, srcb, alucontrol, aluout);
endmodule