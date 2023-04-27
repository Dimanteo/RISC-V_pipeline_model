module datapath(input clk, reset, memtoreg, brtaken, alusrcimm, writesreg, jump,
                // input [2:0] alucontrol,
                output zero,
                output [31:0] pc /*verilator public*/,
                input [31:0]  instr,
                output [31:0] aluout, writedata,
                input [31:0] readdata);
    wire [4:0] rd = instr[11:7];
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
    wire [31:0] signimm, signimmsh;
    wire [31:0] srca, srcb;
    wire [31:0] result;
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];
    // next PC logic
    flopr #(32) pcreg(clk, reset, pcnext, pc);
    adder pcadd1 (pc, 32'b100, pcplus4);
    sl2 immsh(signimm, signimmsh);
    adder pcadd2(pcplus4, signimmsh, pcbranch);
    mux2 #(32) pcbrmux(pcplus4, pcbranch, brtaken, pcnextbr);
    mux2 #(32) pcmux(pcnextbr, {pcplus4[31:28], instr[25:0], 2'b00}, jump, pcnext);
    // register file logic
    regfile rf(clk, writesreg, rs1, rs2, rd, result, srca, writedata);
    mux2 #(32) resmux(aluout, readdata, memtoreg, result);
    signext se(instr[31:20], signimm);
    // ALU logic
    mux2 #(32) srcbmux(writedata, signimm, alusrcimm, srcb);
    alu alu(srca, srcb, {funct7[5], funct3}, aluout, zero);
endmodule