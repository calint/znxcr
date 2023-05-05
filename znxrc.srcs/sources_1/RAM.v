`timescale 1ns / 1ps

module RAM #(parameter SIZE = 4096, parameter ADDR_WIDTH = 16, parameter WIDTH = 16) (
    input clk,
    input [ADDR_WIDTH-1:0] addr,
    input we,
    input [WIDTH-1:0] dat_in,
    output [WIDTH-1:0] dat_out
);

reg [WIDTH-1:0] mem [0:SIZE-1];

assign dat_out = mem[addr];

integer i;
initial begin
    for (i = 0; i < SIZE; i = i + 1) begin
        mem[i] = {WIDTH{1'b0}};
    end
end

always @(posedge clk) begin
    `ifdef DBG
        $display("  clk: RAM");
    `endif

    if (we)
        mem[addr] <= dat_in;
end

endmodule