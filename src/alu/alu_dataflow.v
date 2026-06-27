module alu(input	    clk,
	   input	    reset,
	   input [7:0]	    a,
	   input [7:0]	    b,
	   input [3:0]	    selector,
	   output reg [7:0] out,
	   output reg	    c);
   

   wire [7:0] add;
   wire	      add_c;
   
   wire [7:0] subtract;
   wire	      subtract_c;
   
   wire [7:0] shift_r;
   wire	      shift_r_c;
   
   wire [7:0] shift_l;
   wire	      shift_l_c;
   
   wire [7:0] andg;
   wire	      andg_c;
   
   wire [7:0] org;
   wire	      org_c;

   wire [7:0] notg;
   wire	      notg_c;


   wire       eq_out;
   wire       lt_out;


   reg [7:0] out_combo;
   reg	     out_combo_c;


   eight_bit_adder top_adder(.a(a),
                             .b(b),
                             .c_in(0),
                             .out(add),
                             .c_out(add_c));

   eight_bit_subtractor top_subtractor(.a(a),
                                       .b(b),
                                       .out(subtract),
                                       .sign(subtract_c));

   shifter top_right_shift(.a(a),
                           .dir(1),
                           .out(shift_r),
                           .c(shift_r_c));
   
   shifter top_left_shift(.a(a),
                          .dir(0),
                          .out(shift_l),
                          .c(shift_l_c));


   assign andg   = a & b;
   assign andg_c = 1'b0;

   assign org    = a | b;
   assign org_c  = 1'b0;
   
   assign notg   = ~a;
   assign notg_c = 1'b0;


   equal_to   comp_eq (.a(a), .b(b), .out(eq_out));
   less_than  comp_lt (.a(a), .b(b), .out(lt_out));

   
   four_bit_mux selector(.in_bit({
				  add_c,
				  subtract_c,
				  shift_r_c,
				  shift_l_c,
				  andg_c,
				  org_c,
				  notg_c,
				  eq_out,
				  lt_out,
				  8'h00,
				  8'h00,
				  8'h00,
				  8'h00,
				  8'h00,
				  8'h00,
				  8'h00
				  })
			 .in_byte({
				   add,
				   subtract,
				   shift_r,
				   shift_l
				   andg,
				   org,
				   notg,
				   8'h00,
				   8'h00,
				   8'h00,
				   8'h00,
				   8'h00,
				   8'h00,
				   8'h00,
				   8'h00,
				   8'h00
				   })
			 .sel(selector),
			 .out_bit(out_combo_c),
			 .out_byte(out_combo)
			 );
   

   always @(posedge clk) begin
        if (reset) begin
            out <= 8'h00;
            c   <= 1'b0;
        end else begin
            out <= out_combo;
            c   <= out_combo_c;
        end
    end

endmodule // alu

