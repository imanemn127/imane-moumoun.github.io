//Imane MOUMOUN
//fsm_moore_init_tb

`timescale 1ns / 1ps

module fsm_moore_init_tb (
	//empty declarative part
	);
	// Internal net declaration
	logic clock_s, resetb_s, start_s, end_initialisation_s;
	logic [3:0] round_s;
	logic input_mode_s, en_reg_state_s, bypass_xor_end_s;
	logic mode_xor_key_s, en_cpt_double_s, init_p12_s;
	

	//DUT : component instanciation
	fsm_moore_init DUT (
		.start_i(start_s),
		.resetb_i(resetb_s),
		.clock_i(clock_s),
		.round_i(round_s),
		.end_initialisation_o(end_initialisation_s),
		.input_mode_o(input_mode_s),
		.en_reg_state_o(en_reg_state_s),
		.bypass_xor_end_o(bypass_xor_end_s),
		.mode_xor_key_o(mode_xor_key_s),
		.en_cpt_double_o(en_cpt_double_s),
		.init_p12_o(init_p12_s)
		);


	//clock generation
	initial begin
		clock_s = 1'b0;
		forever #5 clock_s = ~clock_s;
	end

	//stimuli
	initial begin
		resetb_s = 1'b0;
		start_s = 1'b0;
		round_s=4'h0;

		#2;
		$display("reset du circuit");
		resetb_s = 1'b1;

		#8;
		$display("debut du chiffrement");
		start_s = 1'b1;

		@(posedge clock_s);
		start_s = 1'b0;

		@(posedge clock_s);
		while (end_initialisation_s != 1'b1) begin
			#10;
			 if (round_s < 4'hb) 
                		round_s = round_s + 1;
		end
	
		$display("fin de la phase d'initialisation");
		$stop;
	end
		
endmodule : fsm_moore_init_tb
