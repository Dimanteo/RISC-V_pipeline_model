`include "consts.v"

module ForwardMux(input [31:0] srcE, srcM, srcW, 
                  input [1:0] forward, 
                  output [31:0] out);
    assign out = forward[0] == 0 ? srcE :
                 forward[1] ? srcW : srcM;
endmodule