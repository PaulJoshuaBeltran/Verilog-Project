`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.10.2023 22:18:46
// Design Name: 
// Module Name: triangleFiller_tb
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

module triangleFiller_tb #(
	parameter integer VERTEX_DATA_WIDTH = 32,
	parameter integer PIXEL_ADDR_WIDTH = 16
    )();
    reg clk;
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_RSTIF, POLARITY ACTIVE_LOW" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 S_RSTIF RST" *)
    reg resetn;
    reg start;
    reg [VERTEX_DATA_WIDTH-1:0] v0;
    reg [VERTEX_DATA_WIDTH-1:0] v1;
    reg [VERTEX_DATA_WIDTH-1:0] v2;
    reg [VERTEX_DATA_WIDTH-1:0] v3;
    reg ready;
    
    wire [PIXEL_ADDR_WIDTH-1:0] x;
    wire [PIXEL_ADDR_WIDTH-1:0] y;
    wire valid;
    wire done;
    
    integer file_handle;
    
    /*
    triangleFiller triangleFiller_inst(
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .v0(v0),
        .v1(v1),
        .v2(v2),
        .v3(v3),
        .ready(ready),
        .x(x),
        .y(y),
        .valid(valid),
        .done(done)
    );
    */
    
    triangleFiller_v3 triangleFiller_inst(
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .v0(v0),
        .v1(v1),
        .v2(v2),
        .v3(v3),
        .ready(ready),
        .x(x),
        .y(y),
        .valid(valid),
        .done(done)
    );
    
    initial begin
        file_handle = $fopen("../verilog_test.txt", "w");  // Open the file for writing
        clk = 0; resetn = 0; start = 0;
        #10 resetn = 1;
        #50 start = 1;
        
        // REQUIRED TEST
        /* TEST 0: fillTriangle(360,8,1008,472,128,328)*/
        v0 = {16'h0168, 16'h0008};
        v1 = {16'h03F0, 16'h01D8};
        v2 = {16'h0080, 16'h0148};
        v3 = {16'h0000, 16'h0000};
        
        // UP-ED Triangle
        /* TEST 1: fillTriangle(0,1,5,6,1,5)
        v0 = {16'h0, 16'h1};
        v1 = {16'h5, 16'h6};
        v2 = {16'h1, 16'h5};
        v3 = {16'h0, 16'h0};
        */
        /* TEST 2: fillTriangle(1,1,5,5,1,5)
        v0 = {16'h1, 16'h1};
        v1 = {16'h5, 16'h5};
        v2 = {16'h1, 16'h5};
        v3 = {16'h0, 16'h0};
        */
        /* TEST 3: fillTriangle(3,1,5,5,1,5)
        v0 = {16'h3, 16'h1};
        v1 = {16'h5, 16'h5};
        v2 = {16'h1, 16'h5};
        v3 = {16'h0, 16'h0};
        */
        /* TEST 4: fillTriangle(5,1,5,5,1,5)
        v0 = {16'h5, 16'h1};
        v1 = {16'h5, 16'h5};
        v2 = {16'h1, 16'h5};
        v3 = {16'h0, 16'h0};
        */
        /* TEST 5: fillTriangle(6,1,5,5,1,6)
        v0 = {16'h6, 16'h1};
        v1 = {16'h5, 16'h5};
        v2 = {16'h1, 16'h6};
        v3 = {16'h0, 16'h0};
        */
        
        // DOWN-ED Triangle
        /* TEST 6: fillTriangle(1,1,5,0,0,5)
        v0 = {16'h1, 16'h1};
        v1 = {16'h5, 16'h0};
        v2 = {16'h0, 16'h5};
        v3 = {16'h0, 16'h0};
        */
        /* TEST 7: fillTriangle(1,1,5,1,1,5)
        v0 = {16'h1, 16'h1};
        v1 = {16'h5, 16'h1};
        v2 = {16'h1, 16'h5};
        v3 = {16'h0, 16'h0};
        */
        /* TEST 8: fillTriangle(1,1,5,1,3,5)
        v0 = {16'h1, 16'h1};
        v1 = {16'h5, 16'h1};
        v2 = {16'h3, 16'h5};
        v3 = {16'h0, 16'h0};
        */
        /* TEST 9: fillTriangle(1,1,5,1,5,5)
        v0 = {16'h1, 16'h1};
        v1 = {16'h5, 16'h1};
        v2 = {16'h5, 16'h5};
        v3 = {16'h0, 16'h0};
        */
        /* TEST 10: fillTriangle(1,0,5,1,6,5)
        v0 = {16'h1, 16'h0};
        v1 = {16'h5, 16'h1};
        v2 = {16'h6, 16'h5};
        v3 = {16'h0, 16'h0};
        */
        
        $fwrite(file_handle, "fillTriangle(%04h, %04h, %04h)\n", v0, v1, v2);
        $fclose(file_handle);
        ready = 1;
    end
    
    always @* begin
        #5 clk <= ~clk;
    end
    
    always @(posedge clk) begin
        // WRITES TXT FILE IN: C:\SoC\lab3_video_pipeline\lab3_video_pipeline.sim\sim_1\behav
        if (ready && !done && valid) begin
            file_handle = $fopen("../verilog_test.txt", "a");  // Open the file for writing
            $fwrite(file_handle, "x:%d, y:%d\n", x, y);
            $fclose(file_handle);
        end if (ready && done) begin
            file_handle = $fopen("../verilog_test.txt", "a");  // Open the file for writing
            $fwrite(file_handle, "DONE\n");
            $fclose(file_handle);
        end
    end
endmodule