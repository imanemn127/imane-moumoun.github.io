//Imane MOUMOUN
//ascon_top.sv


`timescale 1 ns / 1 ps

import ascon_pack::*;

module ascon_top
	
	(
	input logic start_i,
	input logic  data_valid_i,
	input logic  clock_i ,
	input logic  resetb_i,
	input logic[127:0] key_i,
	input logic[127:0] data_i,
	input logic[127:0] nonce_i,
	
	output logic cipher_valid_o,
	output logic [127:0] cipher_o,
	output logic [127:0] tag_o,
	output logic end_initialisation_o,
	output logic end_associate_o,
	output logic end_cipher1_o,
	output logic end_cipher2_o,
	output logic end_o
	);

	//internal net declaration
	type_state permutation_i_s, permutation_o_s;
	logic [3:0] round_s;
	logic input_mode_s, en_reg_state_s, bypass_xor_end_s, mode_xor_key_s, en_xor_begin_data_s, en_xor_begin_key_s,  en_cpt_double_s, en_reg_cipher_s, en_reg_tag_s, init_p12_s, init_p8_s; 


	assign permutation_i_s = {64'h00001000808c0001, key_i[63:0], key_i[127:64], nonce_i[63:0], nonce_i[127:64]};
	
	
	//structural description
	compteur_double compteur_ronde(
		.clock_i(clock_i),
    		.resetb_i(resetb_i),
   		.en_i(en_cpt_double_s),
   		.init_p12_i(init_p12_s),
    		.init_p8_i(init_p8_s),
    		.cpt_o (round_s)   
    	);

	fsm_moore fsm_moore(
		.start_i(start_i),
		.data_valid_i(data_valid_i),
		.clock_i(clock_i),
		.resetb_i(resetb_i),
		.round_i(round_s),
		.input_mode_o(input_mode_s),
		.en_reg_state_o(en_reg_state_s),
		.en_xor_begin_data_o(en_xor_begin_data_s),
		.en_xor_begin_key_o(en_xor_begin_key_s),
		.bypass_xor_end_o(bypass_xor_end_s),
		.mode_xor_key_o(mode_xor_key_s),
		.en_reg_cipher_o(en_reg_cipher_s),
		.en_reg_tag_o(en_reg_tag_s),
		.en_cpt_double_o(en_cpt_double_s),
		.init_p12_o(init_p12_s),
		.init_p8_o(init_p8_s),
		.cipher_valid_o(cipher_valid_o),
		.end_initialisation_o(end_initialisation_o),
		.end_associate_o(end_associate_o),
		.end_cipher1_o(end_cipher1_o),
		.end_cipher2_o(end_cipher2_o),
		.end_o(end_o)
	);

	permutation_xor_reg permutation_xor_reg(
		.permutation_i(permutation_i_s),
		.permutation_o(permutation_o_s),
		.clock_i(clock_i),
		.resetb_i(resetb_i),
		.round_i(round_s),
		.key_i(key_i),
		.data_i(data_i),
		.input_mode_i(input_mode_s),
		.enable_i(en_reg_state_s),
		.en_reg_cipher_i(en_reg_cipher_s),
		.en_reg_tag_i(en_reg_tag_s),
		.en_xor_begin_data_i(en_xor_begin_data_s),
		.en_xor_begin_key_i(en_xor_begin_key_s),
		.bypass_xor_end_i(bypass_xor_end_s),
		.mode_xor_key_i(mode_xor_key_s),
		.cipher_o(cipher_o),
		.tag_o(tag_o)
	);
		

endmodule: ascon_top
