//Imane MOUMOUN
//fsm_moore_init

`timescale 1ns/1ps

module fsm_moore_init (

	input logic start_i,
	input logic  clock_i ,
	input logic  resetb_i,
	logic [3:0] round_i,

	output logic input_mode_o,
	output logic en_reg_state_o,
	output logic bypass_xor_end_o,
	output logic mode_xor_key_o,
	output logic en_cpt_double_o,
	output logic init_p12_o,
	output logic end_initialisation_o
	);


	//def type enumere
	typedef enum{ idle, conf_init, end_conf_init, init,end_init, end_fsm} state_t;

	// declaration de 2 cas pour l'etat
	state_t current_state;
	state_t next_state;

	//modelisation du registre des etats
	always_ff@(posedge clock_i, negedge resetb_i)
		begin: seq_0
			if(resetb_i ==1'b0)
				current_state <= idle;
			else current_state <= next_state;
		end : seq_0

	//modelisation des transitions
	always_comb
		begin: comb_0
			case(current_state)
				idle:	
					if(start_i ==1'b1) next_state = conf_init;
					else next_state = idle;
				conf_init: next_state = end_conf_init;
				end_conf_init:  next_state = init;
				init:   
					if(round_i ==4'ha)  next_state = end_init;
					else next_state= init;
				end_init: next_state = end_fsm;
			
				default: next_state= idle;
			endcase
		end : comb_0

	//modelisation des sorties
	always_comb
		begin: comb_1
			//valeurs par defaut
			input_mode_o=1'b1;
			en_reg_state_o=1'b0;     
			bypass_xor_end_o=1'b1;
			mode_xor_key_o=1'b1;
			en_cpt_double_o=1'b0;
			init_p12_o=1'b0; 
			end_initialisation_o=1'b0;

			
			case(current_state)
				idle:	begin
					en_cpt_double_o= 1'b0;
					end
				conf_init: begin
					en_cpt_double_o= 1'b1;
					init_p12_o= 1'b1;
					end
				end_conf_init:  begin   //round 0
					en_reg_state_o= 1'b1;
					en_cpt_double_o= 1'b1;
					init_p12_o= 1'b0;
					input_mode_o= 1'b0; //pour prendre permutation_i
					end
				init:   begin        //round 1-10
					en_reg_state_o= 1'b1;
					en_cpt_double_o=1'b1;
					end
				end_init: begin        //round 11  
					en_reg_state_o= 1'b1;
					en_cpt_double_o= 1'b0;
					bypass_xor_end_o = 1'b0;   //activer xor_end
					mode_xor_key_o=1'b1;    
					end
				end_fsm: begin
					end_initialisation_o= 1'b1; //fin initialisation
					end
				default: ;
			endcase
		end : comb_1
	

endmodule: fsm_moore_init
