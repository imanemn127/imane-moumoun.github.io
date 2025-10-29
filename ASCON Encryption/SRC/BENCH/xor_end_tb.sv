//Imane MOUMOUN 
//xor_end_tb

`timescale 1ns / 1ps

import ascon_pack::*;

module xor_end_tb
	(
	//empty declarative part
	);

	// Internal net declaration
	
	type_state state_i_s;
	logic bypass_xor_end_s;
	logic mode_xor_key_s;
	logic [127:0] key_s;
	type_state state_o_s;

	//DUT : component instanciation
	xor_end DUT (
		.state_i(state_i_s),
		.state_o(state_o_s),
		.bypass_xor_end_i(bypass_xor_end_s),
		.key_i(key_s),
        	.mode_xor_key_i(mode_xor_key_s)
		);

	initial begin
		
		key_s=128'h691AED630E81901F6CB10AD9CA912F80;
		state_i_s[0]= 64'h82bf91294ba5808d ;		
		state_i_s[1]= 64'hd81eeca694136f8a ;
		state_i_s[2]= 64'h0217bc9ebd9fff02 ;
		state_i_s[3]= 64'h4dd2c87c59c2fb48;
		state_i_s[4]= 64'h4e2b20c3e9eb3044;

		    
		 // Test cas 1: xor transparent
		bypass_xor_end_s = 1'b1;
		mode_xor_key_s = 1'b1;

		#10;
		// Test cas 2: xor avec key 
		bypass_xor_end_s = 1'b0;
		mode_xor_key_s = 1'b1;

		#10;
		// Test cas 3: xor avec 1 (seul bit 63 )
		mode_xor_key_s = 1'b0;
		//  state_o[4]=0xC6487B3E06D9D7A8 
	

    	end
	
endmodule: xor_end_tb
	
