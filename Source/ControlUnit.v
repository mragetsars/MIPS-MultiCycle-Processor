module ControlUnit (
    input             clk, rst,
    input      [15:0] Instruction,
    input             Zero,
    
    output reg        PCWrite,
    output reg        IRWrite,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        IorD,
    output reg        RegWrite,
    output reg        MemtoReg,
    output reg [1:0]  ALUSrcB,
    output reg [2:0]  ALUOp,
    output reg        RegDst,
    output     [1:0]  PCSource_Out_Sig 
);

    parameter FETCH = 0, DECODE = 1, MEM_ADDR = 2, MEM_READ = 3, MEM_WB = 4, 
              MEM_WRITE = 5, EXEC_TYPE_C = 6, EXEC_TYPE_D = 7, 
              WB_ALU = 8, BRANCH = 9, JUMP = 10;

    reg  [3:0] current_state, next_state;

    wire [3:0] Opcode = Instruction[15:12];
    wire [8:0] Func = Instruction[8:0];

    always @(posedge clk or posedge rst) begin
        if (rst) current_state <= FETCH;
        else current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            FETCH: next_state = DECODE;
            
            DECODE: begin
                case (Opcode)
                    4'b0000: next_state = MEM_ADDR;
                    4'b0001: next_state = MEM_ADDR;
                    4'b0010: next_state = JUMP;
                    4'b0100: next_state = BRANCH;
                    4'b1000: next_state = EXEC_TYPE_C;
                    4'b1100, 4'b1101, 4'b1110, 4'b1111: next_state = EXEC_TYPE_D;
                    default: next_state = FETCH;
                endcase
            end

            MEM_ADDR: begin
                if (Opcode == 4'b0000) next_state = MEM_READ;
                else next_state = MEM_WRITE;
            end

            MEM_READ: next_state = MEM_WB;
            MEM_WB: next_state = FETCH;
            MEM_WRITE: next_state = FETCH;

            EXEC_TYPE_C: next_state = WB_ALU;
            EXEC_TYPE_D: next_state = WB_ALU;
            WB_ALU: next_state = FETCH;
            
            BRANCH: next_state = FETCH;
            JUMP: next_state = FETCH;
            
            default: next_state = FETCH;
        endcase
    end

    always @(*) begin
        PCWrite = 0; IRWrite = 0; MemRead = 0; MemWrite = 0;
        IorD = 0; RegWrite = 0; MemtoReg = 0; ALUSrcB = 2'b00;
        ALUOp = 3'b000; RegDst = 0;

        case (current_state)
            FETCH: begin
                MemRead = 1;
                IRWrite = 1;
                IorD = 0;
                PCWrite = 1;
            end

            DECODE: begin
            end

            MEM_ADDR: begin
            end

            MEM_READ: begin
                MemRead = 1;
                IorD = 1;
            end

            MEM_WB: begin
                RegWrite = 1;
                MemtoReg = 1;
                RegDst = 0;
            end

            MEM_WRITE: begin
                MemWrite = 1;
                IorD = 1;
            end

            EXEC_TYPE_C: begin
                ALUSrcB = 2'b00;
                if (Func[0]) ALUOp = 3'b101;
                else if (Func[1]) ALUOp = 3'b110;
                else if (Func[2]) ALUOp = 3'b000;
                else if (Func[3]) ALUOp = 3'b001;
                else if (Func[4]) ALUOp = 3'b010;
                else if (Func[5]) ALUOp = 3'b011;
                else if (Func[6]) ALUOp = 3'b100;
                else ALUOp = 3'b000;
            end

            EXEC_TYPE_D: begin
                ALUSrcB = 2'b01;
                case (Opcode)
                    4'b1100: ALUOp = 3'b000;
                    4'b1101: ALUOp = 3'b001;
                    4'b1110: ALUOp = 3'b010;
                    4'b1111: ALUOp = 3'b011;
                    default: ALUOp = 3'b000;
                endcase
            end

            WB_ALU: begin
                RegWrite = 1;
                MemtoReg = 0;
                if (Opcode == 4'b1000 && Func[0] == 1)
                    RegDst = 1;
                else
                    RegDst = 0;
            end

            BRANCH: begin
                ALUSrcB = 2'b00;
                ALUOp = 3'b001;
                if (Zero) begin
                    PCWrite = 1; 
                end
            end
            
            JUMP: begin
                PCWrite = 1;
            end
        endcase
    end

    assign PCSource_Out_Sig = (current_state == JUMP) ? 2'b01 : 
                              ((current_state == BRANCH && Zero) ? 2'b10 : 2'b00);

endmodule