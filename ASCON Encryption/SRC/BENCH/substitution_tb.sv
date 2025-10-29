`timescale 1ns / 1ps

module substitution_tb
	import ascon_pack::*;
	(
	//empty declarative part
	);
	// Internal net declaration
	type_state state_i_s;
	type_state substitution_o_s;

	//DUT : component instanciation
	substitution DUT (
		.state_i(state_i_s),
		.substitution_o(substitution_o_s)
		);

	//stimuli generation
	initial begin
		state_i_s[0]= 64'h00001000808C0001 ;		
		state_i_s[1]= 64'h6CB10AD9CA912F80 ;
		state_i_s[2]= 64'h691AED630E8190EF ;
		state_i_s[3]= 64'h0C4C36A20853217C ;
		state_i_s[4]= 64'h46487B3E06D9D7A8;
	

		#50;
		state_i_s[0]= 64'h932c16dd634b9585 ;		
		state_i_s[1]= 64'hb48a3c3fe8fb45ce ;
		state_i_s[2]= 64'ha69f28b0c721c3A1 ;
		state_i_s[3]= 64'h05e1761f1e1fcb67 ;
		state_i_s[4]= 64'h64d322a896b791cf;
	

		

		
	end

endmodule: substitution_tb

