`include "consts.v"

module HazardUnit(
    // RAW
    input [4:0] rs1E, rs2E, rdM, rdW,
    input writesregM, writesregW,
    output [1:0] forwardAE, forwardBE);
    assign forwardAE = (rs1E != 0) && (rs1E == rdM) && writesregM ? `FWD_MEM
                       : (rs1E != 0) && (rs1E == rdW) && writesregW ? `FWD_WB 
                       : `NO_FWD;
    assign forwardBE = (rs2E != 0) && (rs2E == rdM) && writesregM ? `FWD_MEM
                       : (rs2E != 0) && (rs2E == rdW) && writesregW ? `FWD_WB 
                       : `NO_FWD;
endmodule