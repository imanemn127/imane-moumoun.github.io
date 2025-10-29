//Imane MOUMOUN
//substitution.sv

`timescale 1ns / 1ps

import ascon_pack::*;

module substitution

 	( 
	input type_state state_i,
	output type_state substitution_o);

	//declaration variable pour generacite
	genvar i;
	generate  //on utilise la structure generate pour instancier 64 S-box en parallèle (une par colonne)

		for (i = 0; i < 64; i++) begin : g_sbox  // parcours collone
			
			// Chaque S-box opère sur 5 bits 
			sbox inst_sbox (
				 .sbox_i( {state_i[0][i],state_i[1][i],state_i[2][i],state_i[3][i], state_i[4][i]}),
				 .sbox_o({substitution_o[0][i],substitution_o[1][i],substitution_o[2][i],substitution_o[3][i], substitution_o[4][i]})
			 );

		end : g_sbox

	endgenerate  
			
 
endmodule : substitution
	
