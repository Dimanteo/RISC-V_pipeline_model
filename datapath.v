module datapath(input clk, reset, memtoreg, alusrcimm, writesreg, writesmem, 
                        indirectbr, jump, invcond, uncond, genupimm, pcrel,
                        pauseD,
                output memWE,
                input [31:0] simm, uimm,
                input [3:0] alucontrol,
                output [31:0] pc,
                input [31:0]  instr,
                output [31:0] decodeI,
                output [31:0] aluout, writedata,
                input [31:0] readdata);
    wire [31:0] result;

    // Fetch
    wire [31:0] instrF, pcnextF, pcplus4F, simmF, uimmF;
    assign instrF = instr;

    PCreg pcreg(.clk(clk), .reset(reset), .en(!pauseD), .in(pcnextF), .out(pc));
    adder pcadd1 (pc, 32'b100, pcplus4F);


    pipereg #(64) FetchPipe(.clk(clk), .reset(reset), .en(!pauseD),
                            .in ({instrF, pc}), 
                            .out({instrD, pcD}));

    // Decode
    wire [31:0] instrD, pcD;
    wire [4:0] rdD = instrD[11:7];
    wire [4:0] rs1D = instrD[19:15];
    wire [4:0] rs2D = instrD[24:20];
    wire [2:0] funct3D = instrD[14:12];
    wire [31:0] srcaD, writedataD, simmD, uimmD;

    assign decodeI = instrD;
    assign simmD = simm;
    assign uimmD = uimm;

    regfile rf(clk, writesregW, rs1D, rs2D, rdW, result, srcaD, writedataD);

    pipereg #(185) DecodePipe(.clk(clk), .reset(reset), .en(!pauseE),
        .in ({pcD, srcaD, writedataD, rs2D, rdD, simmD, uimmD, alucontrol, memtoreg, alusrcimm, writesreg, writesmem, indirectbr, jump, invcond, uncond, genupimm, pcrel, pauseD}),
        .out({pcE, srcaE, writedataE, rs2E, rdE, simmE, uimmE, alucontrolE, memtoregE, alusrcimmE, writesregE, writesmemE, indirectbrE, jumpE, invcondE, uncondE, genupimmE, pcrelE, pauseE}));

    // Execute
    wire [31:0] pcE, srcaE, writedataE, simmE, uimmE, srcbE, aluoutE;
    wire [31:0] indirectTargetE, jumpTargetE;
    wire [4:0] rs2E, rdE;
    wire[3:0] alucontrolE;
    wire memtoregE, alusrcimmE, writesregE, writesmemE, indirectbrE, jumpE, invcondE, uncondE, genupimmE, pcrelE, brtakenE, pauseE;

    mux2 #(32) srcbmux(writedataE, simmE, alusrcimmE, srcbE);
    alu alu(srcaE, srcbE, alucontrolE, aluoutE);

    assign indirectTargetE = aluoutE & 32'hfffffffe;
    assign jumpTargetE = indirectbrE ? indirectTargetE : (pcE + simmE);
    assign brtakenE = invcondE ? !(aluoutE == 0) : aluoutE == 0;

    pipereg #(206) ExecutePipe(.clk(clk), .reset(reset), .en(!pauseM),
        .in ({pcE, rdE, aluoutE, jumpTargetE, writedataE, simmE, uimmE, writesregE, brtakenE, uncondE, memtoregE, genupimmE, pcrelE, jumpE, writesmemE, pauseE}),
        .out({pcM, rdM, aluoutM, jumpTargetM, writedataM, simmM, uimmM, writesregM, brtakenM, uncondM, memtoregM, genupimmM, pcrelM, jumpM, writesmemM, pauseM}));

    // Memory
    wire [31:0] readdataM, pcM, jumpTargetM, aluoutM, writedataM, simmM, uimmM;
    wire [4:0] rdM;
    wire writesregM, brtakenM, uncondM, memtoregM, genupimmM, pcrelM, jumpM, writesmemM, pauseM;
    
    assign readdataM = readdata;
    assign writedata = writedataM;
    assign memWE = writesmemM;

    mux2 #(32) jumpmux(pcplus4F, jumpTargetM, jumpM & (uncondM || brtakenM), pcnextF);

    pipereg #(140) MemoryPipe(.clk(clk), .reset(reset), .en(!pauseW),
        .in ({pcM, rdM, aluoutM, readdataM, uimmM, writesregM, brtakenM, memtoregM, genupimmM, pcrelM, jumpM, pauseM}),
        .out({pcW, rdW, aluoutW, readdataW, uimmW, writesregW, brtakenW, memtoregW, genupimmW, pcrelW, jumpW, pauseW}));

    // Writeback
    wire writesregW, brtakenW, memtoregW, genupimmW, pcrelW, jumpW, pauseW;
    wire [4:0] rdW;
    wire [31:0] pcW, aluoutW, readdataW, uimmW;
    assign result = memtoregW ? readdataW
        : genupimmW ?  (pcrelW ? uimmW + pcW : uimmW)
        : jumpW ? pcW + 4 : aluoutW;

    always @(negedge clk) begin
        if (pauseW) $finish;
    end

endmodule