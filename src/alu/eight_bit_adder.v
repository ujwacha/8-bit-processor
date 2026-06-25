module eight_bit_adder(input [7:0]  a,
		       input [7:0]  b,
		       input	    c_in,
		       output [7:0] out,
		       output	    c_out);
   wire c0;

   four_bit_adder adder_0(.a(a[3:0]),
			  .b(b[3:0]),
			  .c_in(c_in),
			  .out(out[3:0]),
			  .c_out(c0));


   four_bit_adder adder_1(.a(a[7:4]),
			  .b(b[7:4]),
			  .c_in(c0),
			  .out(out[7:4]),
			  .c_out(c_out));
      
   
endmodule // eight_bit_adder
