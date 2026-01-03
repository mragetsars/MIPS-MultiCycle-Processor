module Memory (
    input         clk, we,
    input  [15:0] addr,
    input  [15:0] din,
    output [15:0] dout
);
    reg [15:0] ram [0:4095];

    initial begin
        $readmemh("program.mem", ram);
    end

    assign dout = ram[addr[11:0]];

    always @(posedge clk) begin
        if (we) ram[addr[11:0]] <= din;
    end
endmodule