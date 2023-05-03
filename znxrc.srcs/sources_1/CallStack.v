`timescale 1ns / 1ps

module CallStack(
    input rst,
    input clk,
    input [15:0] pc_in, // current program counter
    input zf_in, // current zero flag
    input nf_in, // current negative flag
    input push,
    input pop,
    output reg [15:0] pc_out, // top of stack program counter
    output reg zf_out, // top of stack zero flag
    output reg nf_out // top of stack negative flag
    );
    
    reg [3:0] mem_idx;
    reg [17:0] mem [0:15];
    
    always @(posedge clk) begin
        $display("  clk: CallStack");
        if (rst) begin
            mem_idx <= 4'hf;
        end else begin
            zf_out = mem[mem_idx][17];
            nf_out = mem[mem_idx][16];
            pc_out = mem[mem_idx][15:0];
            if (push) begin
                mem_idx = mem_idx + 1;
                mem[mem_idx] = {zf_in, nf_in, pc_in};
            end else if (pop) begin
                mem_idx = mem_idx - 1;
            end
        end
    end

endmodule