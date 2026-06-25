module shifter(input [7:0]  a,
	       input	    dir,
	       output [7:0] out,
	       output	    c);
   

   wire [7:0] right_shifted;
   wire [7:0] left_shifted;


   assign right_shifted = a >> 1;
   assign left_shifted = a << 1;


   assign out = dir ? right_shifted : left_shifted;
   assign c = dir ? a[0] : a[7];
   
endmodule // shifter

