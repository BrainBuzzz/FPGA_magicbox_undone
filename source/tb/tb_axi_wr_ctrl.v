`timescale 1ns/1ps

module tb_axi_wr_ctrl;

localparam C_M_TARGET_SLAVE_BASE_ADDR	= 32'h40000000;

localparam C_M_AXI_ADDR_WIDTH	= 28;

localparam C_M_AXI_DATA_WIDTH	= 16;

/**************寄存器设置****************/
reg                               aw_ready;
reg                               w_ready;
reg  [C_M_AXI_ADDR_WIDTH-1 : 0]   axi_addr;
reg  [C_M_AXI_DATA_WIDTH-1 : 0]   axi_data;

reg                               axi_resetn;
reg                               axi_clk; 
reg  [6 : 0]                      wr_clk_cnt;                     //每间隔10个axi周期发送一次data

//reset and axi_clk control
initial begin  
    axi_resetn = 1;
    axi_clk = 0;
    #50 axi_resetn = 0;
    wr_clk_cnt = 0;
    forever begin
        #10  axi_clk = ~axi_clk; 
    end
    
end

//wr_clk_cnt    control
always @(posedge axi_clk) begin
    if(!axi_resetn || wr_clk_cnt == 6'd50)
        wr_clk_cnt = 0;
    else
        wr_clk_cnt = wr_clk_cnt + 1;
end

//aw_ready control
always @(posedge axi_clk) begin
    if(!axi_resetn) begin
        aw_ready <= 0;
    end
    else if(wr_clk_cnt == 6'd50) begin
        aw_ready <= 1;
    end
end

//w_ready control
always @(posedge axi_clk) begin
    if(!axi_resetn)
        w_ready <= 0;
    else if(aw_ready == 1)
        w_ready <= 1;
    else 
        w_ready <= w_ready;
end

assign axi_data = (aw_ready && w_ready)?axi_data + 4'b1111:axi_data;

axi_wr_ctrl axi_wr_ctrl(    
        /****************前端接口**************/
        .FIFO_AXI_DATA          (axi_data)            ,         
        .CTRL_AWADDR            (axi_addr)            ,         
        .M_AXI_AWREADY          (aw_ready)            ,         
        .M_AXI_WREADY           (w_ready)             ,         
        /****************总信号****************/            

        .M_AXI_ACLK              (axi_clk)             ,          //总AXI时钟
		.M_AXI_ARESETN           (axi_resetn)                     //复位		
)

endmodule