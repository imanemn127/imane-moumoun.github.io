//Imane MOUMOUN
//permutation_xor_reg_tb


`timescale 1ns / 1ps

import ascon_pack::*;

module permutation_xor_reg_tb 
	
	(
	//empty declarative part
	);

	// Internal net declaration
	logic clock_s, resetb_s, enable_s, en_reg_tag_s, en_reg_cipher_s,input_mode_s;
	logic[3:0] round_s; 
	logic bypass_xor_end_s; 
	logic mode_xor_key_s;
	logic en_xor_begin_key_s;
	logic en_xor_begin_data_s;
	logic [127:0] key_s;
	logic [127:0] data_s;
	type_state permutation_i_s, permutation_o_s;
	logic [127:0] cipher_o_s, tag_o_s;

	//DUT : component instanciation
	permutation_xor_reg DUT (
		.permutation_i(permutation_i_s),
		.resetb_i(resetb_s),
		.clock_i(clock_s),
		.enable_i(enable_s),
		.en_reg_tag_i(en_reg_tag_s),
		.en_reg_cipher_i(en_reg_cipher_s),
		.input_mode_i(input_mode_s),
		.round_i(round_s),
		.permutation_o(permutation_o_s),
		.bypass_xor_end_i(bypass_xor_end_s),
		.en_xor_begin_key_i(en_xor_begin_key_s),
		.en_xor_begin_data_i(en_xor_begin_data_s),
		.key_i(key_s),
		.data_i(data_s),
        	.mode_xor_key_i(mode_xor_key_s),
		.tag_o(tag_o_s),
		.cipher_o(cipher_o_s)
		);

	//clock generation
	initial begin
		clock_s = 1'b0;
		forever #5 clock_s = ~clock_s;
		end

	// stimuli
	initial begin

		key_s=128'h691AED630E81901F6CB10AD9CA912F80;
		data_s= 128'h4D20746E75696E65013F206172656E75;   //P3 : j'ai inversé la valeur fourni dans l'énoncé en ajoutant le padding afin d'obtenir la valeur attendue
		permutation_i_s[0]= 64'h2c3bc95b7a50915f; //pour tester la phase de finalisation qui fournit le tag	
		permutation_i_s[1]= 64'h7b7d99f4d259f8b6;
		permutation_i_s[2]= 64'h5559f34990428d74;
		permutation_i_s[3]= 64'h9d90ceeb92993b0f;
		permutation_i_s[4]= 64'h0693aa3bd58fed41;

		resetb_s = 1'b0;
		round_s = 4'h0;
		enable_s= 1'b0;
		en_reg_tag_s=1'b0;
		en_reg_cipher_s=1'b1;
		bypass_xor_end_s = 1'b1;
		mode_xor_key_s=1'b1;
		en_xor_begin_key_s=1'b1;
		en_xor_begin_data_s=1'b1;
		input_mode_s=1'b0;

		#2;
		resetb_s = 1'b1;
	
		#8
		enable_s= 1'b1;

		@(posedge clock_s);
		round_s= 4'h1;
		input_mode_s=1'b1;
		en_reg_cipher_s=1'b0;
		en_xor_begin_key_s=1'b0;
		en_xor_begin_data_s=1'b0;

		@(posedge clock_s);
		round_s= 4'h2;

		@(posedge clock_s);
		round_s= 4'h3;

		@(posedge clock_s);
		round_s= 4'h4;

		@(posedge clock_s);
		round_s= 4'h5;

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
		enable_s= 1'b0;
		en_reg_tag_s=1'b1;
		bypass_xor_end_s=1'b1;

		@(posedge clock_s);
		en_reg_tag_s=1'b0;

		#10;
		$stop;
		
		
	end

endmodule : permutation_xor_reg_tb

