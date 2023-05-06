`define BYTE_W 2'b00
`define HALF_W 2'b01
`define WORD_W 2'b10

module memory # (parameter SIZE = 1024)
            (input clk, we,
            input [31:0] address /*verilator public*/,
            input usignext,
            input [1:0] width,
            input [31:0] w_data,
            output [31:0] r_data);
    reg [7:0] storage[SIZE] /*verilator public*/;
    wire [31:0] r_word;
    
    wire [31:0] read_word = {storage[address],
                      storage[address + 1],
                      storage[address + 2],
                      storage[address + 3]};
    wire [31:0] read_half = usignext ? {16'd0, storage[address], storage[address + 1]}
                        : {{16{storage[address][7]}},
                          storage[address],
                          storage[address + 1]};
    wire [31:0] read_byte = usignext ? {24'd0, storage[address]} : 
                                {{24{storage[address][7]}}, storage[address]};

    assign r_data = (width == `WORD_W) ? read_word
                    : (width == `HALF_W) ? read_half
                    : (width == `BYTE_W) ? read_byte : {32{1'bx}};

    always @(posedge clk) 
    begin
        if (we) begin
            case(width)
                `BYTE_W:
                    storage[address] <= w_data[7:0];
                `HALF_W:
                    {storage[address], storage[address + 1]} <=w_data[15:0];
                `WORD_W:
                    {storage[address],
                     storage[address + 1],
                     storage[address + 2],
                     storage[address + 3]} <= w_data;
                default:;
            endcase
        end
    end
endmodule