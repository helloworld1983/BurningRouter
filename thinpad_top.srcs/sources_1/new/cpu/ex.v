`include "def_op.v"

module ex(
    input wire rst,

    input wire [7:0] aluop_i,
    input wire [2:0] alusel_i,
    input wire [31:0] reg1_i,
    input wire [31:0] reg2_i,
    input wire [4:0] wd_i,
    input wire wreg_i,
    input wire [31:0] link_addr_i,
    input wire is_in_delayslot,
    input wire [31:0] ram_offset_i,

    output reg[4:0] wd_o,
    output reg wreg_o,
    output reg[31:0] wdata_o,
    output reg[7:0] aluop_o,
    output reg[31:0] ram_addr_o
);

reg[31:0] logicout, shiftout, arithout, ramout;

always @(*) begin
    if (rst == 1'b1) begin
        logicout <= 0;
    end else begin
        case (aluop_i)
            `EXE_AND_OP: begin
                logicout <= reg1_i & reg2_i;
            end
            `EXE_OR_OP: begin
                logicout <= reg1_i | reg2_i;
            end
            `EXE_XOR_OP: begin
                logicout <= reg1_i ^ reg2_i;
            end
            default: begin
                logicout <= 0;
            end
        endcase
    end
end


always @(*) begin
    if (rst == 1'b1) begin
        shiftout <= 0;
    end else begin
        case (aluop_i)
            `EXE_SLL_OP: begin
                shiftout <= reg2_i << reg1_i[4:0];
            end
            `EXE_SRL_OP: begin
                shiftout <= reg2_i >> reg1_i[4:0];
            end
            default: begin
                shiftout <= 0;
            end
        endcase
    end
end

always @(*) begin
    if (rst == 1'b1) begin
        arithout <= 0;
    end else begin
        case (aluop_i)
            `EXE_ADDU_OP: begin
                arithout <= reg1_i + reg2_i;
            end
            default: begin
                arithout <= 0;
            end
        endcase
    end
end

always @(*) begin
    if (rst == 1'b1) begin
        ramout <= 0;
    end else begin
        ramout <= 0;
        case (aluop_i)
            `EXE_SB_OP: begin
                ramout <= reg2_i;
            end
            `EXE_SW_OP: begin
                ramout <= reg2_i;
            end
        endcase
    end
end

always @(*) begin
    wd_o <= wd_i;
    wreg_o <= wreg_i;
    ram_addr_o <= alusel_i == `EXE_RES_RAM ? ram_offset_i + reg1_i : 0;
    aluop_o <= aluop_i;
    case (alusel_i)
        `EXE_RES_LOGIC: begin
            wdata_o <= logicout;
        end
        `EXE_RES_SHIFT: begin
            wdata_o <= shiftout;
        end
        `EXE_RES_ARITHMETIC: begin
            wdata_o <= arithout;
        end
        `EXE_RES_BRANCH: begin
            wdata_o <= link_addr_i;
        end
        `EXE_RES_RAM: begin
            wdata_o <= ramout;
        end
        default: begin
            $display("[ex.v] aluop %h not support", aluop_i);
            wdata_o <= 0;
        end
    endcase
end

endmodule