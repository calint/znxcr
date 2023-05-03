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
    
    reg [3:0] idx;
    reg [17:0] mem [0:15];
    reg [15:0] pc_out_nxt;
    reg zf_out_nxt;
    reg nf_out_nxt;

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
            idx <= 4'hf;
        end else begin
            if (push) begin
                idx = idx + 1;
                mem[idx] = {zf_in, nf_in, pc_in};
                zf_out_nxt = zf_in;
                nf_out_nxt = nf_in;
                pc_out_nxt = pc_in;
             end else if (pop) begin
                idx = idx - 1;
                zf_out_nxt = mem[idx][17];
                nf_out_nxt = mem[idx][16];
                pc_out_nxt = mem[idx][15:0];
            end
        end
    end

endmodule