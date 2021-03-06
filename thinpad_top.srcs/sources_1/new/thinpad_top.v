`default_nettype none

module thinpad_top(
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入

    input wire clock_btn,         //BTN5手动时钟按钮开关，带消抖电路，按下时为1
    input wire reset_btn,         //BTN6手动复位按钮开关，带消抖电路，按下时为1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4，按钮开关，按下时为1
    input  wire[31:0] dip_sw,     //32位拨码开关，拨到“ON”时为1
    output wire[15:0] leds,       //16位LED，输出时1点亮
    output wire[7:0]  dpy0,       //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0]  dpy1,       //数码管高位信号，包括小数点，输出1点亮

    //CPLD串口控制器信号
    output wire uart_rdn,         //读串口信号，低有效
    output wire uart_wrn,         //写串口信号，低有效
    input wire uart_dataready,    //串口数据准备好
    input wire uart_tbre,         //发送数据标志
    input wire uart_tsre,         //数据发送完毕标志

    //BaseRAM信号
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享
    output wire[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire base_ram_ce_n,       //BaseRAM片选，低有效
    output wire base_ram_oe_n,       //BaseRAM读使能，低有效
    output wire base_ram_we_n,       //BaseRAM写使能，低有效

    //ExtRAM信号
    inout wire[31:0] ext_ram_data,  //ExtRAM数据
    output wire[19:0] ext_ram_addr, //ExtRAM地址
    output wire[3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire ext_ram_ce_n,       //ExtRAM片选，低有效
    output wire ext_ram_oe_n,       //ExtRAM读使能，低有效
    output wire ext_ram_we_n,       //ExtRAM写使能，低有效

    //直连串口信号
    output wire txd,  //直连串口发送端
    input  wire rxd,  //直连串口接收端

    //Flash存储器信号，参考 JS28F640 芯片手册
    output wire [22:0]flash_a,      //Flash地址，a0仅在8bit模式有效，16bit模式无意义
    inout  wire [15:0]flash_d,      //Flash数据
    output wire flash_rp_n,         //Flash复位信号，低有效
    output wire flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧写
    output wire flash_ce_n,         //Flash片选信号，低有效
    output wire flash_oe_n,         //Flash读使能信号，低有效
    output wire flash_we_n,         //Flash写使能信号，低有效
    output wire flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1

    //USB+SD 控制器信号，参考 CH376T 芯片手册
    output wire ch376t_sdi,
    output wire ch376t_sck,
    output wire ch376t_cs_n,
    output wire ch376t_rst,
    input  wire ch376t_int_n,
    input  wire ch376t_sdo,

    //网络交换机信号，参考 KSZ8795 芯片手册与 RGMII 规范
    input  wire [3:0] eth_rgmii_rd,
    input  wire eth_rgmii_rx_ctl,
    input  wire eth_rgmii_rxc,
    output wire [3:0] eth_rgmii_td,
    output wire eth_rgmii_tx_ctl,
    output wire eth_rgmii_txc,
    output wire eth_rst_n,
    input  wire eth_int_n,

    input  wire eth_spi_miso,
    output wire eth_spi_mosi,
    output wire eth_spi_sck,
    output wire eth_spi_ss_n,

    //图像输出信号
    output wire[2:0] video_red,    //红色像素，3位
    output wire[2:0] video_green,  //绿色像素，3位
    output wire[1:0] video_blue,   //蓝色像素，2位
    output wire video_hsync,       //行同步（水平同步）信号
    output wire video_vsync,       //场同步（垂直同步）信号
    output wire video_clk,         //像素时钟输出
    output wire video_de           //行数据有效信号，用于区分消隐区

    // for debug
    // in the future these interfaces will be removed
    // CPU receiving FIFO
    // output wire [31:0] cpu_rx_qword_tdata,
    // output wire [3:0] cpu_rx_qword_tlast,
    // output wire cpu_rx_qword_tvalid,
    // input wire cpu_rx_qword_tready,
    // // CPU transmitting FIFO
    // input wire [31:0] cpu_tx_qword_tdata,
    // input wire [3:0] cpu_tx_qword_tlast,
    // input wire cpu_tx_qword_tvalid,
    // output wire cpu_tx_qword_tready
);

/* =========== Demo code begin =========== */

// PLL分频示例
wire locked, clk_10M, clk_20M, clk_125M, clk_200M;
pll_example clock_gen 
 (
  // Clock out ports
  .clk_out1(clk_10M), // 时钟输出1，频率在IP配置界面中设置
  .clk_out2(clk_20M), // 时钟输出2，频率在IP配置界面中设置
  .clk_out3(clk_125M), // 时钟输出3，频率在IP配置界面中设置
  .clk_out4(clk_200M), // 时钟输出4，频率在IP配置界面中设置
  // Status and control signals
  .reset(reset_btn), // PLL复位输入
  .locked(locked), // 锁定输出，"1"表示时钟稳定，可作为后级电路复位
 // Clock in ports
  .clk_in1(clk_50M) // 外部时钟输入
 );

assign eth_rst_n = ~reset_btn;
// 以太网交换机寄存器配置
eth_conf conf(
    .clk(clk_50M),
    .rst_in_n(locked),

    .eth_spi_miso(eth_spi_miso),
    .eth_spi_mosi(eth_spi_mosi),
    .eth_spi_sck(eth_spi_sck),
    .eth_spi_ss_n(eth_spi_ss_n),

    .done()
);

reg reset_of_clk10M, reset_of_clk20M, reset_of_clk_eth;
// 异步复位，同步释放
always@(posedge clk_10M or negedge locked) begin
    if(~locked) reset_of_clk10M <= 1'b1;
    else        reset_of_clk10M <= 1'b0;
end
always@(posedge clk_20M or negedge locked) begin
    if(~locked) reset_of_clk20M <= 1'b1;
    else        reset_of_clk20M <= 1'b0;
end
always@(posedge clk_125M or negedge locked) begin
    if(~locked) reset_of_clk_eth <= 1'b1;
    else        reset_of_clk_eth <= 1'b0;
end

always@(posedge clk_10M or posedge reset_of_clk10M) begin
    if(reset_of_clk10M)begin
        // Your Code
    end
    else begin
        // Your Code
    end
end

// 不使用内存、串口时，禁用其使能信号
// assign base_ram_ce_n = 1'b1;
// assign base_ram_oe_n = 1'b1;
// assign base_ram_we_n = 1'b1;

// assign ext_ram_ce_n = 1'b1;
// assign ext_ram_oe_n = 1'b1;
// assign ext_ram_we_n = 1'b1;

// assign uart_rdn = 1'b1;
// assign uart_wrn = 1'b1;

// 数码管连接关系示意图，dpy1同理
// p=dpy0[0] // ---a---
// c=dpy0[1] // |     |
// d=dpy0[2] // f     b
// e=dpy0[3] // |     |
// b=dpy0[4] // ---g---
// a=dpy0[5] // |     |
// f=dpy0[6] // e     c
// g=dpy0[7] // |     |
//           // ---d---  p

// 7段数码管译码器演示，将number用16进制显示在数码管上面
reg[7:0] number;
SEG7_LUT segL(.oSEG1(dpy0), .iDIG(number[3:0])); //dpy0是低位数码管
SEG7_LUT segH(.oSEG1(dpy1), .iDIG(number[7:4])); //dpy1是高位数码管

reg[15:0] led_bits;
assign leds = led_bits;
wire [15:0] led_debug;

/*always@(posedge clock_btn or posedge reset_btn) begin
    if(reset_btn)begin //复位按下，设置LED和数码管为初始值
        number<=0;
        led_bits <= 16'h1;
    end
    else begin //每次按下时钟按钮，数码管显示值加1，LED循环左移
        number <= number+1;
        led_bits <= {led_bits[14:0],led_bits[15]};
    end
end*/
always @ (posedge clk_125M) begin
    // led_bits <= led_debug;
end

//直连串口接收发送演示，从直连串口收到的数据再发送出去
wire [7:0] ext_uart_rx;
reg  [7:0] ext_uart_buffer, ext_uart_tx;
wire ext_uart_ready, ext_uart_busy;
reg ext_uart_start, ext_uart_avai;

async_receiver #(.ClkFrequency(50000000),.Baud(9600)) //接收模块，9600无检验位
    ext_uart_r(
        .clk(clk_50M),                       //外部时钟信号
        .RxD(rxd),                           //外部串行信号输入
        .RxD_data_ready(ext_uart_ready),  //数据接收到标志
        .RxD_clear(ext_uart_ready),       //清除接收标志
        .RxD_data(ext_uart_rx)             //接收到的一字节数据
    );
    
always @(posedge clk_50M) begin //接收到缓冲区ext_uart_buffer
    if(ext_uart_ready)begin
        ext_uart_buffer <= ext_uart_rx;
        ext_uart_avai <= 1;
    end else if(!ext_uart_busy && ext_uart_avai)begin 
        ext_uart_avai <= 0;
    end
end
always @(posedge clk_50M) begin //将缓冲区ext_uart_buffer发送出去
    if(!ext_uart_busy && ext_uart_avai)begin 
        ext_uart_tx <= ext_uart_buffer;
        ext_uart_start <= 1;
    end else begin 
        ext_uart_start <= 0;
    end
end

async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //发送模块，9600无检验位
    ext_uart_t(
        .clk(clk_50M),                  //外部时钟信号
        .TxD(txd),                      //串行信号输出
        .TxD_busy(ext_uart_busy),       //发送器忙状态指示
        .TxD_start(ext_uart_start),    //开始发送信号
        .TxD_data(ext_uart_tx)        //待发送的数据
    );

//图像输出演示，分辨率800x600@75Hz，像素时钟为50MHz
wire [11:0] hdata;
assign video_red = hdata < 266 ? 3'b111 : 0; //红色竖条
assign video_green = hdata < 532 && hdata >= 266 ? 3'b111 : 0; //绿色竖条
assign video_blue = hdata >= 532 ? 2'b11 : 0; //蓝色竖条
assign video_clk = clk_50M;
vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga800x600at75 (
    .clk(clk_50M), 
    .hdata(hdata), //横坐标
    .vdata(),      //纵坐标
    .hsync(video_hsync),
    .vsync(video_vsync),
    .data_enable(video_de)
);

// 以太网 MAC 配置演示
wire [7:0] eth_rx_axis_mac_tdata;
wire eth_rx_axis_mac_tvalid;
wire eth_rx_axis_mac_tlast;
wire eth_rx_axis_mac_tuser;
wire [7:0] eth_tx_axis_mac_tdata;
wire eth_tx_axis_mac_tvalid;
wire eth_tx_axis_mac_tlast;
wire eth_tx_axis_mac_tuser;
wire eth_tx_axis_mac_tready;

wire eth_rx_mac_aclk;
wire eth_tx_mac_aclk;

eth_mac eth_mac_inst (
    .gtx_clk(clk_125M),
    .refclk(clk_200M),

    .glbl_rstn(eth_rst_n),
    .rx_axi_rstn(eth_rst_n),
    .tx_axi_rstn(eth_rst_n),

    .rx_mac_aclk(eth_rx_mac_aclk),
    .rx_axis_mac_tdata(eth_rx_axis_mac_tdata),
    .rx_axis_mac_tvalid(eth_rx_axis_mac_tvalid),
    .rx_axis_mac_tlast(eth_rx_axis_mac_tlast),
    .rx_axis_mac_tuser(eth_rx_axis_mac_tuser),

    .tx_ifg_delay(8'b0),
    .tx_mac_aclk(eth_tx_mac_aclk),
    .tx_axis_mac_tdata(eth_tx_axis_mac_tdata),
    .tx_axis_mac_tvalid(eth_tx_axis_mac_tvalid),
    .tx_axis_mac_tlast(eth_tx_axis_mac_tlast),
    .tx_axis_mac_tuser(eth_tx_axis_mac_tuser),
    .tx_axis_mac_tready(eth_tx_axis_mac_tready),

    .pause_req(1'b0),
    .pause_val(16'b0),

    .rgmii_txd(eth_rgmii_td),
    .rgmii_tx_ctl(eth_rgmii_tx_ctl),
    .rgmii_txc(eth_rgmii_txc),
    .rgmii_rxd(eth_rgmii_rd),
    .rgmii_rx_ctl(eth_rgmii_rx_ctl),
    .rgmii_rxc(eth_rgmii_rxc),

    // receive 1Gb/s | promiscuous | flow control | fcs | vlan | enable
    .rx_configuration_vector(80'b10100000101110),
    // transmit 1Gb/s | vlan | enable
    .tx_configuration_vector(80'b10000000000110)
);
/* =========== Demo code end =========== */

wire eth_sync_rst;
wire eth_sync_rst_n;

// eth_mac_reset_sync reset_sync_i(
//     .reset_in(1'b0),
//     .clk(eth_rx_mac_aclk),
//     .enable(1'b1),
//     .reset_out(eth_sync_rst)
// );
assign eth_sync_rst = reset_of_clk_eth;
assign eth_sync_rst_n = ~eth_sync_rst;

wire cpu_rx_qword_tvalid, cpu_tx_qword_tvalid, cpu_rx_qword_tready, cpu_tx_qword_tready;
wire [31:0] cpu_rx_qword_tdata, cpu_tx_qword_tdata;
wire [3:0] cpu_rx_qword_tlast, cpu_tx_qword_tlast;
// ******for simulation******
// reg bus_stall, bus_stall_reg;
// initial begin
//     bus_stall = 0;
// end
// always bus_stall = #876 ~bus_stall;
// always @ (posedge clk_50M) begin
//     bus_stall_reg <= bus_stall;
// end
// ***********end************


localparam BUFFER_SIZE_INDEX = 7;

wire router_write_stall, router_read_stall;
wire [BUFFER_SIZE_INDEX-1:0] router_in_index;
wire router_mem_we, router_mem_oe;
wire router_in_restart_clr, router_in_restart;
wire [1:0] router_out_state, router_out_en;
wire [31:0] router_mem_waddr, router_mem_wdata;
wire [31:0] router_mem_oaddr, router_mem_odata;
wire [31:0] router_out_data;

wire clk_cpu = clk_10M;
wire rst_cpu = reset_of_clk10M;

router_controller #(.BUFFER_IND(BUFFER_SIZE_INDEX)) router_controller_inst
(
    .clk(clk_cpu),
    .rst(rst_cpu),
    .write_stall(router_write_stall),
    .read_stall(router_read_stall),
    .in_index(router_in_index),       // o
    .in_restart(router_in_restart),   // o
    .in_restart_clear(router_in_restart_clr),// i
    .mem_write_en(router_mem_we),     // o
    .mem_write_addr(router_mem_waddr),// o
    .mem_write_data(router_mem_wdata),// o
    
    .out_state(router_out_state),     // o
    .out_en(router_out_en),           // i
    .out_data(router_out_data),       // i
    .mem_read_en(router_mem_oe),      // o
    .mem_read_addr(router_mem_oaddr), // o
    .mem_read_data(router_mem_odata), // i

    // cpu receiving
    .cpu_rx_qword_tdata(cpu_rx_qword_tdata),   // i
    .cpu_rx_qword_tlast(cpu_rx_qword_tlast),   // i
    .cpu_rx_qword_tvalid(cpu_rx_qword_tvalid), // i
    .cpu_rx_qword_tready(cpu_rx_qword_tready), // o
    // cpu transmitting
    .cpu_tx_qword_tdata(cpu_tx_qword_tdata),  // o
    .cpu_tx_qword_tlast(cpu_tx_qword_tlast),  // o
    .cpu_tx_qword_tvalid(cpu_tx_qword_tvalid),// o
    .cpu_tx_qword_tready(cpu_tx_qword_tready) // i
);


wire [31:0] lookup_modify_in_addr, lookup_modify_in_nexthop;
wire lookup_modify_in_ready;
wire [1:0] lookup_modify_in_nextport;
wire [6:0] lookup_modify_in_len;
wire lookup_modify_finish, lookup_full;
wire ip_modify_req;

router router_inst(
    .eth_rx_mac_aclk(eth_rx_mac_aclk),
    .eth_tx_mac_aclk(eth_tx_mac_aclk),
    .cpu_clk(clk_cpu),
    .eth_sync_rst_n(eth_sync_rst_n),
    .cpu_rst(rst_cpu),

    .eth_rx_axis_mac_tdata(eth_rx_axis_mac_tdata),
    .eth_rx_axis_mac_tvalid(eth_rx_axis_mac_tvalid),
    .eth_rx_axis_mac_tlast(eth_rx_axis_mac_tlast),
    .eth_rx_axis_mac_tuser(eth_rx_axis_mac_tuser),

    .eth_tx_axis_mac_tdata(eth_tx_axis_mac_tdata),
    .eth_tx_axis_mac_tvalid(eth_tx_axis_mac_tvalid),
    .eth_tx_axis_mac_tlast(eth_tx_axis_mac_tlast),
    .eth_tx_axis_mac_tready(eth_tx_axis_mac_tready),
    .eth_tx_axis_mac_tuser(eth_tx_axis_mac_tuser),

    // transmitted by CPU
    .cpu_rx_qword_tdata(cpu_rx_qword_tdata),
    .cpu_rx_qword_tlast(cpu_rx_qword_tlast),
    .cpu_rx_qword_tvalid(cpu_rx_qword_tvalid),
    .cpu_rx_qword_tready(cpu_rx_qword_tready),
    // received by CPU
    .cpu_tx_qword_tdata(cpu_tx_qword_tdata),
    .cpu_tx_qword_tlast(cpu_tx_qword_tlast),
    .cpu_tx_qword_tvalid(cpu_tx_qword_tvalid),
    .cpu_tx_qword_tready(cpu_tx_qword_tready),
    
    .ip_modify_req(ip_modify_req),
    .lookup_modify_in_addr(lookup_modify_in_addr),
    .lookup_modify_in_nexthop(lookup_modify_in_nexthop),
    .lookup_modify_in_ready(lookup_modify_in_ready),
    .lookup_modify_in_nextport(lookup_modify_in_nextport),
    .lookup_modify_in_len(lookup_modify_in_len),
    .lookup_modify_finish(lookup_modify_finish),
    .lookup_full(lookup_full),
    .lookup_error(lookup_error)
);



// cpu
assign ext_ram_ce_n = 1'b0;

/*mark_debug="true"*/wire [3:0] mem_be;
/*mark_debug="true"*/wire pc_stall, mem_we, mem_oe, mem_stall;
// assign ext_ram_be_n = ~ram_be;
// assign ext_ram_we_n = ~ram_we;
// assign ext_ram_oe_n = ~ram_oe;
(*mark_debug="true"*)wire [31:0] pc_data, mem_data_i, mem_data_o;
(*mark_debug="true"*)wire [31:0] pc_addr, mem_addr;

wire [15:0] cpu_out;
wire [15:0] bus_out;
always @(cpu_out) begin
    led_bits <= cpu_out;
end

wire [63:0] timing_mils;
// Needs to be turned down to little in simulation
timer #(.FREQ(10000)) timer_inst (
    .clk(clk_cpu),
    .rst(rst_cpu),
    .out(timing_mils)
);

bus bus_inst(
    .clk(clk_cpu),
    .rst(rst_cpu),

    .pcram_data(base_ram_data),
    .pcram_addr(base_ram_addr),
    .pcram_be_n(base_ram_be_n),
    .pcram_we_n(base_ram_we_n),
    .pcram_oe_n(base_ram_oe_n),
    .pcram_ce_n(base_ram_ce_n),

    .dtram_data(ext_ram_data),
    .dtram_addr(ext_ram_addr),
    .dtram_be_n(ext_ram_be_n),
    .dtram_we_n(ext_ram_we_n),
    .dtram_oe_n(ext_ram_oe_n),

    .router_in_ind({32'b0, router_in_index}),
    .router_out_state(router_out_state),
    .router_out_en(router_out_en),
    .router_out_data(router_out_data),
    
    .router_ip_modify_req(ip_modify_req),
    .lookup_modify_in_addr(lookup_modify_in_addr),
    .lookup_modify_in_nexthop(lookup_modify_in_nexthop),
    .lookup_modify_in_ready(lookup_modify_in_ready),
    .lookup_modify_in_nextport(lookup_modify_in_nextport),
    .lookup_modify_in_len(lookup_modify_in_len),
    .lookup_modify_finish(lookup_modify_finish),
    .lookup_full(lookup_full),

    .timing_mil_secs(timing_mils),
    .router_in_restart(router_in_restart),
    .router_in_restart_clr(router_in_restart_clr),

    .pc_data(pc_data),
    .pc_addr(pc_addr),
    .pc_stall(pc_stall),

    .mem_data_i(mem_data_i),
    .mem_data_o(mem_data_o),
    .mem_addr_i(mem_addr),
    .mem_be_i(mem_be),
    .mem_oe_i(mem_oe),
    .mem_we_i(mem_we),
    .mem_stall(mem_stall),
    .router_we(router_mem_we),
    .router_addr_i(router_mem_waddr),
    .router_data_i(router_mem_wdata),
    .router_write_stall(router_write_stall),
    .router_oe(router_mem_oe),
    .router_addr_o(router_mem_oaddr),
    .router_data_o(router_mem_odata),
    .router_read_stall(router_read_stall),

    .uart_dataready(uart_dataready),
    .uart_tsre(uart_tsre),
    .uart_tbre(uart_tbre),
    .uart_rdn(uart_rdn),
    .uart_wrn(uart_wrn),
    .leds(bus_out)
);

cpu CPU(
    .clk(clk_cpu),
    .rst(rst_cpu),

    .pc_data_i(pc_data),
    .pc_addr_o(pc_addr),
    .if_stall_req(pc_stall),
    .mem_stall_req(mem_stall),
    .int_i({3'b0, uart_dataready, 2'b0}),

    .ram_data_o(mem_data_i),
    .ram_data_i(mem_data_o),
    .ram_addr_o(mem_addr),
    .ram_be_o(mem_be),
    .ram_we_o(mem_we),
    .ram_oe_o(mem_oe),
    .leds(cpu_out)
);

always @(posedge clk_cpu) begin
    number <= pc_data[7:0];
end

endmodule