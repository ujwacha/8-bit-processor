module four_bit_adder(input [3:0]  a,
		      input [3:0]  b,
		      input	   c_in,
		      output [3:0] out,
		      output	   c_out);
   

   wire c0, c1, c2;
   
   
   full_adder adder_0(.a(a[0]),
		      .b(b[0]),
		      .c_in(c_in),
		      .d(out[0]),
		      .c_out(c0)
		      );
   

   
   full_adder adder_1(.a(a[1]),
		      .b(b[1]),
		      .c_in(c0),
		      .d(out[1]),
		      .c_out(c1)
		      );
   
   
   full_adder adder_2(.a(a[2]),
		      .b(b[2]),
		      .c_in(c1),
		      .d(out[2]),
		      .c_out(c2)
		      );
   
   
   full_adder adder_3(.a(a[3]),
		      .b(b[3]),
		      .c_in(c2),
		      .d(out[3]),
		      .c_out(c_out)
		      );
   
endmodule // four_bit_adder


