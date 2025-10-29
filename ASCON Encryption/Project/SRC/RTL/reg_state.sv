//Imane MOUMOUN
//reg_state

`timescale 1ns / 1ps

import ascon_pack::*;

module reg_state
	
	(
	input type_state d_i,
	input logic clock_i,
	input logic resetb_i,
	input logic enable_i,
	output type_state q_o

	);
	
	type_state state_s;

	//sequential process
	always_ff @(posedge clock_i or negedge resetb_i)
		begin  
			if (resetb_i == 1'b0)
				//nonblocking assignment <=
				state_s <= {64'h0,64'h0,64'h0,64'h0,64'h0};

			else begin
				if(enable_i == 1'b1)
					state_s <= d_i;
				else 	
					state_s <= state_s;
			end
		end 

	 assign q_o = state_s;

endmodule : reg_state
