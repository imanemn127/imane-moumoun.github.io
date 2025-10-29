//Imane MOUMOUN
//permutation_xor_tb


`timescale 1ns / 1ps

import ascon_pack::*;

module permutation_xor_tb 
	
	(
	//empty declarative part
	);

	// Internal net declaration
	logic clock_s, resetb_s, enable_s, input_mode_s;
	logic[3:0] round_s; 
	logic bypass_xor_end_s;
	logic en_xor_begin_key_s;
	logic en_xor_begin_data_s;
	logic mode_xor_key_s;
	logic [127:0] key_s;
	logic [127:0] data_s;
	type_state permutation_i_s, permutation_o_s;

	//DUT : component instanciation
	permutation_xor DUT (
		.permutation_i(permutation_i_s),
		.resetb_i(resetb_s),
		.clock_i(clock_s),
		.enable_i(enable_s),
		.input_mode_i(input_mode_s),
		.round_i(round_s),
		.permutation_o(permutation_o_s),
		.bypass_xor_end_i(bypass_xor_end_s),
		.en_xor_begin_key_i(en_xor_begin_key_s),
		.en_xor_begin_data_i(en_xor_begin_data_s),
		.key_i(key_s),
		.data_i(data_s),
        	.mode_xor_key_i(mode_xor_key_s)
		);

	//clock generation
	initial begin
		clock_s = 1'b0;
		forever #5 clock_s = ~clock_s;
		end

	// stimuli
	initial begin
		
		key_s=128'h691AED630E81901F6CB10AD9CA912F80; 
		data_s= 128'h6F74206563696C4100000001626F4220; //A1
		
		permutation_i_s[0]= 64'h82BF91294BA5808D; //pour tester 2eme bloc ou figurent xor_end et xor_begin	
		permutation_i_s[1]= 64'hD81EECA694136F8A;
		permutation_i_s[2]= 64'h0217BC9EBD9FFF02;
		permutation_i_s[3]= 64'h2163C2A59353D4C8;
		permutation_i_s[4]= 64'h2731CDA0E76AA05B;

		resetb_s = 1'b0;
		round_s = 4'h4;
		enable_s= 1'b0;
		bypass_xor_end_s = 1'b1;
		mode_xor_key_s=1'b0;
		en_xor_begin_data_s= 1'b1;
		en_xor_begin_key_s= 1'b0;
		input_mode_s=1'b0;

		#2;
		resetb_s = 1'b1;
	
		#8
		enable_s= 1'b1;
		
		@(posedge clock_s);
		input_mode_s =1'b1;
		round_s= 4'h5;
		en_xor_begin_data_s= 1'b0;
		en_xor_begin_key_s= 1'b0;
		@(posedge clock_s);
		round_s= 4'h6;
		@(posedge clock_s);
		round_s= 4'h7;
		@(posedge clock_s);
		round_s= 4'h8;
		@(posedge clock_s);
		round_s= 4'h9;
		@(posedge clock_s);
		round_s= 4'ha;
		@(posedge clock_s);
		round_s= 4'hb;
		bypass_xor_end_s=1'b0;
		@(posedge clock_s);
		#10;
		enable_s= 1'b0;
		$stop;
		
		
	end

endmodule : permutation_xor_tb

