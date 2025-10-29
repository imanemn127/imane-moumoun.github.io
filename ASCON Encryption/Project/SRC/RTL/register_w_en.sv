//Imane MOUMOUN
// register_w_en: registre pour memoriser cipher et tag

`timescale 1 ns / 1 ps

import ascon_pack::*;

module register_w_en
  
#(
    parameter nb_bits_g = 32
) (
    input  logic  clock_i,
    input  logic  resetb_i,
    input  logic  en_i,
    input  logic [nb_bits_g-1 : 0] data_i,
    output logic [nb_bits_g-1 : 0] data_o
);

  logic [nb_bits_g-1 : 0] data_s;

  always_ff @(posedge clock_i or negedge resetb_i) begin
    if (resetb_i == 1'b0) begin
      data_s <= 0;
    end else begin
      if (en_i == 1'b1) begin
        data_s <= data_i;
      end else data_s <= data_s;
    end
  end

  assign data_o = data_s;

endmodule : register_w_en



