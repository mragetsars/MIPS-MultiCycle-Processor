module Datapath (
    input clk, rst,

    input         PCWrite,
    input         IRWrite,
    input         MemWrite, 
    input  [1:0]  PCSource,
    input         IorD,
    input         RegWrite,
    input         MemtoReg,
    input  [1:0]  ALUSrcB,
    input  [2:0]  ALUOp,
    input         RegDst,
    
    input  [15:0] MemReadData,
    output [15:0] MemAddress,
    output [15:0] MemWriteData,
    output [15:0] Instruction_Out,
    output        ZeroFlag
);

    wire   [15:0] PC_Out, PC_In;
    wire   [15:0] PC_Plus_1;
    wire   [15:0] Jump_Target;
    wire   [15:0] Branch_Target;
    wire   [15:0] Const_1, Const_0;

    wire   [15:0] IR_Out, MDR_Out;
    wire   [15:0] IR_Address_Ext;

    wire   [2:0]  WriteRegAddr;
    wire   [2:0]  ReadReg2_Addr;
    wire   [15:0] WriteData_Reg;
    wire   [15:0] ReadData1, ReadData2;
    wire   [15:0] A_Out, B_Out;

    wire   [15:0] Imm_SignExt;
    wire   [15:0] SrcA, SrcB;
    wire   [15:0] ALU_Out, ALU_Result_Reg;

    Constant_1 C1 (.One(Const_1));
    Constant_0 C0 (.Zero(Const_0));

    Adder16 PC_Inc_Adder (
        .A(PC_Out), 
        .B(Const_1), 
        .Sum(PC_Plus_1)
    );

    ZeroExtend_12to16 Jump_Ext (
        .In(IR_Out[11:0]),
        .Out(Jump_Target)
    );

    BranchTargetCalc Branch_Calc (
        .PC_Current(PC_Out),
        .Offset(IR_Out[8:0]),
        .BranchAddress(Branch_Target)
    );

    Mux4to1_16bit PCMux (
        .i0(PC_Plus_1), 
        .i1(Jump_Target), 
        .i2(Branch_Target), 
        .i3(Const_0),
        .sel(PCSource), 
        .out(PC_In)
    );
    
    Register16 PC (
        .clk(clk), .rst(rst), .en(PCWrite), .in(PC_In), .out(PC_Out)
    );

    ZeroExtend_12to16 Mem_Addr_Ext (
        .In(IR_Out[11:0]),
        .Out(IR_Address_Ext)
    );

    Mux2to1_16bit AdrMux (
        .i0(PC_Out), 
        .i1(IR_Address_Ext), 
        .sel(IorD), 
        .out(MemAddress)
    );
    
    Register16 IR (.clk(clk), .rst(rst), .en(IRWrite), .in(MemReadData), .out(IR_Out));

    assign Instruction_Out = IR_Out; 

    Register16 MDR (.clk(clk), .rst(rst), .en(Const_1[0]), .in(MemReadData), .out(MDR_Out));

    Mux2to1_3bit RegDstMux (
        .i0(3'b000),
        .i1(IR_Out[11:9]),
        .sel(RegDst),
        .out(WriteRegAddr)
    );
    
    Mux2to1_16bit WDMux (
        .i0(ALU_Result_Reg), 
        .i1(MDR_Out), 
        .sel(MemtoReg), 
        .out(WriteData_Reg)
    );

    RegisterFile RF (
        .clk(clk),
        .RegWrite(RegWrite),
        .ReadReg1(3'b000),
        .ReadReg2(IR_Out[11:9]), 
        .WriteReg(WriteRegAddr),
        .WriteData(WriteData_Reg),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    Register16 RegA (.clk(clk), .rst(rst), .en(Const_1[0]), .in(ReadData1), .out(A_Out));
    Register16 RegB (.clk(clk), .rst(rst), .en(Const_1[0]), .in(ReadData2), .out(B_Out));
    
    assign MemWriteData = A_Out; 

    assign SrcA = A_Out;

    ZeroExtend_12to16 Imm_Ext (
        .In(IR_Out[11:0]),
        .Out(Imm_SignExt)
    );

    Mux4to1_16bit SrcBMux (
        .i0(B_Out), 
        .i1(Imm_SignExt), 
        .i2(Const_0), 
        .i3(Const_0), 
        .sel(ALUSrcB), 
        .out(SrcB)
    );

    ALU MainALU (
        .In1(SrcA),
        .In2(SrcB),
        .ALUOp(ALUOp),
        .Out(ALU_Out),
        .Zero(ZeroFlag)
    );

    Register16 ALUOutReg (.clk(clk), .rst(rst), .en(Const_1[0]), .in(ALU_Out), .out(ALU_Result_Reg));

endmodule