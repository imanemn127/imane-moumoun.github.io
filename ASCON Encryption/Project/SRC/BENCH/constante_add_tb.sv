//Imane MOUMOUN
//constante_add_tb

`timescale 1ns / 1ps

import ascon_pack::*;

module constante_add_tb

 	(
	//empty declarative part
	);
	// Internal net declaration
	logic [3:0] round_s ;
	type_state state_i_s, state_o_s;

	//DUT : component instanciation
	constante_add DUT (
		.state_i(state_i_s),
		.state_o(state_o_s),
		.round_i(round_s)
		);

	//stimuli generation
	initial begin
		state_i_s[0]= 64'h00001000808C0001 ;		
		state_i_s[1]= 64'h6CB10AD9CA912F80 ;
		state_i_s[2]= 64'h691AED630E81901F ;
		state_i_s[3]= 64'h0C4C36A20853217C ;
		state_i_s[4]= 64'h46487B3E06D9D7A8;
		round_s = 4'h0;

		#10;
		state_i_s[0]= 64'h932c16dd634b9585 ;		
		state_i_s[1]= 64'hb48a3c3fe8fb45ce ;
		state_i_s[2]= 64'ha69f28b0c721c340 ;
		state_i_s[3]= 64'h05e1761f1e1fcb67 ;
		state_i_s[4]= 64'h64d322a896b791cf;
		round_s = 4'h1;

		#10;
		state_i_s[0]= 64'h42094eaa32d8178a ;		
		state_i_s[1]= 64'hd497391f109fdf5a ;
		state_i_s[2]= 64'ha9337d973985c830 ;
		state_i_s[3]= 64'h3d727835f938378c ;
		state_i_s[4]= 64'h67306d896d9ad434;
		round_s = 4'h2;

		#10;
		state_i_s[0]= 64'h069274b022ebe097 ;		
		state_i_s[1]= 64'h0d52a8bc80a5668b ;
		state_i_s[2]= 64'hff770f7bc41d20ed;
		state_i_s[3]= 64'h5767f307dfdc57ca ;
		state_i_s[4]= 64'hab9b9a442952e201;
		round_s = 4'h3;
          	
 
	end

endmodule : constante_add_tb
