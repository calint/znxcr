`timescale 1ns / 1ps
`default_nettype none

module ROM #(parameter ADDR_WIDTH = 16, parameter WIDTH = 16) (
    input wire [ADDR_WIDTH-1:0] addr, // address
    output wire [WIDTH-1:0] data // data at address
);

reg [WIDTH-1:0] mem [0:2**ADDR_WIDTH-1];

integer i;
initial begin
    for (i = 0; i < 2**ADDR_WIDTH; i = i + 1) begin
        mem[i] = {WIDTH{1'b0}};
    end
    $readmemh("rom.hex", mem);
end

assign data = mem[addr];

endmodule

`default_nettype wire
