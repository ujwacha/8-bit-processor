module control_unit(input wire	      clk,
		    input wire	      rst,
		    input wire [7:0]  mem_data_in,
		    input wire [7:0]  r0_stat,
		    input wire	      flag_stat,
		    output reg [7:0]  mem_data_out,
		    output reg [15:0] adress_line,
		    output reg	      mem_sel,
		    output reg	      mem_read,
		    output reg [2:0]  r1,
		    output reg [2:0]  r2,
		    output reg [2:0]  r3,
		    output reg [3:0]  alu_out,
		    output reg	      f_ch,
		    output reg	      r_ch,
		    output reg	      rb_sel,
		    output reg	      imme_sel,
		    output reg [7:0]  imme_out
		    );
   
   
   


   // first implement instruction fetch

   reg [3:0] state;
   reg [3:0] if_state;
   reg [3:0] load_state;


   reg [15:0] pc;
   wire [15:0] pc1;
   wire [15:0] pc2;
   wire [15:0] pc3;
   wire [15:0] pc4;
   

   reg [3:0]   alu_state;
   

   reg [2:0]   r1_s;
   reg [2:0]   r2_s;
   reg [2:0]   r3_s;
   reg [3:0]   alu_out_s;
   // reg	       f_ch_s;
   // reg	       r_ch_s;
   reg	       imme;
   reg	       jmp;
   reg	       sto;
   reg [7:0]   imme_high;
   reg [7:0]   imme_low;
   
   
   assign pc1 = pc + 1;
   assign pc2 = pc + 2;
   assign pc3 = pc + 3;
   assign pc4 = pc + 4;



   
   

   always @(posedge clk) begin


      if (rst) begin
	 state        <= 4'h0;
	 if_state     <= 4'h0;
	 load_state   <= 4'h0;
	 alu_state    <= 4'h0;
	 pc           <= 16'h0000;

	 r1_s         <= 3'b000;
	 r2_s         <= 3'b000;
	 r3_s         <= 3'b000;
	 alu_out_s    <= 4'h0;
	 // f_ch_s       <= 1'b0;
	 // r_ch_s       <= 1'b0;
	 imme         <= 1'b0;
	 jmp          <= 1'b0;
	 sto          <= 1'b0;
	 imme_high    <= 8'h00;
	 imme_low     <= 8'h00;

	 // Outputs
	 r1           <= 3'b000;
	 r2           <= 3'b000;
	 r3           <= 3'b000;
	 alu_out      <= 4'h0;
	 f_ch         <= 1'b0;
	 r_ch         <= 1'b0;
	 rb_sel       <= 1'b0;
	 imme_sel     <= 1'b0;
	 imme_out     <= 8'h00;
	 mem_sel      <= 1'b0;
	 mem_read     <= 1'b0;        // disabled by default after reset
	 mem_data_out <= 8'h00;
	 adress_line  <= 16'h0000;
      end else begin

	 r1         <= r1_s;          // keep latched values from fetch
	 r2         <= r2_s;
	 r3         <= r3_s;
	 alu_out    <= alu_out_s;

	 r_ch       <= 1'b0;
	 f_ch       <= 1'b0;
	 rb_sel     <= 1'b0;

	 imme_sel   <= imme;
	 imme_out   <= imme_high;

	 mem_sel    <= 1'b0;
	 mem_read   <= 1'b1;
	 mem_data_out <= 8'h00;
	 adress_line <= 16'h0000;
	 
	 case (state)
	   default: begin
	      state <= 4'h0;
	   end
	   
	   4'h0: begin
	      case (if_state) 
		4'h0: begin
		   adress_line <= pc;
		   mem_sel <= 1;
		   mem_read <= 1;
		   if_state <= 4'h1;
		end
		

		4'h1: begin
		   adress_line <= pc1;
		   mem_sel <= 1;
		   mem_read <= 1;

		   alu_out_s <= mem_data_in[7:4];
		   imme <= mem_data_in[3];
		   r1_s <= mem_data_in[2:0];
		   if_state <= 4'h2;
		   
		end // case: 4'h01

		4'h2: begin


		   jmp <= mem_data_in[7];
		   r2_s <= mem_data_in[6:4];
		   sto <= mem_data_in[3];
		   r1_s <= mem_data_in[2:0];

		   if (imme) begin
		      adress_line <= pc2;
		      mem_sel <= 1;
		      mem_read <= 1;
		      if_state <= 4'h3;
		   end else begin
		      mem_sel <= 0;
		      if_state <= 4'h5;
		   end
		   
		end // case: 4'h2
		
		
		4'h3: begin
		   adress_line <= pc3;
		   mem_sel <= 1;
		   mem_read <= 1;


		   imme_high <= mem_data_in;
		   
		   if_state <= 4'h4;
		end // case: 4'h3
		
		4'h4: begin
		   imme_low <= mem_data_in;
		   mem_sel <= 0; // stop selecting memory now
		   if_state <= 4'h5;
		end // case: 4'h4

		4'h5: begin
		   // instruction fetched now goto decode
		   pc <= pc4;
		   if_state <= 4'h0;
		   state <= 4'h1;
		end
		
		default: if_state <= 4'h0;
	      endcase; // case (if_state)
	   end // case: 4'h0
	   
	   4'h1: begin
	      // now I decode here, look at h5 state of if_state
	      // things will be latched after decoding

	      // immediately latch in the immediate operand so that 1 mux can select 1 register or immediate to ALU


	      // Defaults
	      // Register selects – keep the values latched from fetch
	      r1         <= r1_s;
	      r2         <= r2_s;
	      r3         <= r3_s;
	      alu_out    <= alu_out_s;

	      // Writeback control – default disabled
	      r_ch       <= 1'b0;
	      f_ch       <= 1'b0;
	      rb_sel     <= 1'b0;      // 0 = no register write


	      imme_sel   <= imme;      // pass through the immediate flag
	      imme_out   <= imme_high; // send the high byte of immediate (or zero)

	      // Memory control – default disabled
	      mem_sel    <= 1'b0;
	      mem_read   <= 1'b0;
	      mem_data_out <= 8'h00;
	      adress_line <= 16'h0000;

	      if (jmp) begin

		 // there are ALU instructions to set the flag stat
		 // the programmer will run that instruction, set the flag
		 // and jump
		 // there are 'less than' and 'equal to' and 'always set flag' instructions in alu
		 if (flag_stat) begin
		    pc <= {imme_high, imme_low};
		    state <= 4'h0;
		 end else begin
		    pc <= pc;
		    state <= 4'h0;
		 end
	      end else begin
		 // check if sto is set
		 // sto is high -> either load or store
		 // ALU not needed, so the 4 bits will be used to
		 // select load or store
		 if (sto) begin
		    // this is going to be complex, so gonna write later
		    // immediate must always be high here
		    // or not, just let assembler do it's job.
		    // doesn't matter anyway
		    
		    case (alu_out_s)
		      4'h0: begin
			 state <= 4'h2; // store
		      end

		      default: begin
			 state <= 4'h3; // load
		      end
		      
		    endcase; // case (alu_out_s)
		    
		    
		 end else begin


		    case (alu_state)
		      default: begin
			 alu_state <= 4'h0;
		      end
		      4'h0: begin
			 //start by sending from the register bank to alu
			 rb_sel <= 1;
			 r1 <= r1_s;
			 r2 <= r2_s;
			 r3 <= r3_s;
			 alu_out <= alu_out_s;
			 f_ch <= 0;
			 r_ch <= 0;
			 alu_state <= 4'h1;
		      end // case: begin...

		      4'h1: begin
			 // wait for a clock cycle for alu to settle down
			 alu_state <= 4'h2;
		      end

		      4'h2: begin
			 rb_sel <= 1;
			 f_ch <= 1;
			 r_ch <= 1;
			 alu_state <= 4'h3;
		      end

		      4'h3: begin
			 rb_sel     <= 1'b0;
			 alu_state <= 4'h0;
			 // jump back to instruction fetch
			 state <= 4'h0;
		      end
		    endcase; // case (alu_state)
		 end
	      end
	   end // case: 4'h1
	   
           4'h2: begin
	      // write back to RAM, one clock cycle stuff
	      mem_data_out <= r0_stat;
	      rb_sel <= 0;
	      mem_sel <= 1;
	      mem_read <= 0;
	      adress_line <= {imme_high, imme_low};
	      
	      state <= 4'h0;
	      
	   end // case: 4'h2

	   4'h3: begin
	      case (load_state)
		4'h0: begin
		   // Start memory read
		   adress_line   <= {imme_high, imme_low}; // address from immediate
		   mem_sel       <= 1'b1;
		   mem_read      <= 1'b1;
		   mem_data_out  <= 8'h00;
		   r_ch          <= 1'b0;
		   f_ch          <= 1'b0;
		   rb_sel        <= 1'b0;
		   load_state    <= 4'h1;
		end
		4'h1: begin
		   // Loaded data is now on mem_data_in.
		   // Store it as immediate, then reuse ALU passthrough to write to register.
		   imme_high     <= mem_data_in;   // loaded data becomes immediate
		   imme_low      <= 8'h00;         // not used (8‑bit loads)
		   imme          <= 1'b1;          // select immediate as ALU operand A
		   sto           <= 1'b0;          // clear store flag so we go to ALU path
		   alu_out_s     <= 4'h9;          // passthrough A (ALU out = A)
		   alu_state     <= 4'h0;          // start ALU pipeline from beginning
		   state         <= 4'h1;          // jump back to DECODE
		   load_state    <= 4'h0;          // reset for next load
		end
		default: load_state <= 4'h0;
	      endcase
	   end	  
	   
	 endcase; // case (state)
      end // else: !if(rst)
   end // always @ (posedge clk)
   
endmodule // control_unit

