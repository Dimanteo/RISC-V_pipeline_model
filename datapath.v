module datapath(input clk, reset, memtoreg, brtaken, alusrcimm,
                        writesreg, readsreg, jump,
                input [31:0] simm, uimm,
                input [3:0] alucontrol,
                output zero,
                output [31:0] pc /*verilator public*/,
                input [31:0]  instr,
                output [31:0] aluout, writedata,
                input [31:0] readdata);
    wire [4:0] rd = instr[11:7];
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [31:0] pcnext, pcnextbr, pcplus4, indirectTarget, jumpTarget;
    wire [31:0] srca, srcb;
    wire [31:0] result;

    // next PC logic
    flopr #(32) pcreg(clk, reset, pcnext, pc);
    adder pcadd1 (pc, 32'b100, pcplus4);
    assign indirectTarget = (pc + aluout) & 32'hfffe;
    assign jumpTarget = (jump && readsreg) ? indirectTarget : (pc + simm);
    mux2 #(32) jumpmux(pcplus4, jumpTarget, jump, pcnext);
    // register file logic
    regfile rf(clk, writesreg, rs1, rs2, rd, result, srca, writedata);
    mux2 #(32) resmux(jump ? pcplus4 : aluout, readdata, memtoreg, result);
    // ALU logic
    mux2 #(32) srcbmux(writedata, simm, alusrcimm, srcb);
    alu alu(srca, srcb, alucontrol, aluout, zero);
endmodule