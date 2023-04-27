`define PAUSE_OP 7'b0001111

`include "inst.v"

module maindec(input [6:0] op, input [2:0] funct3, input [6:0] funct7,
               output memtoreg,
               output memwrite,
               output alusrcimm,
               output writesreg,
               output jump,
               output pause /*verilator public*/);
    reg [5:0] controls /*verilator public*/;
    assign {memtoreg,
            memwrite,
            alusrcimm,
            writesreg,
            jump,
            pause
        } = controls;
    always @ (*)
        case(op)
            `PAUSE_OP  : controls = 6'b000001;
            `IMMALU_OP : controls = 6'b001100;
            `REGALU_OP : controls = 6'b000100;
            default: controls = 6'bxxxxxx; //???
        endcase
endmodule