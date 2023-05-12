`include "consts.v"

module HazardUnit(
    // RAW forwarding
    input [4:0] rs1E, rs2E, rdM, rdW,
    input writesregM, writesregW,
    output [1:0] forwardAE, forwardBE,
    // RAW stalling
    input [4:0] rdE, rs1D, rs2D,
    input memtoregE,
    output stallF, stallD, flushE,
    // Control hazards
    input speculativeE, speculativeM, speculativeW);

    // Forwarding logic
    assign forwardAE = (rs1E != 0) && (rs1E == rdM) && writesregM ? `FWD_MEM
                       : (rs1E != 0) && (rs1E == rdW) && writesregW ? `FWD_WB 
                       : `NO_FWD;
    assign forwardBE = (rs2E != 0) && (rs2E == rdM) && writesregM ? `FWD_MEM
                       : (rs2E != 0) && (rs2E == rdW) && writesregW ? `FWD_WB 
                       : `NO_FWD;
    // Stall logic
    wire loadstall;
    assign loadstall = memtoregE && ((rdE == rs1D) || (rdE == rs2D));
    assign stallF = loadstall;
    assign stallD = loadstall;
    assign flushE = loadstall | speculativeE | speculativeM || speculativeW;
endmodule