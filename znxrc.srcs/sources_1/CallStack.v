`timescale 1ns / 1ps

module CallStack #(parameter SIZE = 16, parameter ADDR_WIDTH = 4, parameter WIDTH = 16) (
    input rst,
    input clk,
    input [WIDTH-1:0] pc_in, // current program counter
    input zf_in, // current zero flag
    input nf_in, // current negative flag
    input push,
    input pop,
    output reg [WIDTH-1:0] pc_out, // top of stack program counter
    output reg zf_out, // top of stack zero flag
    output reg nf_out // top of stack negative flag
    );

reg [ADDR_WIDTH-1:0] idx;
reg [WIDTH+1:0] mem [0:SIZE-1];
reg [WIDTH-1:0] pc_out_nxt;
reg zf_out_nxt;
reg nf_out_nxt;

integer i;
initial begin
    for (i = 0; i < SIZE; i = i + 1) begin
        mem[i] = {(WIDTH+2){1'b0}};
    end
end

always @(negedge clk) begin
    pc_out <= pc_out_nxt;
    zf_out <= zf_out_nxt;
    nf_out <= nf_out_nxt;
end

always @(posedge clk) begin
    `ifdef DBG
        $display("  clk: CallStack");
    `endif

    if (rst) begin
        idx <= {ADDR_WIDTH{1'b1}};
    end else begin
        if (push) begin
            idx = idx + 1;
            mem[idx] <= {zf_in, nf_in, pc_in};
            zf_out_nxt <= zf_in;
            nf_out_nxt <= nf_in;
            pc_out_nxt <= pc_in;
        end else if (pop) begin
            idx = idx - 1;
            zf_out_nxt <= mem[idx][WIDTH+1];
            nf_out_nxt <= mem[idx][WIDTH];
            pc_out_nxt <= mem[idx][WIDTH-1:0];
        end
    end
end

endmodule