//Imane MOUMOUN
//ascon_top_tb.sv


`timescale 1 ns / 1 ps

 import ascon_pack::*;

module ascon_top_tb
 
	(
	    //vide
	);

	  // Internal net declaration
	  logic clock_s;
	  logic resetb_s;
	  logic start_s;
	  logic [127:0] key_s;
	  logic [127:0] nonce_s;
	  logic [127:0] data_s;
	  logic data_valid_s;
	  logic cipher_valid_s;
	  logic [127:0] cipher_s;
	  logic end_s;
	  logic end_initialisation_s;
	  logic end_associate_s;
	  logic end_cipher1_s;
	  logic end_cipher2_s;
	  logic [127:0] tag_s;


	  ascon_top DUT (
	      .clock_i(clock_s),
	      .resetb_i(resetb_s),
	      .start_i(start_s),
	      .key_i(key_s),
	      .nonce_i(nonce_s),
	      .data_i(data_s),
	      .data_valid_i(data_valid_s),
	      .cipher_valid_o(cipher_valid_s),
	      .cipher_o(cipher_s),
	      .end_o(end_s),
	      .end_initialisation_o(end_initialisation_s),
	      .end_associate_o(end_associate_s),
	      .end_cipher1_o(end_cipher1_s),
	      .end_cipher2_o(end_cipher2_s),
	      .tag_o(tag_s)
	  );

	  //horloge
	  initial begin
	    clock_s = 0;
	    forever #10 clock_s = ~clock_s;
	  end

	  //stimuli
	  initial begin
		    resetb_s = 0;
		    key_s = 128'h691AED630E81901F6CB10AD9CA912F80;
		    nonce_s = 128'h46487B3E06D9D7A80C4C36A20853217C;
		    start_s = 0;
		    data_s = '0;
		    data_valid_s = 0;

		    #40;
		    $display("reset du circuit");
		    resetb_s = 1;

		    #100;
		    $display("début du chiffrement");
		    start_s = 1;
		    #20;
		    start_s = 0;
		    do begin
		      #20;
		    end while (end_initialisation_s != 1'b1);
		    $display("fin de la phase d'initialisation");
		    

		    data_s = 128'h6F74206563696C4100000001626F4220; //A1: j'ai inversé la valeur fourni dans l'énoncé en ajoutant le padding afin d'obtenir la valeur attendue
		    data_valid_s = 1;
		    #20;
		    data_valid_s = 0;
		    do begin
		      #20;
		    end while (end_associate_s != 1'b1);
		    $display("fin de la phase de traitement des données associées");

		    data_s = 128'h7475657620657551704F206572696420;  //P1: j'ai inversé la valeur fourni dans l'énoncé afin d'obtenir la valeur attendue
		    data_valid_s = 1;
		    #20;
		    data_valid_s = 0;
		    do begin
		      #20;
		    end while (end_cipher1_s != 1'b1);
		    $display("fin de la phase de traitement du premier bloc de données");
		    

		    data_s = 128'h74614E2061747265766E492065617275; //P2: j'ai inversé la valeur fourni dans l'énoncé afin d'obtenir la valeur attendue
		    data_valid_s = 1;
		    #20;
		    data_valid_s = 0;
		    do begin
		      #20;
		    end while (end_cipher2_s != 1'b1);
		    $display("fin de la phase de traitement du deuxieme bloc de données");
		    
		    data_s = 128'h4D20746E75696E65013F206172656E75; //P3: j'ai inversé la valeur fourni dans l'énoncé en ajoutant le padding afin d'obtenir la valeur attendue
		    data_valid_s = 1;
		    #20;
		    data_valid_s = 0;
		    do begin
		      #20;
		    end while (end_s != 1'b1);
		    $display("fin du chiffrement");
		    

		    #40;
		    $stop();

	  end

endmodule : ascon_top_tb

