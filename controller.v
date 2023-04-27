module controller(input [6:0] op,
                  input [2:0] funct3,
                  input [6:0] funct7,
                  input zero,
                  output memtoreg, memwrite,
                  output brtaken, alusrc,
                  output regdst, writesreg,
                  output jump,
                  output pause,
                  output [2:0] alucontrol);
    wire [1:0] aluop;
    maindec md (.op(op), .funct3(funct3), .funct7(funct7), .memtoreg(memtoreg), 
                .memwrite(memwrite), .alusrcimm(alusrc), .writesreg(writesreg), 
                .jump(jump), .pause(pause));
    assign brtaken = jump & zero;
endmodule