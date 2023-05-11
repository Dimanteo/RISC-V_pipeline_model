module datapath(input clk, reset, memtoreg, alusrcimm, writesreg, writesmem, 
                        indirectbr, jump, invcond, uncond, genupimm, pcrel,
                        pauseD,
                output memWE,
                input [31:0] simm, uimm,
                input [3:0] alucontrol,
                output [2:0] memcontrol,
                output [31:0] pc,
                input [31:0]  instr,
                output [31:0] decodeI,
                output [31:0] aluout, writedata,
                input [31:0] readdata);

    // Hazard unit
    wire stallF, stallD, flushE;
    wire [1:0] forwardAE, forwardBE;

    HazardUnit hu(
        // forwarding
        .rs1E(rs1E), .rs2E(rs2E), .rdM(rdM), .rdW(rdW),
        .writesregM(writesregM), .writesregW(writesregW),
        .forwardAE(forwardAE), .forwardBE(forwardBE),
        // stalling
        .rdE(rdE), .rs1D(rs1D), .rs2D(rs2D),
        .memtoregE(memtoregE),
        .stallF(stallF), .stallD(stallD), .flushE(flushE));

    // Fetch
    wire [31:0] instrF, pcnextF, pcplus4F, simmF, uimmF;
    assign instrF = instr;

    wire PCregEN = !stallF & !pauseD;

    PCreg pcreg(.clk(clk), .reset(reset), .en(PCregEN), .in(pcnextF), .out(pc));
    adder pcadd1 (pc, 32'b100, pcplus4F);


    wire FetchPipeEN = !stallD & !pauseD;

    pipereg #(64) FetchPipe(.clk(clk), .reset(reset), .en(FetchPipeEN),
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

    wire DecodePipeReset = flushE;

    pipereg #(193) DecodePipe(.clk(clk), .reset(DecodePipeReset), .en(!pauseE),
        .in ({pcD, srcaD, writedataD, rs1D, rs2D, rdD, simmD, uimmD, alucontrol, memtoreg, alusrcimm, writesreg, writesmem, indirectbr, jump, invcond, uncond, genupimm, pcrel, pauseD, funct3D}),
        .out({pcE, srcaE, writedataE, rs1E, rs2E, rdE, simmE, uimmE, alucontrolE, memtoregE, alusrcimmE, writesregE, writesmemE, indirectbrE, jumpE, invcondE, uncondE, genupimmE, pcrelE, pauseE, funct3E}));

    // Execute
    wire [31:0] pcE, srcaE, writedataE, simmE, uimmE, srcbE, aluoutE;
    wire [31:0] indirectTargetE, jumpTargetE, srcaHazard, srcbHazard;
    wire [4:0] rs1E, rs2E, rdE;
    wire[3:0] alucontrolE;
    wire [2:0] funct3E;
    wire memtoregE, alusrcimmE, writesregE, writesmemE, indirectbrE, jumpE, invcondE, uncondE, genupimmE, pcrelE, brtakenE, pauseE;

    ForwardMux forwardAmux(.srcE(srcaE), .srcM(aluoutM), .srcW(result), .forward(forwardAE), .out(srcaHazard));
    ForwardMux forwardBmux(.srcE(writedataE), .srcM(aluoutM), .srcW(result), .forward(forwardBE), .out(srcbHazard));
    
    mux2 #(32) srcbmux(srcbHazard, simmE, alusrcimmE, srcbE);

    alu alu(srcaHazard, srcbE, alucontrolE, aluoutE);

    assign indirectTargetE = aluoutE & 32'hfffffffe;
    assign jumpTargetE = indirectbrE ? indirectTargetE : (pcE + simmE);
    assign brtakenE = invcondE ? !(aluoutE == 0) : aluoutE == 0;

    pipereg #(209) ExecutePipe(.clk(clk), .reset(reset), .en(!pauseM),
        .in ({pcE, rdE, aluoutE, jumpTargetE, writedataE, simmE, uimmE, writesregE, brtakenE, uncondE, memtoregE, genupimmE, pcrelE, jumpE, writesmemE, pauseE, funct3E}),
        .out({pcM, rdM, aluoutM, jumpTargetM, writedataM, simmM, uimmM, writesregM, brtakenM, uncondM, memtoregM, genupimmM, pcrelM, jumpM, writesmemM, pauseM, funct3M}));

    // Memory
    wire [31:0] readdataM, pcM, jumpTargetM, aluoutM, writedataM, simmM, uimmM;
    wire [4:0] rdM;
    wire [2:0] funct3M;
    wire writesregM, brtakenM, uncondM, memtoregM, genupimmM, pcrelM, jumpM, writesmemM, pauseM;
    
    assign readdataM = readdata;
    assign writedata = writedataM;
    assign memWE = writesmemM;
    assign aluout = aluoutM;
    assign memcontrol = funct3M;

    mux2 #(32) jumpmux(pcplus4F, jumpTargetM, jumpM & (uncondM || brtakenM), pcnextF);

    pipereg #(140) MemoryPipe(.clk(clk), .reset(reset), .en(!pauseW),
        .in ({pcM, rdM, aluoutM, readdataM, uimmM, writesregM, brtakenM, memtoregM, genupimmM, pcrelM, jumpM, pauseM}),
        .out({pcW, rdW, aluoutW, readdataW, uimmW, writesregW, brtakenW, memtoregW, genupimmW, pcrelW, jumpW, pauseW}));

    // Writeback
    wire [31:0] result;
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