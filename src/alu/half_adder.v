module half_adder(input a, b, output o, c);
   assign o = a^b;
   assign c = a&b;
endmodule // half_adder
