//Imane MOUMOUN
//permutation_xor_reg: ajout 2 registre pour memoriser tag et cipher

`timescale 1ns / 1ps

import ascon_pack::*;

module permutation_xor_reg
	
	(
	input  type_state permutation_i,
	input logic input_mode_i, 
	input logic[3:0] round_i,
	input logic clock_i,
	input logic resetb_i,
	input logic enable_i,
	input logic en_reg_cipher_i,
	input logic en_reg_tag_i,
	input logic bypass_xor_end_i,
	input logic mode_xor_key_i,
	input logic en_xor_begin_data_i,
	input logic en_xor_begin_key_i,
	input logic[127:0] key_i,
	input logic[127:0] data_i,
	input logic[127:0] nonce_i,

	output type_state permutation_o,
	output logic[127:0] cipher_o,
	output logic[127:0] tag_o
	);

	//internal net declaration
	type_state mux_to_xor_s, xor_to_add_s, add_to_sub_s, sub_to_diff_s, diff_to_xor_s, xor_to_reg_s;
	type_state permutation_loop_s;
	logic [127:0] xor_to_cipher_s;
	logic [127:0] permutation_to_tag_s;

	assign xor_to_cipher_s= {xor_to_add_s[1],xor_to_add_s[0]};
	assign permutation_to_tag_s= {permutation_loop_s[4],permutation_loop_s[3]};

	//structural description
	mux_state mux (
	     .input1_i(permutation_loop_s),
	     .input0_i(permutation_i),
	     .select_i(input_mode_i),
	     .mux_o(mux_to_xor_s)
	);

	xor_begin xor_begin(
		.en_xor_begin_data_i(en_xor_begin_data_i),
		.en_xor_begin_key_i(en_xor_begin_key_i),
		.key_i(key_i),
		.data_i(data_i),
		.state_i(mux_to_xor_s),
		.state_o(xor_to_add_s)
	);

	register_w_en #(
		.nb_bits_g(128)
		
	) reg_cipher (
		.data_i(xor_to_cipher_s),
	 	.clock_i(clock_i),
		.resetb_i(resetb_i),
		.en_i( en_reg_cipher_i),
		.data_o( cipher_o)		
	);

	constante_add add (
	     .state_i(xor_to_add_s),
	     .round_i(round_i),
	     .state_o(add_to_sub_s)
	);

	substitution sub (
	     .state_i(add_to_sub_s),
	     .substitution_o(sub_to_diff_s)
	);

	diffusion diff(
	     .state_i(sub_to_diff_s),
	     .diffusion_o(diff_to_xor_s)
	);

	xor_end xor_end(
		.bypass_xor_end_i(bypass_xor_end_i),
		.mode_xor_key_i( mode_xor_key_i),
		.key_i(key_i),
		.state_i(diff_to_xor_s),
		.state_o(xor_to_reg_s)
	);

	reg_state reg_state(
	     .d_i(xor_to_reg_s),
 	     .clock_i(clock_i),
	     .resetb_i(resetb_i),
             .enable_i(enable_i),
	     .q_o( permutation_loop_s)
	);

	register_w_en #(
		.nb_bits_g(128)
	) reg_tag (
		.data_i(permutation_to_tag_s),
	 	.clock_i(clock_i),
		.resetb_i(resetb_i),
		.en_i( en_reg_tag_i),
		.data_o(tag_o)		
	);

	assign permutation_o = permutation_loop_s;
;

endmodule : permutation_xor_reg
	


