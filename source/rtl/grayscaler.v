/*
MODULE OVERVIEW:
Function of this module:
To calculate the grayscale values of each colour pixel(R,G,B respectively) stored in first memory module.
It communicates with the controller and the memory modules.

Working:
The module makes use of a FSM with 3 states:-
1)IDLE: Whenever the module is not in use, it is in this state. It waits for further commands from the controller.

2)EXPAND: Here every three pixel bytes at the input data bus is loaded into the internal registers for grayscale calculation.
        First byte is stored in 'red', second in 'green' and third in 'blue'.
        After the third byte is recieved, a status signal is sent to the first memory module to pause its operation.

3)CALCULATE: To find the grayscale value of the three bytes recieved.
             After placing the computed value in the output bus, a status signal is sent to the second memory module to store this value.
*/


module grayscaler(
 input          clk,                     //clock
 input          rst_n,                   //external asynchronous active low reset
 input          GS_enable,               //to enable or disable this module. Driven by controller
 input [15:0]   Din,                     //input data bus. Connected to RWM_1 module
 output [7:0]   Dout,                    //output data bus. Connected to RWM_2 module
 output         GS_valid,                //an active high signal that tells the RWM_2 module that desired data bytes is present in the output data bus
 output     	GS_done               	   //after the completion of an operation done is set to 1. It is a status signal to drive the controller
);

parameter N = 1280, M = 720;   			 //only in simulating
//parameter N = 450, M = 450;              //分辨率

reg [7:0] red, green, blue, result;

integer pixel_cnt;

parameter IDLE = 2'b00, EXPAND = 2'b01;
reg [1:0] CS, NS;

always @(posedge clk or negedge rst_n)
begin
if(~rst_n)
  CS <= IDLE;
 else
 begin
  CS <= NS;
 end
end


always @(*)
begin

 case (CS)
 IDLE:
 begin
  pixel_cnt = 0;
  red = 8'h00;
  green = 8'h00;
  blue = 8'h00;
  
  
  
  if(GS_enable)
  begin
   NS = EXPAND;
  end
  else NS = IDLE;  
 end
 
 EXPAND:   //逐个读入FIFO中数据pdata1 pdata2，读取过程中完成扩展
 begin
	blue = {Din[15:11],Din[13:11]};
	green = {Din[10:8], 5'b00000};
	green = {green[7:5], Din[7:5], Din[6:5]};
	red = {Din[4:0], Din[2:0]};
	result = (red>>2) + (red>>5) + (green>>1) + (green>>4) + (blue>>4) + (blue>>5);
	NS = (pixel_cnt == N*M) ? IDLE : EXPAND;
	pixel_cnt = (pixel_cnt == N*M) ? 0 : pixel_cnt + 1;
 end
 
 default: NS = IDLE;
 
 endcase
end

assign GS_done = (pixel_cnt == N*M) ? 1'b1 : 1'b0;
assign GS_valid = (CS == EXPAND) ? 1'b0 : 1'b1;
assign Dout = (CS == EXPAND) ? result : 8'hzz;

endmodule
