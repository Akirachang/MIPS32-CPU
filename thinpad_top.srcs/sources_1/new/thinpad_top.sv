`default_nettype none

module thinpad_top(
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入

    input wire clock_btn,         //BTN5手动时钟按钮开关，带消抖电路，按下时为1
    input wire reset_btn,         //BTN6手动复位按钮开关，带消抖电路，按下时为1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4，按钮开关，按下时为1
    input  wire[31:0] dip_sw,     //32位拨码开关，拨到"ON"时为1
    output wire[15:0] leds,       //16位LED，输出时1点亮
    output wire[7:0]  dpy0,       //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0]  dpy1,       //数码管高位信号，包括小数点，输出1点亮

    //CPLD串口控制器信号
    output logic uart_rdn,         //读串口信号，低有效
    output logic uart_wrn,         //写串口信号，低有效
    input wire uart_dataready,    //串口数据准备好
    input wire uart_tbre,         //发送数据标志
    input wire uart_tsre,         //数据发送完毕标志

    //BaseRAM信号
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享
    output logic[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output logic base_ram_ce_n,       //BaseRAM片选，低有效
    output logic base_ram_oe_n,       //BaseRAM读使能，低有效
    output logic base_ram_we_n,       //BaseRAM写使能，低有效

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

    //USB 控制器信号，参考 SL811 芯片手册
    output wire sl811_a0,
    //inout  wire[7:0] sl811_d,     //USB数据线与网络控制器的dm9k_sd[7:0]共享
    output wire sl811_wr_n,
    output wire sl811_rd_n,
    output wire sl811_cs_n,
    output wire sl811_rst_n,
    output wire sl811_dack_n,
    input  wire sl811_intrq,
    input  wire sl811_drq_n,

    //网络控制器信号，参考 DM9000A 芯片手册
    output wire dm9k_cmd,
    inout  wire[15:0] dm9k_sd,
    output wire dm9k_iow_n,
    output wire dm9k_ior_n,
    output wire dm9k_cs_n,
    output wire dm9k_pwrst_n,
    input  wire dm9k_int,

    //图像输出信号
    output wire[2:0] video_red,    //红色像素，3位
    output wire[2:0] video_green,  //绿色像素，3位
    output wire[1:0] video_blue,   //蓝色像素，2位
    output wire video_hsync,       //行同步（水平同步）信号
    output wire video_vsync,       //场同步（垂直同步）信号
    output wire video_clk,         //像素时钟输出
    output wire video_de           //行数据有效信号，用于区分消隐区
);

/* =========== Demo code begin =========== */

// PLL分频示例
wire locked, clk_10M, clk_20M;
pll_example clock_gen
 (
  // Clock out ports
  .clk_out1(clk_10M), // 时钟输出1，频率在IP配置界面中设置
  .clk_out2(clk_20M), // 时钟输出2，频率在IP配置界面中设置
  // Status and control signals
  .reset(reset_btn), // PLL复位输入
  .locked(locked), // 锁定输出，"1"表示时钟稳定，可作为后级电路复位
 // Clock in ports
  .clk_in1(clk_50M) // 外部时钟输入
 );

reg reset_of_clk10M;
// 异步复位，同步释放
always@(posedge clk_10M or negedge locked) begin
    if(~locked) reset_of_clk10M <= 1'b1;
    else        reset_of_clk10M <= 1'b0;
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

assign ext_ram_ce_n = 1'b1;
assign ext_ram_oe_n = 1'b1;
assign ext_ram_we_n = 1'b1;

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
wire[7:0] dpy_number;
SEG7_LUT segL(.oSEG1(dpy0), .iDIG(dpy_number[3:0])); //dpy0是低位数码管
SEG7_LUT segH(.oSEG1(dpy1), .iDIG(dpy_number[7:4])); //dpy1是高位数码管



//---------------------ALU--------------------------------------

// reg[15:0]  num_a, num_b, num_c;
// wire[15:0] res_add, res_sub;
// wire[3:0]  op, num_b_low;
// wire       ov_add, ov_sub; reg ovfl;     // overflow
//
// // assignments for wire variables
// assign res_add = num_a + num_b;
// assign op = dip_sw[3:0];
// assign num_b_low = num_b[3:0];
// assign ov_add = num_a[15] == num_b[15] && res_add[15] != num_a[15];
// assign res_sub = num_a - num_b;
// assign ov_sub = num_a[15] != num_b[15] && res_sub[15] == num_b[15];

// parameter OP_ADD = 4'd1, OP_SUB = 4'd2, OP_AND = 4'd3, OP_OR = 4'd4, OP_XOR = 4'd5, OP_NOT = 4'd6,
//            OP_SLL = 4'd7, OP_SRL = 4'd8, OP_SRA = 4'd9, OP_ROL = 4'd10;

// parameter state0 = 2'b00, state1 = 2'b01, state2 = 2'b10, state3 = 2'b11;   // 状态
// reg[1:0]   cur_state = state0;
// assign     dpy_number = cur_state;

// assign leds = cur_state >= 2 ? num_c : dip_sw;
// //assign leds = num_c;

// always @ (dip_sw or cur_state) begin    // when state changes or input changes
//     case (cur_state)
//         state2: case (op)
//             OP_ADD: begin num_c <= res_add; ovfl <= ov_add; end
//             OP_SUB: begin num_c <= res_sub; ovfl <= ov_sub; end
//             OP_AND: begin num_c <= num_a & num_b; ovfl <= 0; end
//             OP_OR:  begin num_c <= num_a | num_b; ovfl <= 0; end
//             OP_XOR: begin num_c <= num_a ^ num_b; ovfl <= 0; end
//             OP_NOT: begin num_c <= ~num_a; ovfl <= 0; end
//             OP_SLL: begin num_c <= num_a << num_b; ovfl <= 0; end
//             OP_SRL: begin num_c <= num_a >> num_b; ovfl <= 0; end
//             OP_SRA: begin num_c <= $signed(num_a) >>> num_b; ovfl <= 0; end
//             OP_ROL: begin num_c <= (num_a << num_b_low) | (num_a >> (16 - num_b_low)); ovfl <= 0; end
//             default: begin num_c <= 0; ovfl <= 0; end  // error
//         endcase
//         state3: begin
//             num_c[0] <= ovfl;
//             num_c[15:1] <= 0;
//         end
//     endcase
// end

// always @ (posedge clock_btn or posedge reset_btn) begin
//     if (reset_btn) //复位按下，设置LED为初始值，进入初始态
//         cur_state <= state0;
//     else case (cur_state) //每次按下时钟按钮，进入下一状态处理
//         state0: begin num_a <= dip_sw[15:0]; cur_state <= state1; end
//         state1: begin num_b <= dip_sw[15:0]; cur_state <= state2; end
//         state2: cur_state <= state3;
//         state3: cur_state <= state0;    
//     endcase
// end

//-------------------------END ALU------------------------



// //------------------------SRAM--------------------

// reg[31:0] write_data;
// reg[19:0] write_addr; 

// parameter state_begin=3'b000,state_write_addr=3'b001, state_write_data=3'b010, state_release=3'b011,state_read=3'b100,state_show=3'b101,state_read_real=3'b111,state_write=3'b110;

// reg[2:0] cur_state = state_begin;
// assign base_ram_ce_n = 1'b0;
// assign base_ram_be_n = 1'b0;
// reg oe=1'b1;
// reg we=1'b1;
// reg[31:0] data;
// reg[19:0] addr;
// reg[15:0] showleds;
// assign base_ram_oe_n = oe;
// assign base_ram_we_n = we;
// assign base_ram_data = data;
// assign base_ram_addr = addr;
// assign leds = showleds;


// // State Change
// always @ (posedge clock_btn or posedge reset_btn) begin
//     if (reset_btn) begin
//             cur_state<=state_begin;
//         end
//     else begin
//         case (cur_state)
//             state_begin: begin 
//                     cur_state<=state_write_addr;
//                 end
//             state_write_addr:begin
//                     cur_state<=state_write_data;
//                 end
//             state_write_data:begin
//                     cur_state<=state_write;
//                 end
//             state_write:begin
//                     cur_state<=state_release;
//                 end
//             state_release:begin
//                     cur_state<=state_read;
//                 end
//             state_read:begin
//                     cur_state<=state_read_real;
//                 end
//             state_read_real:begin
//                     cur_state<=state_show;
//                 end
//         endcase
//     end
// end

// always @ (cur_state) begin
//     case(cur_state)
//         state_write_addr:begin
//                 addr<=dip_sw[19:0];
//             end
//         state_write_data:begin
//                 data = dip_sw[31:0];
//             end
//         state_write:begin
//                 we = 1'b0;
//             end
//         state_release:begin
//                 we = 1'b1;
//             end
//         state_read:begin
//                 data = 32'bz;
//             end
//         state_read_real:begin
//                 oe = 1'b0;
//             end
//         state_show:begin
//                 showleds <= base_ram_data[15:0];
//             end
//     endcase
// end

// //----------------------END SRAM------------------




// //-------------------------READ UART-----------------

// reg[2:0] state=3'b000;
// assign base_ram_ce_n = 1'b1;
// assign base_ram_oe_n = 1'b1;
// assign base_ram_we_n = 1'b1;

// assign ext_ram_ce_n = 1'b1;
// assign ext_ram_oe_n = 1'b1;
// assign ext_ram_we_n = 1'b1;

// assign uart_rdn = 1'b1;
// // assign uart_wrn = 1'b1;

// reg uart_wrn_my = 1'b1;
// assign uart_wrn = uart_wrn_my;


// reg[31:0] data;
// assign base_ram_data = data;

// always @ (state) begin
//     case(state)
//         3'b001:begin
//             data = dip_sw;
//         end
//         3'b010:begin
//             uart_wrn_my = 1'b0;
//         end
//         3'b011:begin
//             uart_wrn_my = 1'b1;
//         end
//         3'b100:begin
//             uart_wrn_my = 1'b1;
//         end
//         3'b101:begin
//             uart_wrn_my = 1'b1;
//         end

//     endcase
// end

// always @ (posedge clock_btn) begin
//     case(state)
//         3'b000:begin
//             state <= 3'b001;
//         end
//         3'b001:begin
//             state <= 3'b010;
//         end
//         3'b010:begin
//             state<=3'b011;
//         end
//         3'b011:begin
//             state<=3'b100;
//         end
//         3'b100:begin
//             if(uart_tbre==1'b1) begin
//                 state<=3'b101;
//             end
//         end
//         3'b101:begin
//             if(uart_tsre==1'b1)begin
//                 state<=3'b000;
//             end
//         end

//     endcase

// end



// //------------------------END READ UART--------------



// //-----------------------Write UART--------------------

// reg[2:0] state=3'b000;
// assign base_ram_ce_n = 1'b1;
// assign base_ram_oe_n = 1'b1;
// assign base_ram_we_n = 1'b1;

// assign ext_ram_ce_n = 1'b1;
// assign ext_ram_oe_n = 1'b1;
// assign ext_ram_we_n = 1'b1;

// // assign uart_rdn = 1'b1;
// assign uart_wrn = 1'b1;


// reg uart_rdn_my = 1'b1;
// assign uart_rdn = uart_rdn_my;

// reg[31:0] data;
// assign base_ram_data = data;

// reg[7:0] showleds;
// assign leds=showleds;

// always@(state) begin
//     case(state)
//         3'b001:begin
//             data = 32'bz;
//         end
//         3'b010:begin
//             uart_rdn_my = 1'b0;
//         end
//         3'b011:begin
//             showleds = base_ram_data[7:0];
//         end
//         3'b100:begin
//             uart_rdn_my=1'b1;
//         end
//     endcase
// end

// always@(posedge clock_btn)begin
//     case(state)
//         3'b000:begin
//             state<=3'b001;
//         end
//         3'b001:begin
//             state<=3'b010;
//         end
//         3'b010:begin
//             if(uart_dataready==1'b1)begin
//                 state<=3'b011;
//             end
//         end
//         3'b011:begin
//             state<=3'b100;
//         end
//         3'b100:begin
//             state<=3'b000;
//         end
//     endcase
// end



// //------------------------END Write UART---------------



//---------------------------ALL-------------------------

reg[4:0] state = 5'b00000;

reg[31:0] data;
assign base_ram_data  = data;

always @ (posedge clk_11M0592) begin

    if(reset_btn==1'b1)begin
        base_ram_ce_n = 1'b1;
        base_ram_oe_n = 1'b1;
        base_ram_we_n = 1'b1;

        uart_rdn = 1'b1;
        uart_wrn = 1'b1;
        state<=5'b00000;
    end

    case(state)
        5'b00000:begin
            state<=5'b00001;
        end
        5'b00001:begin
            base_ram_addr<=dip_sw[19:0];        //write addr, prepare read uart
            data = 32'bz;
            uart_rdn = 1'b1;
            state<=5'b00010;
        end
        5'b00010:begin                          //wait to read uart
            if(uart_dataready==1'b1)begin
                state<=5'b00011;
            end
        end
        5'b00011:begin                          //read uart
            uart_rdn = 1'b0;
            state<=5'b00100;
        end
        5'b00100:begin                          //write tp base ram
            uart_rdn = 1'b1;
            base_ram_ce_n = 1'b0;
            base_ram_we_n = 1'b0;
            state<=5'b00101;
        end
        5'b00101:begin                          //end write
            base_ram_we_n = 1'b1;
            base_ram_ce_n = 1'b1;
            state<=5'b00110;
        end
        5'b00110:begin                          //repeate
            if(base_ram_addr-dip_sw[19:0]!=9) begin
                base_ram_addr<=base_ram_addr+1;
                state<= 5'b00010;
            end
            else begin
                state<=5'b00111;
            end
        end
        5'b00111:begin                         //reset addr
            base_ram_addr = dip_sw[19:0];
            state<=5'b01000;
        end
        5'b01000:begin                          //read data in addr
            base_ram_ce_n = 1'b0;
            data=32'bz;
            base_ram_oe_n = 1'b0;
            state<=5'b01001;
        end
        5'b01001:begin                          //sent data
            base_ram_oe_n = 1'b1;
            base_ram_ce_n = 1'b1;
            uart_wrn = 1'b0;
            state<=5'b01010;            
        end
        5'b01010:begin                         //fin write
            uart_wrn = 1'b1;
            state<=5'b01011;
        end
        5'b01011:begin                          //wait to write
            if(uart_tbre==1'b1)begin
                state<=5'b01100;
            end
        end
        5'b01100:begin                         //wait to write
            if(uart_tsre==1'b1)begin
                state<=5'b01101;
            end
        end
        5'b01101:begin                        //repeate
            if(base_ram_addr-dip_sw[19:0]!=9) begin
                base_ram_addr<=base_ram_addr+1;
                state<= 5'b01000;
            end
        end
    endcase
end


//--------------------------END ALL-----------------------


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
/* =========== Demo code end =========== */

endmodule
