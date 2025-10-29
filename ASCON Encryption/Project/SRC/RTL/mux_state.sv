//Imane MOUMOUN
//mux_state

`timescale 1ns / 1ps

import ascon_pack::*;

module mux_state
	
	(
	input type_state input1_i, 
	input type_state input0_i,
	input logic select_i,
	output type_state mux_o
	);

	assign mux_o = (select_i==1'b1)? input1_i:input0_i ;
		

endmodule : mux_state
	
	
	
