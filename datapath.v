module datapath(input clk, reset, memtoreg, alusrcimm, writesreg, writesmem, 
                        indirectbr, jump, invcond, uncond, genupimm, pcrel,
                        pauseD, valid,
                output memWE, validOut,
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
        .stallF(stallF), .stallD(stallD), .flushE(flushE),
        // control hazards
        .speculativeE(jumpE & brtakenE),
        .speculativeM(jumpM & brtakenM),
        .speculativeW(jumpW & brtakenW));

    // Fetch
    wire [31:0] instrF, pcnextF, pcplus4F, simmF, uimmF;
    assign instrF = instr;

    wire PCregEN = !stallF;

    PCreg pcreg(.clk(clk), .reset(reset), .en(PCregEN), .in(pcnextF), .out(pc));
    adder pcadd1 (pc, 32'b100, pcplus4F);


    wire FetchPipeEN = !stallD;

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
    wire validD;

    assign validD = valid;
    assign decodeI = instrD;
    assign simmD = simm;
    assign uimmD = uimm;

    regfile rf(clk, writesregW, rs1D, rs2D, rdW, result, srcaD, writedataD);

    wire DecodePipeReset = flushE;

    pipereg #(194) DecodePipe(.clk(clk), .reset(DecodePipeReset), .en(!pauseE),
        .in ({pcD, srcaD, writedataD, rs1D, rs2D, rdD, simmD, uimmD, alucontrol, memtoreg, alusrcimm, writesreg, writesmem, indirectbr, jump, invcond, uncond, genupimm, pcrel, pauseD, funct3D, validD}),
        .out({pcE, srcaE, writedataE, rs1E, rs2E, rdE, simmE, uimmE, alucontrolE, memtoregE, alusrcimmE, writesregE, writesmemE, indirectbrE, jumpE, invcondE, uncondE, genupimmE, pcrelE, pauseE, funct3E, validE}));

    // Execute
    wire [31:0] pcE, srcaE, writedataE, simmE, uimmE, srcbE, aluRes, aluoutE;
    wire [31:0] indirectTargetE, jumpTargetE, srcaHazard, srcbHazard;
    wire [4:0] rs1E, rs2E, rdE;
    wire[3:0] alucontrolE;
    wire [2:0] funct3E;
    wire memtoregE, alusrcimmE, writesregE, writesmemE, indirectbrE, jumpE,
        invcondE, uncondE, genupimmE, pcrelE, brtakenE, pauseE, validE;

    ForwardMux forwardAmux(.srcE(srcaE), .srcM(aluoutM), .srcW(result), .forward(forwardAE), .out(srcaHazard));
    ForwardMux forwardBmux(.srcE(writedataE), .srcM(aluoutM), .srcW(result), .forward(forwardBE), .out(srcbHazard));
    
    mux2 #(32) srcbmux(srcbHazard, simmE, alusrcimmE, srcbE);

    alu alu(srcaHazard, srcbE, alucontrolE, aluRes);

    assign aluoutE = genupimmE ? (pcrelE ? uimmE + pcE : uimmE) : aluRes;

    assign indirectTargetE = aluoutE & 32'hfffffffe;
    assign jumpTargetE = indirectbrE ? indirectTargetE : (pcE + simmE);
    wire zero;
    assign zero = invcondE ? !(aluoutE == 0) : aluoutE == 0;
    assign brtakenE = (zero | uncondE) & jumpE;

    pipereg #(220) ExecutePipe(.clk(clk), .reset(reset), .en(!pauseM),
        .in ({pcE, rs1E, rs2E, rdE, aluoutE, jumpTargetE, writedataE, simmE, uimmE, writesregE, brtakenE, uncondE, memtoregE, genupimmE, pcrelE, jumpE, writesmemE, pauseE, funct3E, validE}),
        .out({pcM, rs1M, rs2M, rdM, aluoutM, jumpTargetM, writedataM, simmM, uimmM, writesregM, brtakenM, uncondM, memtoregM, genupimmM, pcrelM, jumpM, writesmemM, pauseM, funct3M, validM}));

    // Memory
    wire [31:0] readdataM, pcM, jumpTargetM, aluoutM, writedataM, simmM, uimmM;
    wire [4:0] rs1M, rs2M, rdM;
    wire [2:0] funct3M;
    wire writesregM, brtakenM, uncondM, memtoregM, genupimmM, pcrelM, jumpM, 
        writesmemM, pauseM, validM;
    
    assign readdataM = readdata;
    assign writedata = writedataM;
    assign memWE = writesmemM;
    assign aluout = aluoutM;
    assign memcontrol = funct3M;

    mux2 #(32) jumpmux(pcplus4F, jumpTargetM, brtakenM, pcnextF);

    pipereg #(151) MemoryPipe(.clk(clk), .reset(reset), .en(!pauseW),
        .in ({pcM, rs1M, rs2M, rdM, aluoutM, readdataM, simmM, writesregM, brtakenM, memtoregM, genupimmM, pcrelM, jumpM, pauseM, validM}),
        .out({pcW, rs1W, rs2W, rdW, aluoutW, readdataW, simmW, writesregW, brtakenW, memtoregW, genupimmW, pcrelW, jumpW, pauseW, validW}));

    // Writeback
    wire [31:0] result;
    wire writesregW, brtakenW, memtoregW, genupimmW, pcrelW, jumpW, pauseW, validW;
    wire [4:0] rs1W /*verilator public*/, rs2W /*verilator public*/, rdW /*verilator public*/;
    wire [31:0] pcW /*verilator public*/, aluoutW, readdataW, simmW /*verilator public*/;
    assign result = memtoregW ? readdataW : jumpW ? pcW + 4 : aluoutW;
    assign validOut = validW;

    always @(negedge clk) begin
        if (pauseW) $finish;
    end

endmodule