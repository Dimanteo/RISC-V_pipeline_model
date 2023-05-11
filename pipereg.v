module pipereg # (parameter W = 32) 
    (input clk, reset, en, input [W-1:0] in, output [W-1:0] out);

    reg [W-1:0] storage /*verilator public*/;

    assign out = storage;

    always @ (posedge clk) begin
        if (!reset && en) begin 
            storage <= in;
        end
        else begin
            if(reset) begin
                storage <= 0;
            end
        end
    end
endmodule