//Imane MOUMOUN
//permutation_simple_tb

import ascon_pack::*;

`timescale 1ns / 1ps

module permutation_simple_tb 
	
	(
	//empty declarative part
	);

	// Internal net declaration
	bit clock_s, resetb_s, enable_s, input_mode_s;
	logic[3:0] round_s; 
	type_state permutation_i_s, permutation_o_s;

	//DUT : component instanciation
	permutation_simple DUT (
		.permutation_i(permutation_i_s),
		.resetb_i(resetb_s),
		.clock_i(clock_s),
		.enable_i(enable_s),
		.input_mode_i(input_mode_s),
		.round_i(round_s),
		.permutation_o(permutation_o_s)
		);

	//clock generation
	initial begin
		clock_s = 1'b0;
		forever #5 clock_s = ~clock_s;
		end// stimuli
	initial begin
		

		permutation_i_s[0]= 64'h00001000808C0001 ;		
		permutation_i_s[1]= 64'h6CB10AD9CA912F80 ;
		permutation_i_s[2]= 64'h691AED630E81901F ;
		permutation_i_s[3]= 64'h0C4C36A20853217C ;
		permutation_i_s[4]= 64'h46487B3E06D9D7A8;

		resetb_s = 1'b0;
		round_s = 4'h0;
		enable_s= 1'b0;
		input_mode_s=1'b0;

		#2
		resetb_s = 1'b1;

		#8;
		enable_s= 1'b1;
		@(posedge clock_s);
		input_mode_s =1'b1;

		round_s= 4'h1;
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
		@(posedge clock_s);
		#10;
		enable_s= 1'b0;
		$stop;
		
	end

endmodule : permutation_simple_tb

