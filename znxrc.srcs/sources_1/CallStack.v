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
    output wire [15:0] pc_out, // popped program counter
    output wire zf_out, // popped zero flag
    output wire nf_out // popped negative flag
    );
    
    reg [3:0] mem_idx;
    reg [17:0] mem [0:15];
    reg do_pop;
    
    assign zf_out = mem[mem_idx][17];
    assign nf_out = mem[mem_idx][16];
    assign pc_out = mem[mem_idx][15:0];

    always @(negedge clk) begin
        if (do_pop) begin
            mem_idx <= mem_idx - 1;
            do_pop <= 0;
        end
    end
        
    always @(posedge clk) begin
        if (rst) begin
            mem_idx <= 4'hf;
            do_pop <= 0;
        end else begin
            if (push) begin
                mem_idx = mem_idx + 1;
                mem[mem_idx] = {zf_in, nf_in, pc_in};
            end else if (pop) begin
                do_pop <= 1;
            end
        end
    end

endmodule
