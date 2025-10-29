//Imane MOUMOUN 
//xor_end

`timescale 1ns / 1ps

import ascon_pack::*;

module xor_end
	(
	input  type_state state_i,
	input logic bypass_xor_end_i, 
	input logic mode_xor_key_i,
	input logic [127:0] key_i,
	output type_state state_o
	);
	

	// Déclaration des variables internes

	type_state state_s;  // Variable pour stocker l'état modifié
	
	 always @(*) begin 
		if(bypass_xor_end_i == 1'b1)       //xor transparent
			state_s= state_i;   
		else   begin    //xor active

			state_s[0] = state_i[0];
			state_s[1] = state_i[1];
			state_s[2] = state_i[2];

			if ( mode_xor_key_i == 1'b1) begin
				state_s[3] = state_i[3] ^ key_i[63:0]; //XOR de la partie 3 avec les 64 bits inférieurs de la clé
				state_s[4] = state_i[4] ^ key_i[127:64];  // XOR de la partie 4 avec les 64 bits supérieurs de la clé

			end else begin  // le xor du milieu
				state_s[3] = state_i[3];
				state_s[4][62:0] = state_i[4][62:0];   //Conservation des 63 premiers bits de la partie 4
				state_s[4][63] = state_i[4][63] ^ 1'b1;  // XOR uniquement sur le bit 63
			end 
		end
	end 

	// Assignation de l'état final modifié
	assign state_o = state_s;

endmodule: xor_end
