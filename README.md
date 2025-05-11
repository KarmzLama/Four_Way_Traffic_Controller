# Four_Way_Traffic_Controller
This Verilog project simulates a 4-way traffic light controller that inlcudes pedestrian crosswalk buttons. The system uses a finite state machine (FSM) to control the traffic lights at a signalized intersection, giving priority to pedestrians when a request to walk is made.

# Project Summary
This Verilog project models a realistic traffic light controller using a state machine.            It manages:
  - Four directions of vehicle traffic (North, East, South, West)
  - FSM design with parameterized states
  - Pedestrian crosswalk signals
  - Simulated input signals that represent a pedestrian pressing the buttons

The entire project was designed and tested in Vivado 2023.2 using simulation only. It serves as a great learning tool for understanding FSM design, conditional logic, and timing in hardware description languages without the need for physical hardware.

# Features
**Traffic Light (FSM) with 5 states**:
  - NS Green, NS Yellow, EW Green, EW Yellow, All Red Ped

**Pedestrian Button Handling**:
  - ped ns and ped ew inputs trigger a pedestrian walk phase after a 16-second delay

**Timers**:
  - main timer for green/yellow/walk durations
  - ped timer for walk request delay

**Verilog Constructs**:
  - uses 'if-else' and 'case' statements to control signal flow

**Clock Input**: Operates using a 1-second clock pulse for all timing operations
