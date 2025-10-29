//Imane MOUMOUN
//constante_add.sv

`timescale 1ns / 1ps

import ascon_pack::*;

module  constante_add 

	( input type_state state_i, 
	input logic[3:0] round_i,
	output type_state state_o);

	assign state_o[0]= state_i[0]; //les registres 0, 1, 3 et 4 de state_i sont directement recopiés dans state_o
	assign state_o[1]= state_i[1];
	assign state_o[3]= state_i[3];
	assign state_o[4]= state_i[4];

	assign state_o[2][63:8] = state_i[2][63:8];
	assign state_o[2][7:0] = state_i[2][7:0] ^ round_constant[round_i]; //Seul l’octet de poids faible du registre 2 est modifié, en effectuant un XOR avec la constante de round

endmodule: constante_add
