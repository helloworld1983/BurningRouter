//instruction
// ALU
`define EXE_SPECIAL 6'b000000
`define EXE_REGIMM 6'b000001
`define EXE_SLL_FUNC 6'b000000
`define EXE_SRL_FUNC 6'b000010
`define EXE_SRA_FUNC 6'b000011
`define EXE_ADDU_FUNC 6'b100001
`define EXE_SUBU_FUNC 6'b100011
`define EXE_SLT_FUNC 6'b101010
`define EXE_SLTU_FUNC 6'b101011
`define EXE_AND_FUNC  6'b100100
`define EXE_OR_FUNC   6'b100101
`define EXE_XOR_FUNC 6'b100110
`define EXE_NOR_FUNC 6'b100111
`define EXE_MOVZ_FUNC 6'b001010
`define EXE_SLLV_FUNC 6'b000100
`define EXE_SRLV_FUNC 6'b000110
`define EXE_ADDIU 6'b001001
`define EXE_SLTI 6'b001010
`define EXE_SLTIU 6'b001011
`define EXE_ANDI 6'b001100
`define EXE_ORI  6'b001101
`define EXE_XORI 6'b001110
`define EXE_LUI 6'b001111


//AluOp
`define EXE_LB_OP 8'b00100000
`define EXE_LBU_OP 8'b01100100
`define EXE_LW_OP 8'b00100011
`define EXE_LH_OP 8'b01100001
`define EXE_LHU_OP 8'b01100101
`define EXE_SH_OP 8'b00101001
`define EXE_SW_OP 8'b00101011
`define EXE_SB_OP 8'b00101000

`define EXE_ADDU_OP  8'b00100001
`define EXE_SUBU_OP 8'b01100011
`define EXE_SLT_OP 8'b00101010
`define EXE_SLTU_OP 8'b01101011
`define EXE_AND_OP   8'b00100100
`define EXE_OR_OP    8'b00100101
`define EXE_XOR_OP   8'b00100110
`define EXE_NOR_OP   8'b00100111
// LUI: rt <= imm is same as rt <= imm|imm

`define EXE_SLL_OP  8'b01111100
`define EXE_SRL_OP  8'b00000010
`define EXE_SRA_OP  8'b00000011
`define EXE_BRANCH_OP 8'b01000010
`define EXE_NOP_OP    8'b00000000

`define EXE_MFC0_OP 8'b01011101
`define EXE_MTC0_OP 8'b01100000
`define EXE_MOVZ_OP 8'b00001010

//AluSel
`define EXE_RES_LOGIC 3'b001
`define EXE_RES_SHIFT 3'b010
`define EXE_RES_NOP 3'b000
`define EXE_RES_ARITHMETIC 3'b011
`define EXE_RES_BRANCH 3'b100
`define EXE_RES_RAM 3'b101
`define EXE_RES_MOVE 3'b110

// branch & jump
`define EXE_JUMP 6'b000010
`define EXE_JAL 6'b000011
`define EXE_JR_FUNC 6'b001000
`define EXE_BEQ 6'b000100
`define EXE_BNE 6'b000101
`define EXE_BGTZ 6'b000111
`define EXE_BLTZ 5'b00000
`define EXE_BGEZAL 5'b10001
`define EXE_BGEZ 5'b00001


// RAM
`define EXE_LB 6'b100000
`define EXE_LBU 6'b100100
`define EXE_LW 6'b100011
`define EXE_LH 6'b100001
`define EXE_LHU 6'b100101
`define EXE_SB 6'b101000
`define EXE_SH 6'b101001
`define EXE_SW 6'b101011

// CP0
`define EXE_COP 6'b010000
`define EXE_MT 5'b00100
`define EXE_MF 5'b00000
`define EXE_ERET 5'b10000
`define EXE_ERET_32 32'b01000010000000000000000000011000
`define EXE_SYSCALL_FUNC 6'b001100
`define EXE_SYSCALL_OP 8'b00001100
`define EXE_ERET_OP 8'b01101011
`define CP0_REG_STATUS 5'b01100
`define CP0_REG_CAUSE 5'b01101
`define CP0_REG_EPC 5'b01110
`define CP0_REG_EBASE 5'b01111
