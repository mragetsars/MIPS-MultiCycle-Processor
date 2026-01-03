`timescale 1ns / 1ps

module tb_Processor;

    reg clk;
    reg rst;

    TopModule uut (
        .clk(clk),
        .rst(rst)
    );

    localparam CLK_PERIOD = 10;

    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin

        rst = 1;
        #20;
        rst = 0; 
        
        $display("--- Simulation Started using external file 'program.mem' ---");
        
        #3000; 

        $display("\n========================================");
        $display(" Sum result is %d ", uut.DP.RF.registers[0]);
        $display("\n========================================");

        $stop;
    end

    initial begin
        $monitor("Time=%0t | PC=%h | IR=%h | State=%d | R0(Acc)=%d", 
                 $time, uut.DP.PC_Out, uut.DP.Instruction_Out, uut.CU.current_state, 
                 uut.DP.RF.registers[0]);
    end

endmodule