module RegisterFile (
    input         clk,
    input         RegWrite,
    input  [2:0]  ReadReg1,
    input  [2:0]  ReadReg2,
    input  [2:0]  WriteReg, 
    input  [15:0] WriteData,
    output [15:0] ReadData1,
    output [15:0] ReadData2
);
    reg [15:0] registers [7:0];

    assign ReadData1 = registers[ReadReg1];
    assign ReadData2 = registers[ReadReg2];

    always @(posedge clk) begin
        if (RegWrite) begin
            registers[WriteReg] <= WriteData;
        end
    end
endmodule