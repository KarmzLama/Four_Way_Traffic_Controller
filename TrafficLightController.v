`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/07/2025 10:46:14 AM
// Design Name: 
// Module Name: TrafficLightController
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


module TrafficLightController(
    input clk, // 1 sec clock
    input reset, // Active high reset
    input ped_ns, // crosswalk button for ns, active high
    input ped_ew, // crosswalk button for ew, active high
    output reg [1:0] ns_light, // north south light
    output reg [1:0] ew_light, // east west light
    output reg ns_walk, // north south crosswalk signal (WALK = 1, DON'T WALK = 0)
    output reg ew_walk // east west crosswalk signal (W = 1, DW = 0)
    );
    
    // State Encoding
    localparam NS_GREEN = 3'b000;      // ns green, ew red
    localparam NS_YELLOW = 3'b001;     // ns yellow, ew red
    localparam EW_GREEN = 3'b010;      // ns red, ew green
    localparam EW_YELLOW = 3'b011;     // ns red, ew yellow
    localparam ALL_RED_PED = 3'b100;   // All traffic red, all pedestrians walk
    
    // Light Color Definition
    localparam RED = 2'b00;
    localparam YELLOW = 2'b01;
    localparam GREEN = 2'b10;
    
    // Timing parameters (in seconds)
    localparam NS_GREEN_TIME = 128;      // ns green light duration
    localparam EW_GREEN_TIME = 128;      // ew green light duration
    localparam YELLOW_TIME = 8;          // yellow light duration
    localparam PED_WALK_TIME = 30;       // pedestrian walk duration
    localparam PED_REQUEST_DELAY = 16;   // delay after pedestrian request before transitioning
    
    // Current state and next state
    reg [2:0] current_state, next_state;
    
    // Timers for state transitions
    reg [7:0] main_timer;    // main timer for normal state transitions
    reg [7:0] ped_timer;     // timer for pedestrian request delay
    
    // Pedestrian request flags
    reg ped_request;
    reg ped_delay_active;
    
    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= NS_GREEN;
            main_timer <= NS_GREEN_TIME;
            ped_timer <= 0;
            ped_request <= 0;
            ped_delay_active <= 0;
        end else begin
            current_state <= next_state;
            
            // Handle pedestrian button inputs
            if ((ped_ns || ped_ew) && !ped_request && !ped_delay_active) begin
                ped_request <= 1;
                ped_delay_active <= 1;
                ped_timer <= PED_REQUEST_DELAY;
            end
            
            // update pedestrian delay timer
            if (ped_delay_active && ped_timer > 0) begin
                ped_timer <= ped_timer - 1;
                if (ped_timer == 1) begin // will be 0 next cycle
                    ped_delay_active <= 0; // delay completed
                end
            end
            
            // reset pedestrian request
            if (current_state == ALL_RED_PED && next_state != ALL_RED_PED) begin
                ped_request <= 0;
            end
            
            // Update main timer
            if (main_timer > 0) begin
                main_timer <= main_timer - 1;
            end
            
            // Set main timer for next state
            if (current_state != next_state) begin  // state transition is happening
                case (next_state)
                    NS_GREEN: main_timer <= NS_GREEN_TIME;
                    NS_YELLOW: main_timer <= YELLOW_TIME;
                    EW_GREEN: main_timer <= EW_GREEN_TIME;
                    EW_YELLOW: main_timer <= YELLOW_TIME;
                    ALL_RED_PED: main_timer <= PED_WALK_TIME;
                endcase
            end
        end
    end
    
    // Next state logic
    always @(*) begin
        next_state = current_state; 
        
        case (current_state)
            NS_GREEN: begin
                if (main_timer == 0 || (ped_request && !ped_delay_active)) begin
                    next_state = NS_YELLOW;
                end
            end
            
            NS_YELLOW: begin
                if (main_timer == 0) begin
                    if (ped_request) begin
                        next_state = ALL_RED_PED;
                    end else begin
                        next_state = EW_GREEN;
                    end
                end
            end
            
            EW_GREEN: begin
                if (main_timer == 0 || (ped_request && !ped_delay_active)) begin
                    next_state = EW_YELLOW;
                end
            end
            
            EW_YELLOW: begin
                if (main_timer == 0) begin
                    if (ped_request) begin
                        next_state = ALL_RED_PED;
                    end else begin
                        next_state = NS_GREEN;
                    end
                end
            end
            
            ALL_RED_PED: begin
                if (main_timer == 0) begin
                    next_state = NS_GREEN;  // return to normal cycle after pedestrian phase
                end
            end
            
            default: next_state = NS_GREEN; // safety default
        endcase
    end
    
    // Output logic
    always @(*) begin
        // Default values
        ns_light = RED;
        ew_light = RED;
        ns_walk = 0;  // DW
        ew_walk = 0;  // DW
        
        case (current_state)
            NS_GREEN: begin
                ns_light = GREEN;
                ew_light = RED;
            end
            
            NS_YELLOW: begin
                ns_light = YELLOW;
                ew_light = RED;
            end
            
            EW_GREEN: begin
                ns_light = RED;
                ew_light = GREEN;
            end
            
            EW_YELLOW: begin
                ns_light = RED;
                ew_light = YELLOW;
            end
            
            ALL_RED_PED: begin
                ns_light = RED;
                ew_light = RED;
                ns_walk = 1;  // ns pedestrians can walk
                ew_walk = 1;  // ew pedestrians can walk
            end
        endcase
    end
    
endmodule
