`timescale 1ns / 1ps

module CallStack(
    input rst,
    input clk,
    input [15:0] pc_in, // current program counter
    input zf_in, // current zero flag
    input nf_in, // current negative flag
    input push,
    input pop,
    output [15:0] pc_out, // popped program counter
    output zf_out, // popped zero flag
    output nf_out // popped negative flag
    );
    
    reg [3:0] mem_idx;
    reg [17:0] mem [0:15];
    
    assign zf_out = mem[mem_idx][17];
    assign nf_out = mem[mem_idx][16];
    assign pc_out = mem[mem_idx][15:0];
        
    always @(posedge clk) begin
        $display("  clk: CallStack: %0t", $realtime);
        if (rst) begin
            mem_idx <= 4'hf;
        end else begin
            if (push) begin
                mem_idx = mem_idx + 1;
                mem[mem_idx] = {zf_in, nf_in, pc_in};
 //               $display(" cs:push: [%d]",mem_idx,pc_in);
            end else if (pop) begin
                mem_idx = mem_idx - 1;
            end
        end
    end

endmodule
