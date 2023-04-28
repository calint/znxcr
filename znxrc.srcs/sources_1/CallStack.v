`timescale 1ns / 1ps
`default_nettype none

module CallStack(
    input wire rst,
    input wire clk,
    input wire [15:0] pc_in, // current program counter
    input wire zf_in, // current zero flag
    input wire nf_in, // current negative flag
    input wire push,
    input wire pop,
    output reg [15:0] pc_out, // popped program counter
    output reg zf_out, // popped zero flag
    output reg nf_out // popped negative flag
    );
    
    reg [3:0] mem_idx;
    reg [17:0] mem [0:15];
    
    always @(posedge clk) begin
        if (rst) begin
            mem_idx <= 0;
            pc_out <= 0;
            zf_out <= 0;
            nf_out <= 0;
        end else begin
            if (push) begin
                mem[mem_idx] = {zf_in, nf_in, pc_in};
                mem_idx = mem_idx + 1;
            end else if (pop) begin
                mem_idx = mem_idx - 1;
                zf_out = mem[mem_idx][17];
                nf_out = mem[mem_idx][16];
                pc_out = mem[mem_idx][15:0];
            end
        end
    end

endmodule
