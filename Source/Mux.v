module Mux2to1_16bit (
    input  [15:0] i0, i1,
    input         sel,
    output [15:0] out
);
    assign out = sel ? i1 : i0;
endmodule

module Mux2to1_3bit (
    input  [2:0] i0, i1,
    input        sel,
    output [2:0] out
);
    assign out = sel ? i1 : i0;
endmodule

module Mux4to1_16bit (
    input      [15:0] i0, i1, i2, i3,
    input      [1:0]  sel,
    output reg [15:0] out
);
    always @(*) begin
        case(sel)
            2'b00: out = i0;
            2'b01: out = i1;
            2'b10: out = i2;
            2'b11: out = i3;
        endcase
    end
endmodule