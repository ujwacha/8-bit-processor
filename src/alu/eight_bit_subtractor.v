module eight_bit_subtractor(input [7:0]	 a,
			    input [7:0]	 b,
			    output [7:0] out,
			    output	 sign);

   wire [7:0] negated_b;
   wire	      one;
   
   assign  one = 1;
   assign negated_b = ~b;
   
   eight_bit_adder subtractor_adder_component(.a(a),
					      .b(negated_b),
					      .c_in(one),
					      .out(out),
					      .c_out(sign));
   
   
endmodule // eight_bit_subtractor

