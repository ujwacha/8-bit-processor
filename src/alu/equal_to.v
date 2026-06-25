module equal_to(input [7:0] a,
		input [7:0] b,
		output	    out);
   
   // find a < b

   wire [7:0] sout;
   wire	      sign_out;
   wire [7:0] nsout;
   
   
   eight_bit_subtractor comparator(.a(b),
				   .b(a),
				   .out(sout),
				   .sign(sign_out));
   
   


   assign nsout = ~sout;
   assign out = nsout[0] & nsout[1] & nsout[2] &
		nsout[3] & nsout[4] & nsout[5] &
		nsout[6] & nsout[7] & sign_out;

   
endmodule // equal_to
