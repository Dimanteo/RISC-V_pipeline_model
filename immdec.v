module immdec(input [2:0] itype, input [31:0] instr, output [31:0] simm, uimm);
    wire [11:0] immItype = instr[31:20];
    wire [11:0] immStype = {instr[31:25], instr[11:7]};
    wire [11:0] immBtype = {instr[31], instr[7], instr[30:25], instr[11:8]};
    wire [20:0] immJtype = {instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
    wire [31:0] immUtype = {instr[31:12], 12'd0};

    assign {simm, uimm} = 
    itype[2] == 1 ? // UTYPE or JTYPE
        itype[1:0] == 2'b01 ? // JTYPE
            {{{11{immJtype[20]}}, immJtype},
             {11'd0, immJtype}}
        : // UTYPE
            {immUtype, immUtype}
    :
        itype[1] == 1 ? // BTYPE or STYPE
            itype[0] ? // STYPE
                {{{20{immStype[11]}}, immStype}, {20'd0, immStype}}
            : // BTYPE
                {{{20{immBtype[11]}}, immBtype}, {20'd0, immBtype}}
        : // RTYPE or ITYPE
            itype[0] ? // ITYPE
                {{{20{immItype[11]}}, immItype}, {20'd0, immItype}}
            : // RTYPE
                {{32{1'bx}}, {32{1'bx}}};

endmodule