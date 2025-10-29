//Imane MOUMOUN 
//xor_begin_tb

`timescale 1ns / 1ps

import ascon_pack::*;

module xor_begin_tb
	(
	//empty declarative part
	);

	// Internal net declaration
	
	type_state state_i_s;
	logic en_xor_begin_data_s;
	logic en_xor_begin_key_s;
	logic [127:0] key_s;
	logic [127:0] data_s;

	type_state state_o_s;

	//DUT : component instanciation
	xor_begin DUT (
		.state_i(state_i_s),
		.state_o(state_o_s),
		.en_xor_begin_data_i(en_xor_begin_data_s),
		.en_xor_begin_key_i(en_xor_begin_key_s),
		.key_i(key_s),
		.data_i(data_s)
		);

	initial begin
		
		key_s=128'h691AED630E81901F6CB10AD9CA912F80;
		data_s= 128'h6F74206563696C4100000001626F4220;

		state_i_s[0]= 64'h82bf91294ba5808d ;		
		state_i_s[1]= 64'hd81eeca694136f8a ;
		state_i_s[2]= 64'h0217bc9ebd9fff02 ;
		state_i_s[3]= 64'h2163C2A59353D4C8;
		state_i_s[4]= 64'h2731CDA0E76AA05B;
		    
		 // cas 1: xor transparent
		en_xor_begin_data_s = 1'b0;
		en_xor_begin_key_s = 1'b0;

		#10;
		// cas 2: xor_active avec donne associe ou texte clair
		en_xor_begin_data_s = 1'b1;
		en_xor_begin_key_s = 1'b0;

		#10;
		// cas 3: xor active avec la cle key
		en_xor_begin_data_s = 1'b0;
		en_xor_begin_key_s = 1'b1;

		#10;
		//xor active avec donne associe et avec la cle key
		en_xor_begin_data_s = 1'b1;
		en_xor_begin_key_s = 1'b1;

    	end
	
endmodule: xor_begin_tb
	
