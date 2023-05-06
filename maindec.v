`define PAUSE_OP 7'b0001111

`include "inst.v"

`define  ALU_ADD 4'b0000

module maindec(input [6:0] op, input [2:0] funct3, input [6:0] funct7,
               output memtoreg,
               output memwrite,
               output alusrcimm,
               output writesreg,
               output jump,
               output pause /*verilator public*/,
               output [3:0] aluop,
               output splitimm);
    reg [10:0] controls;
    assign {memtoreg,
            memwrite,
            alusrcimm,
            writesreg,
            jump,
            pause,
            splitimm,
            aluop
        } = controls;
    always @ (*) begin
        case(op)
            `PAUSE_OP  : controls = {7'b0000010, funct7[5], funct3};
            `IMMALU_OP : controls = {7'b0011000, 1'b0, funct3};
            `REGALU_OP : controls = {7'b0001000, funct7[5], funct3};
            `LOAD_OP   : controls = {7'b1011000, `ALU_ADD};
            `STORE_OP  : controls = {7'b0110001, `ALU_ADD};
            default: controls = {11'bxxxxxxxxxxx}; //???
        endcase
    end
endmodule