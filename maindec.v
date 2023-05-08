`define PAUSE_OP 7'b0001111

`include "inst.v"

`include "formats.v"

`define ALU_ADD  4'b0000
`define ALU_SUB  4'b1000
`define ALU_SLT  4'b0010
`define ALU_SLTU 4'b1010 

module maindec(input [6:0] op, input [2:0] funct3, input [6:0] funct7,
               output logic memtoreg,
               output logic memwrite,
               output logic alusrcimm,
               output logic writesreg,
               output logic indirectbr,
               output logic jump,
               output logic pause /*verilator public*/,
               output logic [3:0] aluop,
               output logic [2:0] itype,
               output logic invcond, uncond);
    wire [3:0] alu_nop = 4'bxxxx;
    always_latch @ (*) begin
        invcond = 1'bx;
        uncond = 1'bx;
        case(op)
            `ECALL_OP: begin // EBREAK
                memtoreg = 0;
                memwrite = 0;
                alusrcimm = 0;
                writesreg = 0;
                indirectbr = 0;
                jump = 0;
                pause = 1;
                itype = `RTYPE;
                aluop = alu_nop;
            end
            `PAUSE_OP: begin
                memtoreg = 0;
                memwrite = 0;
                alusrcimm = 0;
                writesreg = 0;
                indirectbr = 0;
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
                indirectbr = 1;
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
                indirectbr = 1;
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
                indirectbr = 1;
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
                indirectbr = 1;
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
                indirectbr = 0;
                jump = 1;
                pause = 0;
                itype = `JTYPE;
                aluop = alu_nop;
                uncond = 1;
            end
            `JALR_OP: begin
                memtoreg = 0;
                memwrite = 0;
                alusrcimm = 1;
                writesreg = 1;
                indirectbr = 1;
                jump = 1;
                pause = 0;
                itype = `ITYPE;
                aluop = `ALU_ADD;
                uncond = 1;
            end
            `BRANCH_OP: begin
                memtoreg = 0;
                memwrite = 0;
                alusrcimm = 0;
                writesreg = 0;
                indirectbr = 0;
                jump = 1;
                pause = 0;
                itype = `BTYPE;
                {aluop, invcond} = funct3[2:1] == 2'b00 ? {`ALU_SUB, funct3[0]}
                : funct3[2:1] == 2'b10 ? {`ALU_SLT, !funct3[0]}
                : funct3[2:1] == 2'b11 ? {`ALU_SLTU, !funct3[0]} : {alu_nop, funct3[0]};
                uncond = 0;
            end
            default: $display("ERROR : unknown opcode");  //???
        endcase
    end
endmodule