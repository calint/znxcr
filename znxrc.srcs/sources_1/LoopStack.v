module LoopStack(
    input rst,
    input clk,
    input new_loop,
    input next,
    input [15:0] count,
    input [15:0] loop_address,
    output reg loop_finished,
    output reg [15:0] jmp_address
    );
    
    reg [3:0] stack_idx;
    reg [15:0] stack_loop_address [0:15];
    reg [15:0] stack_loop_counter [0:15];

    always @(posedge clk) begin
        if (rst) begin
            stack_idx <= 0;
            loop_finished <= 0;
            jmp_address <= 0;
        end else begin
            if (new_loop) begin
                stack_idx = stack_idx + 1;
                stack_loop_address[stack_idx] <= loop_address;
                stack_loop_counter[stack_idx] <= count;
                loop_finished <= 0;
            end else if (next) begin
                stack_loop_counter[stack_idx] = stack_loop_counter[stack_idx] - 1;
                if (stack_loop_counter[stack_idx] === 0) begin
                    loop_finished <= 1;
                    stack_idx = stack_idx - 1;
                    jmp_address <= stack_loop_address[stack_idx];
                end else begin
                    loop_finished <= 0;
                end
            end
        end
    end
    
endmodule
