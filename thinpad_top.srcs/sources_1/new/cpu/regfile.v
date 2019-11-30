module regfile(
    input wire clk,
    input wire rst,

    input wire we,
    input wire [4:0] waddr,
    input wire [31:0] wdata,

    input wire re1,
    input wire [4:0] raddr1,
    output reg [31:0] rdata1,

    input wire re2,
    input wire [4:0] raddr2,
    output reg [31:0] rdata2
);

reg[31:0] regs[31:0];

// write
always @(posedge clk) begin
    if (rst == 1'b0) begin
        if (we == 1'b1 && waddr != 5'b00000) begin
            regs[waddr] <= wdata;
            $display("write %h to reg %d", wdata, waddr);
        end
    end
end

// read1
always @(*) begin
    if (rst == 1'b1) begin
        rdata1 <= 0;
    end else if (re1 ==  1'b1) begin
        if (raddr1 == 5'b00000) begin // must check first, think waddr = 0, we = 1, wdata != 0
            rdata1 <= 0;
        end else if (raddr1 == waddr && we == 1'b1) begin
            rdata1 <= wdata;
        end else begin
            rdata1 <= regs[raddr1];
        end
    end else begin
        rdata1 <= 0;
    end
end

// read2, copy from read1, change 1 to 2
always @(*) begin
    if (rst == 1'b1) begin
        rdata2 <= 0;
    end else if (re2 == 1'b1) begin
        if (raddr2 == 5'b00000) begin // must check first, think waddr = 0, we = 1, wdata != 0
            rdata2 <= 0;
        end else if (raddr2 == waddr && we == 1'b1) begin
            rdata2 <= wdata;
        end else begin
            rdata2 <= regs[raddr2];
        end
    end else begin
        rdata2 <= 0;
    end
end

endmodule