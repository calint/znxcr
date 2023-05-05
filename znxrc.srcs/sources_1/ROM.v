`timescale 1ns / 1ps

module ROM #(parameter SIZE = 4096, parameter ADDR_WIDTH = 16, parameter WIDTH = 16) (
    input [ADDR_WIDTH-1:0] addr, // address
    output [WIDTH-1:0] data // data at address
);

reg [WIDTH-1:0] mem [0:SIZE-1];

integer i;
initial begin
    for (i = 0; i < SIZE; i = i + 1) begin
        mem[i] = {WIDTH{1'b0}};
    end
    $readmemh("rom.hex", mem);
end

assign data = mem[addr];

endmodule