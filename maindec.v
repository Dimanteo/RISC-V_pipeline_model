`define PAUSE_OP 7'b0001111

`include "inst.v"

`include "formats.v"

`define  ALU_ADD 4'b0000

module maindec(input [6:0] op, input [2:0] funct3, input [6:0] funct7,
               output logic memtoreg,
               output logic memwrite,
               output logic alusrcimm,
               output logic writesreg,
               output logic jump,
               output logic pause /*verilator public*/,
               output logic [3:0] aluop,
               output logic [2:0] itype);
    wire [3:0] alu_nop = 4'bxxxx;
    always_latch @ (*) begin
        case(op)
            `PAUSE_OP: begin
                memtoreg = 0;
                memwrite = 0;
                alusrcimm = 0;
                writesreg = 0;
                jump = 0;
                pause = 1;
                itype = `RTYPE;
                aluop = alu_nop;
            end
            `IMMALU_OP: begin
                memtoreg = 0;
                memwrite = 0;
                alusrcimm = 1;
                writesreg = 1;
                jump = 0;
                pause = 0;
                itype = `ITYPE;
                aluop = {1'b0, funct3};
            end
            `REGALU_OP: begin
                memtoreg = 0;
                memwrite = 0;
                alusrcimm = 0;
                writesreg = 1;
                jump = 0;
                pause = 0;
                itype = `RTYPE;
                aluop = {funct7[5], funct3};
            end
            `LOAD_OP: begin 
                memtoreg = 1;
                memwrite = 0;
                alusrcimm = 1;
                writesreg = 1;
                jump = 0;
                pause = 0;
                itype = `ITYPE;
                aluop = `ALU_ADD;
            end
            `STORE_OP: begin
                memtoreg = 0;
                memwrite = 1;
                alusrcimm = 1;
                writesreg = 0;
                jump = 0;
                pause = 0;
                itype = `STYPE;
                aluop = `ALU_ADD;
            end
            `JAL_OP: begin
                memtoreg = 0;
                memwrite = 0;
                alusrcimm = 0;
                writesreg = 1;
                jump = 1;
                pause = 0;
                itype = `JTYPE;
                aluop = alu_nop;
            end
            default: $display("ERROR : unknown opcode");  //???
        endcase
    end
endmodule