//Imane MOUMOUN 
//xor_begin

`timescale 1ns / 1ps

import ascon_pack::*;

module xor_begin
	(
	input  type_state state_i,
	input logic en_xor_begin_data_i, 
	input logic en_xor_begin_key_i,
	input logic [127:0] key_i,
	input logic [127:0] data_i,
	output type_state state_o
	);
	
	type_state state_s;

	always @(*) begin 
			case ({
				en_xor_begin_data_i, en_xor_begin_key_i 
			})
				2'b01: begin  //xor active avec la cle key
					state_s[0]=state_i[0];
					state_s[1]=state_i[1];
					state_s[2]=state_i[2]^key_i[63:0];
					state_s[3]=state_i[3]^key_i[127:64];
					state_s[4]=state_i[4];
				end
				2'b10: begin  //xor active avec donne associe ou texte clair 
					state_s[0]=state_i[0]^data_i[127:64];
					state_s[1]=state_i[1]^data_i[63:0];
					state_s[2]=state_i[2];
					state_s[3]=state_i[3];
					state_s[4]=state_i[4];
				end
				2'b11: begin  //xor active avec donne associe et avec la cle key
					state_s[0]=state_i[0]^data_i[127:64];
					state_s[1]=state_i[1]^data_i[63:0];
					state_s[2]=state_i[2]^key_i[63:0];
					state_s[3]=state_i[3]^key_i[127:64];
					state_s[4]=state_i[4];
				end
				default: begin  //xor transparent
					state_s=state_i;
				end
			endcase
	end 

	assign state_o = state_s;

endmodule: xor_begin
