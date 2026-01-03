module Register16 (
    input             clk, rst, en,
    input      [15:0] in,
    output reg [15:0] out
);
    always @(posedge clk or posedge rst) begin
        if (rst) out <= 0;
        else if (en) out <= in;
    end
endmodule