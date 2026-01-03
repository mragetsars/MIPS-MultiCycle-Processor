module ZeroExtend_12to16 (
    input  [11:0] In,
    output [15:0] Out
);
    assign Out = {4'b0000, In};
endmodule

module BranchTargetCalc (
    input  [15:0] PC_Current,
    input  [8:0]  Offset,
    output [15:0] BranchAddress
);
    assign BranchAddress = {PC_Current[15:9], Offset};
endmodule