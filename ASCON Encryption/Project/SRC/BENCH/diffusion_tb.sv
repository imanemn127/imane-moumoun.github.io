`timescale 1ns / 1ps

import ascon_pack::*;

module diffusion_tb

	(
	//empty declarative part
	);
	// Internal net declaration
	type_state state_i_s;
	type_state diffusion_o_s;

	//DUT : component instanciation
	diffusion DUT (
		.state_i(state_i_s),
		.diffusion_o(diffusion_o_s)
		);

	//stimuli generation
	initial begin
		state_i_s[0]= 64'h25f7c341c45f9912 ;		
		state_i_s[1]= 64'h23b794c540876856 ;
		state_i_s[2]= 64'hb85451593d679610;
		state_i_s[3]= 64'h4fafba264a9e49ba ;
		state_i_s[4]= 64'h62b54d5d460aded4;
	

		#50;
		state_i_s[0]= 64'h94d8684872579d47 ;		
		state_i_s[1]= 64'h44806ada0a028aa5 ;
		state_i_s[2]= 64'h8df8ebd050856918 ;
		state_i_s[3]= 64'he12b4270c43159c2 ;
		state_i_s[4]= 64'h61325cbd80ab1b2c;

      	end

endmodule : diffusion_tb
