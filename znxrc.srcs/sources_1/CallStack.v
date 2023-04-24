module CallStack(
    input rst,
    input clk,
    input [15:0] program_counter_in,
    input zero_flag_in,
    input negative_flag_in,
    input push,
    input pop,
    output reg [15:0] program_counter_out,
    output reg zero_flag_out,
    output reg negative_flag_out
    );
    
    reg [3:0] memory_idx;
    reg [17:0] memory [0:15];
    
    always @(posedge clk) begin
        if (rst) begin
            memory_idx <= 0;
            program_counter_out <= 0;
            zero_flag_out <= 0;
            negative_flag_out <= 0;
        end else begin
            if (push) begin
                memory[memory_idx] = {zero_flag_in, negative_flag_in, program_counter_in};
                memory_idx <= memory_idx + 1;
            end else if (pop) begin
                memory_idx = memory_idx - 1;
                zero_flag_out <= memory[memory_idx][17];
                negative_flag_out <= memory[memory_idx][16];
                program_counter_out <= memory[memory_idx][15:0];
            end
        end
    end

endmodule
