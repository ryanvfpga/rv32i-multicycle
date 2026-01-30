`timescale 1ns / 1ps

module cpu_tb;

    reg clk;
    reg rst;
    integer i;

    cpu uut (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        // Clear CPU Register File [cite: 89, 115]
        for (i = 0; i < 32; i = i + 1) uut.dp.rf.regs[i] = 0;
        
        // Clear Memory [cite: 104]
        for (i = 0; i < 512; i = i + 1) uut.dp.mem_inst.regs[i] = 0;

        // SET INPUT: Calculate up to N = 10
        uut.dp.rf.regs[31] = 10; 

        #20 rst = 0;

        // =====================================================
        // FIBONACCI PROGRAM (Manual Hex Assembly)
        // =====================================================
        uut.dp.mem_inst.regs[0]  = 32'h00000513; // ADDI x10, x0, 0
        uut.dp.mem_inst.regs[1]  = 32'h020f8663; // BEQ x31, x0, 52 (End) [cite: 100]
        uut.dp.mem_inst.regs[2]  = 32'h00100513; // ADDI x10, x0, 1
        uut.dp.mem_inst.regs[3]  = 32'h00100293; // ADDI x5, x0, 1
        uut.dp.mem_inst.regs[4]  = 32'h025f8463; // BEQ x31, x5, 40 (End)

        uut.dp.mem_inst.regs[5]  = 32'h00000093; // ADDI x1, x0, 0
        uut.dp.mem_inst.regs[6]  = 32'h00100113; // ADDI x2, x0, 1
        uut.dp.mem_inst.regs[7]  = 32'h00200193; // ADDI x3, x0, 2

        uut.dp.mem_inst.regs[8]  = 32'h003fcc63; // BLT x31, x3, 24 (End) [cite: 100]
        uut.dp.mem_inst.regs[9]  = 32'h00208533; // ADD x10, x1, x2
        uut.dp.mem_inst.regs[10] = 32'h00010093; // ADDI x1, x2, 0
        uut.dp.mem_inst.regs[11] = 32'h00050113; // ADDI x2, x10, 0
        uut.dp.mem_inst.regs[12] = 32'h00118193; // ADDI x3, x3, 1
        uut.dp.mem_inst.regs[13] = 32'hfedff06f; // JAL x0, -20 (Loop) [cite: 101]

        uut.dp.mem_inst.regs[14] = 32'h0000006f; // JAL x0, 0 (Halt)

        // Wait for multi-cycle execution to complete [cite: 13, 16]
        #5000;

        $display("\n====================================================");
        $display("          RISC-V CPU VERIFICATION REPORT          ");
        $display("====================================================");
        $display(" Input (N) : %0d", uut.dp.rf.regs[31]);
        $display(" Output    : %0d", uut.dp.rf.regs[10]);
        $display("----------------------------------------------------");
        
        if (uut.dp.rf.regs[10] == 55) begin
            $display(" STATUS    : [  PASSED  ] ");
        end else begin
            $display(" STATUS    : [  FAILED  ] ");
            $display(" REMARK    : Expected 55.");
        end
            
        $display("====================================================\n");
        $finish;
    end

endmodule