`include "inst.v"

`include "consts.v"

module maindec(input [6:0] op, input [2:0] funct3, input [6:0] funct7,
               output logic memtoreg,
               output logic memwrite,
               output logic alusrcimm,
               output logic writesreg,
               output logic indirectbr,
               output logic jump,
               output logic pause,
               output logic [3:0] aluop,
               output logic [2:0] itype,
               output logic invcond, uncond,
               output logic genupimm, pcrel, valid);
    wire [3:0] alu_nop = 4'bxxxx;
    always_latch @ (*) begin
        {memtoreg,
        memwrite,
        alusrcimm,
        writesreg,
        indirectbr,
        jump,
        pause,
        invcond,
        uncond,
        genupimm,
        pcrel,
        valid} = 12'b0000000xx000;
        case(op)
            `ECALL_OP: begin // EBREAK
                pause = 1;
                itype = `RTYPE;
                aluop = alu_nop;
                valid = 1;
            end
            `FENCE_OP: begin
                pause = 1;
                itype = `RTYPE;
                aluop = alu_nop;
                valid = 1;
            end
            `IMMALU_OP: begin
                alusrcimm = 1;
                writesreg = 1;
                itype = `ITYPE;
                aluop = {1'b0, funct3};
                valid = 1;
            end
            `REGALU_OP: begin
                writesreg = 1;
                itype = `RTYPE;
                aluop = {funct7[5], funct3};
                valid = 1;
            end
            `LOAD_OP: begin 
                memtoreg = 1;
                alusrcimm = 1;
                writesreg = 1;
                itype = `ITYPE;
                aluop = `ALU_ADD;
                valid = 1;
            end
            `STORE_OP: begin
                memwrite = 1;
                alusrcimm = 1;
                itype = `STYPE;
                aluop = `ALU_ADD;
                valid = 1;
            end
            `JAL_OP: begin
                writesreg = 1;
                jump = 1;
                uncond = 1;
                pcrel = 1;
                itype = `JTYPE;
                aluop = alu_nop;
                valid = 1;
            end
            `JALR_OP: begin
                alusrcimm = 1;
                writesreg = 1;
                indirectbr = 1;
                jump = 1;
                uncond = 1;
                itype = `ITYPE;
                aluop = `ALU_ADD;
                valid = 1;
            end
            `BRANCH_OP: begin
                jump = 1;
                pcrel = 1;
                itype = `BTYPE;
                {aluop, invcond} = funct3[2:1] == 2'b00 ? {`ALU_SUB, funct3[0]}
                : funct3[2:1] == 2'b10 ? {`ALU_SLT, !funct3[0]}
                : funct3[2:1] == 2'b11 ? {`ALU_SLTU, !funct3[0]} : {alu_nop, funct3[0]};
                valid = 1;
            end
            `LUI_OP: begin
                writesreg = 1;
                genupimm = 1;
                itype = `UTYPE;
                aluop = alu_nop;
                valid = 1;
            end
            `AUIPC_OP: begin
                writesreg = 1;
                genupimm = 1;
                pcrel = 1;
                itype = `UTYPE;
                aluop = alu_nop;
                valid = 1;
            end
            7'b0000000: valid = 0; // zero opcode from reset, perform no operation
            default: begin 
                valid = 0;
                $display("ERROR : unknown opcode %x", op);
            end
        endcase
    end
endmodule