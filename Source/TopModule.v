module TopModule (
    input clk,
    input rst
);
    wire        PCWrite, IRWrite, MemWrite, MemRead, IorD, RegWrite, MemtoReg, RegDst, Zero;
    wire [1:0]  ALUSrcB, PCSource;
    wire [2:0]  ALUOp;
    wire [15:0] MemAddress, MemWriteData, MemReadData, Instruction;

    Datapath DP (
        .clk(clk), .rst(rst),
        .PCWrite(PCWrite), .IRWrite(IRWrite), .MemWrite(MemWrite),
        .PCSource(PCSource), .IorD(IorD), .RegWrite(RegWrite),
        .MemtoReg(MemtoReg), .ALUSrcB(ALUSrcB), .ALUOp(ALUOp), .RegDst(RegDst),
        .MemReadData(MemReadData), .MemAddress(MemAddress),
        .MemWriteData(MemWriteData), .Instruction_Out(Instruction),
        .ZeroFlag(Zero)
    );

    ControlUnit CU (
        .clk(clk), .rst(rst),
        .Instruction(Instruction), .Zero(Zero),
        .PCWrite(PCWrite), .IRWrite(IRWrite), .MemRead(MemRead),
        .MemWrite(MemWrite), .IorD(IorD), .RegWrite(RegWrite),
        .MemtoReg(MemtoReg), .ALUSrcB(ALUSrcB), .ALUOp(ALUOp), .RegDst(RegDst),
        .PCSource_Out_Sig(PCSource)
    );

    Memory MEM (
        .clk(clk),
        .we(MemWrite),
        .addr(MemAddress),
        .din(MemWriteData),
        .dout(MemReadData)
    );
endmodule