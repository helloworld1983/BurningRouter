module cpu_test(
    input wire clk
);

reg [31:0] pc_data;
wire [31:0] pc_addr;
wire ce;
reg rst;

cpu CPU(
    .clk(clk),
    .rst(rst),
    .pc_data_i(pc_data),
    .pc_addr_o(pc_addr),
    .pc_ce_o(ce)
);

reg[31:0] ins_mem[0:32];

// simulate PC-RAM
always @(*) begin
    if (ce == 0) begin
        pc_data <= 0;
    end else begin
        pc_data <= ins_mem[pc_addr[7:2]];
    end
end


initial begin
    ins_mem[0] <= 32'h34038000; // ori $3, $0, 0x8000 (1) $3 = 0x8000
    ins_mem[1] <= 32'h00031c00; // sll $3, 16         (2) $3 = 0x80000000
    ins_mem[2] <= 32'h34010001; // ori $1, $0, 0x0001 (3) $1 = 1
    ins_mem[3] <= 32'h10000004; // beq $0, $0, 0x0004 (4) to 8
    ins_mem[4] <= 32'h34010002; // (5) $1 = 2
    ins_mem[5] <= 32'h3401ffff;
    ins_mem[6] <= 32'h3401ffff;
    ins_mem[7] <= 32'h3401ffff;
    ins_mem[8] <= 32'h34010003; // (6) $1 = 3
    ins_mem[9] <= 32'h14200004; // bne $1, $0, 0x0004
    ins_mem[10] <= 32'h34010004; // (7) $1 = 4
    ins_mem[11] <= 32'h3401ffff;
    ins_mem[12] <= 32'h3401ffff;
    ins_mem[13] <= 32'h3401ffff;
    ins_mem[14] <= 32'h34010005; // (8) $1 = 5
    ins_mem[15] <= 32'h1C600004; // (9) bgtz $3, 0x0004
    ins_mem[16] <= 32'h34010006; // (10) $1 = 6
    ins_mem[17] <= 32'h34010007; // (11) $1 = 7
    ins_mem[18] <= 32'h1C000004; // (12) bgtz $0, 0x0004
    ins_mem[19] <= 32'h34010008; // (13) $1 = 8
    ins_mem[20] <= 32'h34010009; // (14) $1 = 9
    ins_mem[21] <= 32'h1C200004; // (15) bgtz $1, 0x0004
    ins_mem[22] <= 32'h3401000a; // (16) $1 = a
    ins_mem[23] <= 32'h3401ffff;
    ins_mem[24] <= 32'h3401ffff;
    ins_mem[25] <= 32'h3401ffff;
    ins_mem[26] <= 32'h3401000b; // (17) $1 = b
    ins_mem[27] <= 32'h14000004; // (18) bne $0, $0, 0x0004
    ins_mem[28] <= 32'h3401000c; // (19) $1 = c
    ins_mem[29] <= 32'h3401000d; // (20) $1 = d
    ins_mem[30] <= 32'h10200004; // (21) beq $1, $0, 0x0004
    ins_mem[31] <= 32'h3401000e; // (22) $1 = e
    ins_mem[32] <= 32'h3401000f; // (23) $1 = f
    rst <= 1;
    #10000
    rst <= 0;
end

endmodule