module alu(input	    clk,
	   input	    reset,
	   input [7:0]	    a,
	   input [7:0]	    b,
	   input [3:0]	    selector,
	   output reg [7:0] out,
	   output reg	    c);
   

   wire [7:0] add;
   wire	      add_c;
   
   wire [7:0] subtract;
   wire	      subtract_c;
   
   wire [7:0] shift_r;
   wire	      shift_r_c;
   
   wire [7:0] shift_l;
   wire	      shift_l_c;
   
   wire [7:0] andg;
   wire	      andg_c;
   
   wire [7:0] org;
   wire	      org_c;

   wire [7:0] notg;
   wire	      notg_c;


   wire       eq_out;
   wire       lt_out;


   reg [7:0] out_combo;
   reg	     out_combo_c;


   eight_bit_adder top_adder(.a(a),
                             .b(b),
                             .c_in(0),
                             .out(add),
                             .c_out(add_c));

   eight_bit_subtractor top_subtractor(.a(a),
                                       .b(b),
                                       .out(subtract),
                                       .sign(subtract_c));

   shifter top_right_shift(.a(a),
                           .dir(1),
                           .out(shift_r),
                           .c(shift_r_c));
   
   shifter top_left_shift(.a(a),
                          .dir(0),
                          .out(shift_l),
                          .c(shift_l_c));


   assign andg   = a & b;
   assign andg_c = 1'b0;

   assign org    = a | b;
   assign org_c  = 1'b0;
   
   assign notg   = ~a;
   assign notg_c = 1'b0;


   equal_to   comp_eq (.a(a), .b(b), .out(eq_out));
   less_than  comp_lt (.a(a), .b(b), .out(lt_out));


   always @(*) begin
        case (selector)
            4'h0: begin
               out_combo   = add;
               out_combo_c = add_c;
            end
            4'h1: begin
               out_combo   = subtract;
               out_combo_c = subtract_c;
            end
            4'h2: begin
               out_combo   = shift_r;
               out_combo_c = shift_r_c;
            end
            4'h3: begin
               out_combo   = shift_l;
               out_combo_c = shift_l_c;
            end
            4'h4: begin
               out_combo   = andg;
               out_combo_c = andg_c;
            end
            4'h5: begin
               out_combo   = org;
               out_combo_c = org_c;
            end
            4'h6: begin
               out_combo   = notg;
               out_combo_c = notg_c;
            end
            4'h7: begin
               out_combo   = 8'h00;
               out_combo_c = eq_out;
            end
            4'h8: begin
               out_combo   = 8'h00;
               out_combo_c = lt_out;
            end
            default: begin
               out_combo   = 8'h00;
               out_combo_c = 1'b0;
            end
        endcase
   end


   always @(posedge clk) begin
        if (reset) begin
            out <= 8'h00;
            c   <= 1'b0;
        end else begin
            out <= out_combo;
            c   <= out_combo_c;
        end
    end

endmodule
