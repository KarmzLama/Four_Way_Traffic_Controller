`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/07/2025 11:10:06 AM
// Design Name: 
// Module Name: TestBenchController
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


module TestBenchController();

// Inputs and Outputs
    reg clk;
    reg reset;
    reg ped_ns;
    reg ped_ew;
    wire [1:0] ns_light;
    wire [1:0] ew_light;
    wire ns_walk;
    wire ew_walk;

// Instantiate
    TrafficLightController uut (
        .clk(clk),
        .reset(reset),
        .ped_ns(ped_ns),
        .ped_ew(ped_ew),
        .ns_light(ns_light),
        .ew_light(ew_light),
        .ns_walk(ns_walk),
        .ew_walk(ew_walk)
    );

// Clock generation
    always begin
        #0.5 clk = ~clk; // 1-second clock period
    end

// press a pedestrian button
    task press_button(input reg which); // 0 = ns, 1 = ew
        begin
            if (which == 0) ped_ns = 1;
            else ped_ew = 1;
            #1;
            ped_ns = 0;
            ped_ew = 0;
        end
    endtask

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;
        ped_ns = 0;
        ped_ew = 0;

        // Wait 2 cycles with reset
        #2;
        reset = 0;

        // Let the FSM run for a few seconds
        #10;

        // Press NS pedestrian button
        $display(">> Pressing NS pedestrian button at time %0t", $time);
        press_button(0);

        // Wait for some time
        #200;

        // Press EW pedestrian button
        $display(">> Pressing EW pedestrian button at time %0t", $time);
        press_button(1);

        // Run more to observe transition back
        #200;

        // End simulation
        $display(">> Ending simulation at time %0t", $time);
        $finish;
    end


endmodule
