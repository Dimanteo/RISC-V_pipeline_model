module alu(input [31:0] lhs, rhs, input [3:0] funct, 
           output reg [31:0] y);
    wire [31:0] sign_rhs = (funct[3] == 0) ? rhs : ~rhs + 1;
    always @(*) begin
        case(funct[2:0])
            3'b000: y = lhs + sign_rhs; // ADD, SUB
            3'b001: y = lhs << rhs[4:0]; // SLL
            3'b010: y = ($signed(lhs) < $signed(rhs)) ? 1 : 0; // SLT
            3'b011: y = (lhs < rhs) ? 1 : 0; // SLTU
            3'b100: y = lhs ^ rhs; // XORI
            3'b101:
                if (funct[3]) 
                begin
                    y = $signed(lhs) >>> $signed(rhs[4:0]); // SRA
                end else begin
                    y = lhs >> rhs[4:0]; // SRL
                end
            3'b110: y = lhs | rhs; // OR
            3'b111: y = lhs & rhs; // AND
        endcase
    end
endmodule