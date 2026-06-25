module less_than(input [7:0] a,
		 input [7:0] b,
		 output	     out);
   // find a < b

   // wire [7:0] subtractor_out;

   wire dummy;
   
   
   /*verilator lint_off PINMISSING */
   eight_bit_subtractor comparator(.a(a),
				   .b(b),
				   // .out(subtractor_out),
				   .sign(dummy));
   /*verilator lint_on PINMISSING */

   assign out = ~dummy;
   
endmodule // less_than
