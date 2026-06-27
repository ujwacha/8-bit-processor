// module four_bit_mux(input [16:0] in_bit,
// 		    input [16:0] in_byte[7:0],
// 		    input [3:0]	 sel,
// 		    output	 out_bit,
// 		    output	 out_byte[7:0]);
   

//    assign out_bit = in_bit[sel];
//    assign out_byte = in_byte[sel];
     
// endmodule; // four_bit_mux
     

module four_bit_mux (
    input  [15:0]      in_bit,      // 16 single-bit inputs (one per selector)
    input  [7:0]       in_byte [15:0], // 16 byte-wide inputs (unpacked array)
    input  [3:0]       sel,
    output             out_bit,
    output [7:0]       out_byte
);
    assign out_bit  = in_bit[sel];
    assign out_byte = in_byte[sel];
endmodule
