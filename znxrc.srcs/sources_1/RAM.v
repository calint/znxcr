`timescale 1ns / 1ps
`default_nettype none

module RAM #(parameter ADDR_WIDTH = 16, parameter WIDTH = 16) (
    input wire clk,
    input wire [ADDR_WIDTH-1:0] addr,
    input wire we,
    input wire [WIDTH-1:0] dat_in,
    output wire [WIDTH-1:0] dat_out
);

reg [WIDTH-1:0] mem [0:2**ADDR_WIDTH-1];

assign dat_out = mem[addr];

integer i;
initial begin
    for (i = 0; i < 2**ADDR_WIDTH; i = i + 1) begin
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

`default_nettype wire
