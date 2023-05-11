// Inst types
`define RTYPE 3'b000
`define ITYPE 3'b001
`define BTYPE 3'b010
`define STYPE 3'b011
`define UTYPE 3'b100
`define JTYPE 3'b101

// ALU operations
`define ALU_ADD  4'b0000
`define ALU_SUB  4'b1000
`define ALU_SLT  4'b0010
`define ALU_SLTU 4'b1010 

// Hazard unit
`define NO_FWD 2'b00
`define FWD_MEM 2'b01
`define FWD_WB 2'b11