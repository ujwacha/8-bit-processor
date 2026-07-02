module memory(input [15:0]     adr,
	      input [7:0]      data_in,
	      input	       read,
	      input	       clk,
	      input	       rst,
	      input	       cs,
	      output reg [7:0] out);
   
   reg [7:0] memory_reg [65535:0];

   always @(posedge clk) begin
      if (cs) begin
	 if (rst) begin
            out <= 8'h00;
	 end else begin
	    if (read) begin
	       out <= memory_reg[adr];
	    end else begin
	       memory_reg[adr] <= data_in;
	       out <= 8'h00;
	    end
	 end
      end
   end
endmodule // memory
