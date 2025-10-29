`timescale 1ns / 1ps

module sbox_tb
	(
	//empty declarative part
	);
	// Internal net declaration
	logic [4:0] sbox_i_s ;
	logic [4:0] sbox_o_s ;

	//DUT : component instanciation
	sbox DUT (
		.sbox_i(sbox_i_s),
		.sbox_o(sbox_o_s)
		);

	//stimuli generation
	initial begin
		sbox_i_s= 5'h04 ; //sbox collonne , sbox_i = x
		

		#25;
		sbox_i_s= 5'h15;
	end

endmodule: sbox_tb



