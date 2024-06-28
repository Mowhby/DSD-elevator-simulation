
module Handler (
    input clk,                    // Clock signal
    input [4:0] WhichFloor,     // Current floor of the elevator
    input [4:0] InToggle,         // Input signal for internal floor buttons
    input [4:0] OutToggle,        // Input signal for external floor buttons
    output reg Dir,               // Direction of the elevator (Up, Down, or Stop)
    output reg Process,            // Elevator process status (Active or Stopped)
    output reg [4:0] PushedButtons
);

    bit [2:0] PushedButtons_queue [$:4]; // Queue to store floor requests
    bit CurrentDestination;       // Flag to check if there's a current destination
    integer i, Destination;       // Loop variable and destination floor

    // Local parameters for elevator states
    localparam Stop = 2'b00,
               Up = 2'b11,
               Down = 2'b01;

    // Initial block to set the default states
    initial begin
        {Dir, Process} = Stop;    // Set the elevator to stop initially
        PushedButtons = 5'b00000;   // No buttons are pushed initially
        CurrentDestination <= 1'b1;
    end

    // Always block triggered on the negative edge of the clock
    // Updates the state of pushed buttons
    always @(posedge clk) begin
        PushedButtons <= PushedButtons | InToggle | OutToggle;
    end

    // Always block to handle the elevator movement and direction based on the request queue
    always @(posedge clk) begin
        if ({Dir, Process} == Up) begin
            if (WhichFloor < 5) begin
                if (PushedButtons[WhichFloor] == 1'b1) begin
                    PushedButtons[WhichFloor] <= 1'b0; // Clear the button press for current floor
                    {Dir, Process} <= Stop; // Stop the elevator
                end
                if (Destination == WhichFloor) begin
                    {Dir, Process} = Stop; // Stop the elevator
                    CurrentDestination = 1; // Mark current destination as reached
                end
            end else begin
                {Dir, Process} <= Stop; // Stop the elevator if at top floor
            end
        end else if ({Dir, Process} == Down) begin
            if (WhichFloor > 0) begin
                if (PushedButtons[WhichFloor] == 1'b1) begin
                    PushedButtons[WhichFloor] <= 1'b0; // Clear the button press for current floor
                    {Dir, Process} <= Stop; // Stop the elevator
                end
                if (Destination == WhichFloor) begin
                    {Dir, Process} = Stop; // Stop the elevator
                    CurrentDestination = 1; // Mark current destination as reached
                end
            end else begin
                {Dir, Process} <= Stop; // Stop the elevator if at bottom floor
            end
        end else if (Dir ==0 && Process ==0) begin
            if (PushedButtons != {5{1'b0}}) begin
                if (PushedButtons_queue.size() > 0 && CurrentDestination) begin
                    Destination = PushedButtons_queue.pop_front(); // Get next destination from queue
                    CurrentDestination = 0;
                end
                if (Destination > WhichFloor)
                    {Dir, Process} <= Up; // Set direction to Up
                else if (Destination < WhichFloor)
                    {Dir, Process} <= Down; // Set direction to Down
            end
            if (Destination == WhichFloor) begin
                PushedButtons[WhichFloor] <= 1'b0; // Clear the button press for current floor
                CurrentDestination = 1; // Mark current destination as reached
            end
        end
    end
    
    // Always block to update the request queue based on button presses
    always @(posedge clk) begin
        for (i = 0; i < 5; i = i + 1) begin
            if (InToggle[i] | OutToggle[i] == 1'b1) begin
                 if ({Dir, Process} == Down) begin
                    if (i > WhichFloor || i < Destination)
                        PushedButtons_queue.push_back(i);
                end else if ({Dir, Process} == Stop) begin
                    if (Destination > WhichFloor) begin
                        if (i < WhichFloor)
                            PushedButtons_queue.push_back(i);
                        else if (i > Destination)
                            PushedButtons_queue.push_back(i);
                    end else if (Destination < WhichFloor) begin
                        if (i > WhichFloor)
                            PushedButtons_queue.push_back(i);
                        else if (i < Destination)
                            PushedButtons_queue.push_back(i);
                    end else
                        PushedButtons_queue.push_back(i);
                end else if ({Dir, Process} == Up) begin
                    if (WhichFloor > i || i > Destination)
                        PushedButtons_queue.push_back(i);
                end
            end
        end
    end
endmodule