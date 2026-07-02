module register_bank(input [2:0]      r1,
		     input [2:0]      r2,
		     input [2:0]      r3,
		     input	      f_ch,
		     input	      r_ch,
		     input [7:0]      r_in,
		     input	      flg_in,
		     input	      clk,
		     input	      rst,
		     input	      cs,
		     output reg [7:0] out_a,
		     output reg [7:0] out_b,
		     output [7:0]     r0_stat,
		     output	      flag_stat);

   ////// r1 <- operation(r2, r3)
   
   reg [7:0] registers [7:0];
   reg	     flag;

   initial begin
      registers[0] = 8'h00;
      registers[1] = 8'h01;
      registers[2] = 8'h02;
      registers[3] = 8'h03;
      registers[4] = 8'h04;
      registers[5] = 8'h05;
      registers[6] = 8'h06;
      registers[7] = 8'h07;
      flag = 1'b0;
   end

   	 
   assign r0_stat = registers[0];
   assign flag_stat = flag;
   
   always @(posedge clk) begin
      if (cs) begin
	 if (rst) begin
	    registers[0] <= 8'h00;	
	    registers[1] <= 8'h00;	 
	    registers[2] <= 8'h00;
	    registers[3] <= 8'h00;
	    registers[4] <= 8'h00;
	    registers[5] <= 8'h00;
	    registers[6] <= 8'h00;
	    registers[7] <= 8'h00;
	    flag <= 0;
	 end else begin // if (rst)
	    out_a <= registers[r2];
	    out_b <= registers[r3];

	    if (r_ch) begin
	       registers[r1] <= r_in;
	    end
	    
	    flag <= flag;
	    if (f_ch) begin
	       flag <= flg_in;
	    end
	 end // else: !if(rst)
      end // if (cs)
   end
endmodule // memory
