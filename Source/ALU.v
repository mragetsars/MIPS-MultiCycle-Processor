module ALU (
    input      [15:0] In1,
    input      [15:0] In2,
    input      [2:0]  ALUOp,
    output reg [15:0] Out,
    output            Zero
);
    assign Zero = (Out == 0);

    always @(*) begin
        case (ALUOp)
            3'b000: Out = In1 + In2;
            3'b001: Out = In1 - In2;
            3'b010: Out = In1 & In2;
            3'b011: Out = In1 | In2;
            3'b100: Out = ~In1;
            3'b101: Out = In1;
            3'b110: Out = In2;
            default: Out = 16'b0;
        endcase
    end
endmodule