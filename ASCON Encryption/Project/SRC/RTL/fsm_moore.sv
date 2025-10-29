//Imane MOUMOUN
//fsm_moore

`timescale 1ns/1ps

module fsm_moore (

	input logic start_i,
	input logic  data_valid_i,
	input logic  clock_i ,
	input logic  resetb_i,
	input logic [3:0] round_i,

	output logic input_mode_o,
	output logic en_reg_state_o,
	output logic en_xor_begin_data_o,
	output logic en_xor_begin_key_o,
	output logic bypass_xor_end_o,
	output logic mode_xor_key_o,
	output logic en_reg_cipher_o,
	output logic en_reg_tag_o,
	output logic en_cpt_double_o,
	output logic init_p12_o,
	output logic init_p8_o,
	output logic cipher_valid_o,
	output logic end_initialisation_o,
	output logic end_associate_o,
	output logic end_cipher1_o,
	output logic end_cipher2_o,
	output logic end_o
	);


	//def type enumere
	typedef enum{ idle, conf_init, end_conf_init, init,end_init, idle_da, conf_da, end_conf_da, da,end_da, idle_cipher1, conf_cipher1, end_conf_cipher1, cipher1,end_cipher1, idle_cipher2, conf_cipher2, end_conf_cipher2, cipher2, end_cipher2, idle_fin, conf_fin, end_conf_fin, fin ,end_fin, end_fsm} state_t;

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
					if(start_i ==1'b1)  next_state = conf_init;
					else next_state= idle;
				conf_init: next_state=end_conf_init;
				end_conf_init:  next_state= init;
				init:   
					if(round_i ==4'ha)  next_state= end_init;
					else next_state= init;
				end_init: next_state=idle_da;
				
				idle_da: 
					if(data_valid_i ==1'b1)   next_state= conf_da;
					else next_state= idle_da;
				
				conf_da: next_state=end_conf_da;
				end_conf_da:  next_state= da;
				da:   
					if(round_i ==4'ha)  next_state= end_da;
					else next_state= da;
				end_da: next_state=idle_cipher1;

				idle_cipher1: 
					if(data_valid_i ==1'b1)   next_state= conf_cipher1;
					else next_state= idle_cipher1;
				
				conf_cipher1: next_state=end_conf_cipher1;
				end_conf_cipher1:  next_state= cipher1;
				cipher1:   
					if(round_i ==4'ha)  next_state= end_cipher1;
					else next_state= cipher1;
				end_cipher1: next_state=idle_cipher2;

				idle_cipher2: 
					if(data_valid_i==1'b1)   next_state= conf_cipher2;
					else next_state= idle_cipher2;
				
				conf_cipher2: next_state=end_conf_cipher2;
				end_conf_cipher2:  next_state= cipher2;
				cipher2:   
					if(round_i ==4'ha)  next_state= end_cipher2;
					else next_state= cipher2;
				end_cipher2: next_state=idle_fin;

				idle_fin: 
					if(data_valid_i ==1'b1)   next_state= conf_fin;
					else next_state= idle_fin;
				
				conf_fin: next_state=end_conf_fin;
				end_conf_fin: next_state= fin;
				fin:   
					if(round_i ==4'ha)  next_state= end_fin;
					else next_state= fin;
				end_fin: next_state=end_fsm;

				default: next_state= idle;
			endcase
	end : comb_0

	//modelisation des sorties
	always_comb
		begin: comb_1
			//valeurs par defaut
			input_mode_o=1'b1;
			en_reg_state_o=1'b0;     
			en_xor_begin_data_o=1'b0;
			en_xor_begin_key_o=1'b0;
			bypass_xor_end_o=1'b1;
			mode_xor_key_o=1'b1;
			en_reg_cipher_o=1'b0;
			en_reg_tag_o=1'b0;
			en_cpt_double_o=1'b0;
			init_p12_o=1'b0; 
			init_p8_o=1'b0; 
			end_o=1'b0;
			cipher_valid_o=1'b0;
			end_cipher1_o=1'b0;
			end_cipher2_o=1'b0;
			end_initialisation_o=1'b0;
			end_associate_o =1'b0;

			
			case(current_state)
				idle:	begin
					end_o = 1'b0;
					en_cpt_double_o= 1'b0;
					end
				conf_init: begin
					en_cpt_double_o= 1'b1;
					init_p12_o= 1'b1;
					end
				end_conf_init:  begin   //round 0
					input_mode_o= 1'b0;//pour prendre permutation_i
					en_reg_state_o= 1'b1;
					en_cpt_double_o= 1'b1;
					init_p12_o= 1'b0;
					end
				init:   begin        //round 1-10
					en_reg_state_o= 1'b1;
					en_cpt_double_o=1'b1;
					end
				end_init: begin        //round 11  
					bypass_xor_end_o = 1'b0;   //activer xor_end
					mode_xor_key_o=1'b1;      
					en_reg_state_o= 1'b1;
					en_cpt_double_o= 1'b0;
					end

				idle_da: begin
					en_reg_state_o= 1'b0; //on a atteint p12
					end_initialisation_o= 1'b1; //on a finit la phase d'initialisation
					end
				conf_da: begin
					en_cpt_double_o= 1'b1;
					init_p8_o= 1'b1;
					end
				end_conf_da: begin  	//round 4
					en_xor_begin_data_o=1'b1; //xor_begin avec donnee associe A1
					en_reg_state_o= 1'b1;
					en_cpt_double_o= 1'b1;
					init_p8_o= 1'b0;
					end
				da: begin	//round 5-10
					en_reg_state_o= 1'b1;
					en_cpt_double_o= 1'b1;
					end
				end_da: begin  //round 11
					bypass_xor_end_o=1'b0; //activer xor_end	
					mode_xor_key_o =1'b0; //xor avec 1
					en_reg_state_o= 1'b1;
					en_cpt_double_o= 1'b0;
					end
				
				idle_cipher1: begin
					en_reg_state_o= 1'b0; //on a atteint p12
					end_associate_o= 1'b1; //on a finit la phase donnee associe
					end
				conf_cipher1: begin
					en_cpt_double_o= 1'b1;
					init_p8_o= 1'b1;
					end
				end_conf_cipher1: begin   //round 4
					en_xor_begin_data_o=1'b1; //xor_begin avec P1 
					en_reg_cipher_o= 1'b1;   //C1
					en_reg_state_o= 1'b1;
					en_cpt_double_o= 1'b1;
					init_p8_o= 1'b0;
					end
				cipher1: begin   //round 5-10
					cipher_valid_o=1'b1;
					en_reg_state_o= 1'b1;
					en_cpt_double_o= 1'b1;
					end
				end_cipher1: begin  //round 11
					en_reg_state_o= 1'b1;
					en_cpt_double_o= 1'b0;
					end

				idle_cipher2: begin
					en_reg_state_o= 1'b0; //on a atteint p12
					end_cipher1_o= 1'b1; //on a finit le premier bloc de la phase texte clair
					end
				conf_cipher2: begin
					en_cpt_double_o= 1'b1;
					init_p8_o= 1'b1;
					end
				end_conf_cipher2: begin   //round 4
					en_xor_begin_data_o=1'b1; //xor_begin avec P2
					en_reg_cipher_o= 1'b1;   //C2
					en_reg_state_o= 1'b1;
					en_cpt_double_o= 1'b1;
					init_p8_o= 1'b0;
					end
				cipher2: begin   //round 5-10
					cipher_valid_o=1'b1;
					en_reg_state_o= 1'b1;
					en_cpt_double_o= 1'b1;
					end
				end_cipher2: begin  //round 11
					en_reg_state_o= 1'b1;
					en_cpt_double_o= 1'b0;
					end

				idle_fin: begin
					en_reg_state_o= 1'b0; //on a atteint p12
					end_cipher2_o= 1'b1; //on a finit le deuxieme bloc de la phase chiffrement
					end
				conf_fin: begin
					en_cpt_double_o= 1'b1;
					init_p12_o= 1'b1;
					end
				end_conf_fin: begin   //round 0
					en_xor_begin_data_o=1'b1; //xor avec data P3
					en_reg_cipher_o= 1'b1;   //C3
					en_xor_begin_key_o=1'b1;
					en_reg_state_o= 1'b1;
					en_cpt_double_o= 1'b1;
					init_p12_o= 1'b0;
					end
				fin: begin   //round 1-10
					cipher_valid_o=1'b1;
					en_reg_state_o= 1'b1;
					en_cpt_double_o= 1'b1;
					end
				end_fin: begin  //round 11
					bypass_xor_end_o=1'b0; //activer xor_end	
					mode_xor_key_o =1'b1;  //xor avec key
					en_reg_state_o= 1'b1;
					en_cpt_double_o= 1'b0;
					end
				end_fsm: begin
					en_reg_tag_o = 1'b1;
					end_o= 1'b1; //on a finit la phase de finalisation
					end

				default: ;
			endcase
	end : comb_1
endmodule: fsm_moore
