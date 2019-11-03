module id_ex (
    input wire clk,
    input wire rst,

    input wire [7:0] id_aluop,
    input wire [2:0] id_alusel,
    input wire [31:0] id_reg1,
    input wire [31:0] id_reg2,
    input wire [4:0] id_wd,
    input wire id_wreg,
    input wire id_is_in_delayslot,
    input wire [31:0] id_link_addr,
    input wire next_inst_in_delayslot_i,
    input wire [31:0] id_ram_offset,

    output reg[7:0] ex_aluop,
    output reg[2:0] ex_alusel,
    output reg[31:0] ex_reg1,
    output reg[31:0] ex_reg2,
    output reg[4:0] ex_wd,
    output reg ex_wreg,
    output reg ex_is_in_delayslot,
    output reg[31:0] ex_link_addr,
    output reg is_in_delayslot_o, // id's input
    output reg [31:0] ex_ram_offset
);

always @(posedge clk) begin
    if (rst == 1'b1) begin
        ex_aluop <= 0;
        ex_alusel <=0;
        ex_reg1 <= 0;
        ex_reg2 <= 0;
        ex_wd <= 0;
        ex_wreg <= 0;
        ex_is_in_delayslot <= 0;
        ex_link_addr <= 0;
        is_in_delayslot_o <= 0;
        ex_ram_offset <= 0;
    end else begin
        ex_aluop <= id_aluop;
        ex_alusel <= id_alusel;
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_wd <= id_wd;
        ex_wreg <= id_wreg;
        ex_is_in_delayslot <= id_is_in_delayslot;
        ex_link_addr <= id_link_addr;
        is_in_delayslot_o <= next_inst_in_delayslot_i;
        ex_ram_offset <= id_ram_offset;
    end
end

endmodule