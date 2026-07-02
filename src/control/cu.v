`define fetch 2'b00
`define decode 2'b01
  

module cu(
	  input wire	    clk,
	  input wire	    rst,
	  input wire [7:0]  data_line,
	  output reg [15:0] addr_line,
	  output reg [3:0]  alu_op,
	  output reg	    mem_read,
	  output reg	    mem_write,
	  output reg	    reg_write,
	  output reg [2:0]  read_reg_1,
	  output reg [2:0]  read_reg_2,
	  output reg [2:0]  write_reg
	  );
   

   reg [1:0] state;
   reg [2:0] fetch_state;
   reg [15:0] pc;
   
   reg	      imme_flag;



   reg [3:0]  alu_op_s;   
   reg	      reg_write_s;   
   reg [2:0]  read_reg_1_s;   
   reg [2:0]  read_reg_2_s;
   reg [2:0]  write_re_s;
   
   



   
   always @(posedge clk or posedge rst) begin
      if (rst) begin
         state       <= `fetch;
         fetch_state <= 3'b000;
         pc          <= 16'h0000;
         // Clear all outputs
         addr_line   <= 16'h0000;
         alu_op      <= 4'b0000;
         mem_read    <= 1'b0;
         mem_write   <= 1'b0;
         reg_write   <= 1'b0;
         read_reg_1  <= 3'b000;
         read_reg_2  <= 3'b000;
         write_reg   <= 3'b000;
         imme_flag   <= 1'b0;
      end else begin
         case (state)
           `fetch : begin
              case (fetch_state)
                3'b000: begin
                   addr_line <= pc;
                   mem_read <= 1'b1;
                   pc <= pc + 1;
                   fetch_state <= 3'b001;
                end

                3'b001 : begin
                   alu_op_s  <= data_line[7:4];
                   imme_flag <= data_line[3];
                   write_reg_s <= data_line[2:0];
                   addr_line <= pc;
                   mem_read  <= 1'b1;
                   pc <= pc + 1;
                   fetch_state <= 3'b010;
                end

                3'b010 : begin 
                   read_reg_1_s <= data_line[6:4];
                   read_reg_2_s <= data_line[2:0];
		   
                   if (imme_flag) begin
                      addr_line <= pc;
                      mem_read <= 1'b1;
                      fetch_state <= 3'b011;
                   end else begin
                      fetch_state <= 3'b000;
                   end
                   pc <= pc + 1;
                end

                3'b011 : begin
                   addr_line <= pc;
                   mem_read <= 1'b1;
                   pc <= pc + 1;
                   fetch_state <= 3'b100;
                end

                3'b100 : begin
                   pc <= pc + 1;
                   fetch_state <= 3'b000;
                end

                default : fetch_state <= 3'b000;
              endcase
           end
           default : state <= `fetch;
         endcase
      end
   end
endmodule
