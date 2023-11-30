// module Grayscaler(
 // input          clk,                     //clock
 // input          rst_n,                   //external asynchronous active low reset
 // input          GS_enable,               //to enable or disable this module. Driven by controller
 // input          RWM_valid,               //an active high signal indicating the presence of desired data at the output data bus
 // input [7:0]    Din,                     //input data bus. Connected to RWM_1 module
 // output [7:0]   Dout,                    //output data bus. Connected to RWM_2 module
 // output         GS_valid,                //an active high signal that tells the RWM_2 module that desired data bytes is present in the output data bus
 // output         pause,                   //an active high signal that tells the RWM_1 module to pause whatever operation it is doing.
 // output reg     GS_done                  //after the completion of an operation done is set to 1. It is a status signal to drive the controller
// );

`timescale 1ns/1ps
`define clock_period 20
`include "./../rtl/grayscaler.v"

module tb_grayscaler();

	reg clk;
	reg rst_n;
	reg GS_enable;
	reg [15:0] Din;
	
	initial begin
		clk = 1'b1;
		forever
			#(`clock_period/2)	clk = ~clk;
	end
	
	initial begin
		rst_n = 1'b0;
		GS_enable = 1'b0;
		Din = 8'b1010_1010_1010_1010;
		
		#100 rst_n = 1'b1;
		#100 GS_enable = 1'b1;
		
	end
	
	
	always @(posedge clk)
	begin 
	if(!rst_n)
		Din <= 16'b0;
	else 
		Din <= Din + 16'b0110;	
	end
		
		
	wire GRS_N;

	GTP_GRS GRS_INST (

	.GRS_N(1'b1)

	);
	
	grayscaler U1(
		.clk(clk),
		.rst_n(rst_n),
		.GS_enable(GS_enable),
		.Din(Din)
	);
	
endmodule