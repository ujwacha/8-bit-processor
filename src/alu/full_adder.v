module full_adder(input	 a,
		   input  b,
		   input  c_in,
		   output d,
		   output c_out);

   wire s1;
   wire	c1;
   wire	c2;
   
   
   half_adder first(.a(a),
		    .b(b),
		    .o(s1),
		    .c(c1)
		    );
   
   half_adder second(.a(c_in),
		     .b(s1),
		     .o(d),
		     .c(c2)
		     );

   
   assign c_out = c1 | c2;
endmodule // full_adder
