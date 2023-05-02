`timescale 1ns / 1ps

module ROM (
    input [15:0] addr, // address
    output [15:0] data // data at address
);

    reg [15:0] mem [0:8191];

    initial begin
        $readmemh("rom.hex", mem);
    end
    
    assign data = mem[addr];

endmodule