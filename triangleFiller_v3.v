`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.10.2023 14:38:30
// Design Name: 
// Module Name: shapeFiller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module triangleFiller_v3 #(
	parameter integer VERTEX_DATA_WIDTH = 32,
	parameter integer PIXEL_ADDR_WIDTH = 16
    )
    (
    input wire clk,
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_RSTIF, POLARITY ACTIVE_LOW" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 S_RSTIF RST" *)
    input wire resetn,
    input wire start,
    input wire [VERTEX_DATA_WIDTH-1:0] v0,
    input wire [VERTEX_DATA_WIDTH-1:0] v1,
    input wire [VERTEX_DATA_WIDTH-1:0] v2,
    input wire [VERTEX_DATA_WIDTH-1:0] v3,
    output wire [PIXEL_ADDR_WIDTH-1:0] x,
    output wire [PIXEL_ADDR_WIDTH-1:0] y,
    input wire ready,
    output wire valid,
    output wire done
    );
    
    // This IP creates a filled rectangle using the vertices v0 and v1.
    // Vertex v0 is the upper-left corner coordinates, vertex v1 is the lower-right corner coordinates
    // Both coordinates of vertex v1 must be less than to the coordinates of vertex v2
    // Otherwise, nothing will be drawn
    
    wire [PIXEL_ADDR_WIDTH-1:0] xa, ya, xb, yb, xc, yc;
    wire valid_inputs;
    
    // initiation
    assign {xa, ya} = v0;
    assign {xb, yb} = v1;
    assign {xc, yc} = v2;
    assign valid_inputs = (w0>=0 && w1>=0 && w2>=0) ? 1 : 0;
    
    // registers
    reg [2:0] cstate_reg, nstate_reg;
    reg [PIXEL_ADDR_WIDTH-1:0] x_reg, y_reg;
    reg valid_reg1, valid_reg2, valid_reg3, done_reg;
    // new registers and wires
    reg [PIXEL_ADDR_WIDTH-1:0] x_min, y_min;
    reg [PIXEL_ADDR_WIDTH-1:0] x_max, y_max;
    reg signed [PIXEL_ADDR_WIDTH-1:0] d_w0_row, d_w0_col;
    reg signed [PIXEL_ADDR_WIDTH-1:0] d_w1_row, d_w1_col;
    reg signed [PIXEL_ADDR_WIDTH-1:0] d_w2_row, d_w2_col;
    reg signed [VERTEX_DATA_WIDTH-1:0] w0_row_i, w1_row_i, w2_row_i;
    reg signed [VERTEX_DATA_WIDTH-1:0] w0, w1, w2;
    wire signed [VERTEX_DATA_WIDTH-1:0] w0_inst_reg, w1_inst_reg, w2_inst_reg; 
    
    edge_cross w0_ec_inst(
        .vax(xb),.vay(yb),.vbx(xc),.vby(yc),.px(x_min),.py(y_min),
        .output_val(w0_inst_reg)
    );
    edge_cross w1_ec_inst(
        .vax(xc),.vay(yc),.vbx(xa),.vby(ya),.px(x_min),.py(y_min),
        .output_val(w1_inst_reg)
    );
    edge_cross w2_ec_inst(
        .vax(xa),.vay(ya),.vbx(xb),.vby(yb),.px(x_min),.py(y_min),
        .output_val(w2_inst_reg)
    );
    
    localparam STATE_IDLE = 0,
               STATE_START = 1,
	           STATE_DRAWING = 2,
	           STATE_DONE = 3;
            
    // current state sequential logic
    always @(posedge clk or negedge resetn) begin
	   if (resetn == 1'b0) begin
	       cstate_reg <= STATE_IDLE;
	   end else begin
	       cstate_reg <= nstate_reg;
	   end
	end
	
	// next state combinational logic
	always @* begin
	   nstate_reg = cstate_reg;
	   if (cstate_reg == STATE_IDLE) begin
	       if (start == 1'b1) begin
	           if (valid_inputs) begin
	               nstate_reg = STATE_START;
               end else begin
                   nstate_reg = STATE_DONE;
               end
	       end
	   end else if (cstate_reg == STATE_START) begin
           nstate_reg = STATE_DRAWING;
	   end else if (cstate_reg == STATE_DRAWING) begin
	       if (ready) begin
	           if (x_reg == x_max && y_reg == y_max) begin
	               nstate_reg = STATE_DONE;
	           end
	       end
	   end else if (cstate_reg == STATE_DONE) begin
	       if (start == 1'b1) begin
	           nstate_reg = STATE_IDLE;
	       end
	   end else begin
	       nstate_reg = STATE_IDLE;
	   end
	end
	
	// output logic
	always @(posedge clk or negedge resetn) begin
	   if (resetn == 1'b0) begin
	        x_min <= 16'b0;
            y_min <= 16'b0;
            x_reg <= 16'b0;
            y_reg <= 16'b0;
            x_max <= 16'b0;
            y_max <= 16'b0;
            d_w0_row <= 16'b0;
            d_w0_col <= 16'b0;
            d_w1_row <= 16'b0;
            d_w1_col <= 16'b0;
            d_w2_row <= 16'b0;
            d_w2_col <= 16'b0;
            valid_reg1 <= 0;
            valid_reg2 <= 0;
            valid_reg3 <= 0;
            w0 <= 16'b0;
            w1 <= 16'b0;
            w2 <= 16'b0;
            w0_row_i <= 16'b0;
            w1_row_i <= 16'b0;
            w2_row_i <= 16'b0;
	        done_reg <= 1'b0;
	   end else begin
	       if (valid) begin
	           $display ("x:%d y:%d", x_reg, y_reg);
	       end
	       if (cstate_reg == STATE_IDLE) begin
	            x_min <= (((xa <= xb) ? xa : xb) <= xc) ? ((xa <= xb) ? xa : xb) : xc;
                y_min <= (((ya <= yb) ? ya : yb) <= yc) ? ((ya <= yb) ? ya : yb) : yc;
                x_reg <= (((xa <= xb) ? xa : xb) <= xc) ? ((xa <= xb) ? xa : xb) : xc;
                y_reg <= (((ya <= yb) ? ya : yb) <= yc) ? ((ya <= yb) ? ya : yb) : yc;
                x_max <= (((xa >= xb) ? xa : xb) >= xc) ? ((xa >= xb) ? xa : xb) : xc;
                y_max <= (((ya >= yb) ? ya : yb) >= yc) ? ((ya >= yb) ? ya : yb) : yc;
	            d_w0_row <= 16'b0;
                d_w0_col <= 16'b0;
                d_w1_row <= 16'b0;
                d_w1_col <= 16'b0;
                d_w2_row <= 16'b0;
                d_w2_col <= 16'b0;
                valid_reg1 <= 0;
                valid_reg2 <= 0;
                valid_reg3 <= 0;
                w0 <= 16'b0;
                w1 <= 16'b0;
                w2 <= 16'b0;
                w0_row_i <= 16'b0;
                w1_row_i <= 16'b0;
                w2_row_i <= 16'b0;
           end else if (cstate_reg == STATE_START) begin
                d_w0_row <= xc - xb;
                d_w0_col <= yb - yc;
                d_w1_row <= xa - xc;
                d_w1_col <= yc - ya;
                d_w2_row <= xb - xa;
                d_w2_col <= ya - yb;
                w0 <= w0_inst_reg + (yb - yc);
                w1 <= w1_inst_reg + (yc - ya);
                w2 <= w2_inst_reg + (ya - yb);
                valid_reg1 <= (w0_inst_reg + (yb - yc)>=0 && w1_inst_reg + (yc - ya)>=0 && w2_inst_reg + (ya - yb)>=0
                                                                                    && xa == x_min && ya == y_min);
                valid_reg2 <= 0;
                valid_reg3 <= 0;                                                                  
                w0_row_i <= w0_inst_reg;
                w1_row_i <= w1_inst_reg;
                w2_row_i <= w2_inst_reg;
           end else if (cstate_reg == STATE_DRAWING) begin
                if (ready) begin
                    if (x_reg == x_max && y_reg == y_max) begin
                        valid_reg1 <= 0;
                        valid_reg2 <= 0;
                        valid_reg3 <= 0;
                        x_reg <= 16'b0;
                        y_reg <= 16'b0;
                        done_reg <= 1'b1;
                        $display ("DONE");
                    end else begin
                        if (x_reg == x_min) begin
                            valid_reg1 <= 0;
                            valid_reg3 <= 0;
                            w0 <= w0_row_i;
                            w1 <= w1_row_i;
                            w2 <= w2_row_i;
                        end if (x_reg < x_max) begin
                            valid_reg1 <= 0;
                            valid_reg3 <= 0;
                            valid_reg2 <= (w0>=0 && w1>=0 && w2>=0);     
                            w0 <= w0 + d_w0_col;
                            w1 <= w1 + d_w1_col;
                            w2 <= w2 + d_w2_col;
                            x_reg <= x_reg + 1;
                        end else begin
                            valid_reg2 <= 0;
                            valid_reg3 <= (w0_row_i + d_w0_row>=0 &&
                                               w1_row_i + d_w1_row>=0 &&
                                                   w2_row_i + d_w2_row>=0);
                            w0 <= w0_row_i + d_w0_row + d_w0_col;
                            w1 <= w1_row_i + d_w1_row + d_w1_col;
                            w2 <= w2_row_i + d_w2_row + d_w2_col;
                            w0_row_i <= w0_row_i + d_w0_row;
                            w1_row_i <= w1_row_i + d_w1_row;
                            w2_row_i <= w2_row_i + d_w2_row;
                            x_reg <= x_min;
                            y_reg <= y_reg + 1;
                        end
                    end
                end
           end else if (cstate_reg == STATE_DONE) begin
                if (start == 1'b1) begin
                    done_reg <= 1'b0;
                end
           end
	   end
	end
    
    assign x = x_reg;
	assign y = y_reg;
	assign valid = valid_reg1 || valid_reg2 || valid_reg3;
	assign done = done_reg;
endmodule