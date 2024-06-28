
module Asansor (
    input Clk,               // Clock input
    input [1:0] State,       // State input to control elevator movement
    output reg [4:0] WhichFloor, // Output to indicate the current floor
    output reg [1:0] FloorInOut [4:0] // Output array to indicate floor states
);

    // Local parameters for elevator states
    localparam Stop = 2'b00,
               Up = 2'b11,
               Down = 2'b01;

    // Initial block to set initial values
    integer i;
    initial begin
        // Initialize all floor states to notStarting yet
        for (i = 0; i < 5; i = i + 1) begin
            FloorInOut[i] = 2'b11;
        end
        WhichFloor = 5'b00000; // Start at floor 0
    end

    // Always block triggered on the positive edge of Clk or Reset
    always @(negedge Clk) begin
       // Reset all floor states to notStarting Yet
        for (i = 0; i < 5; i = i + 1) begin
            FloorInOut[i] = 2'b11;
        end           
        // State machine to control elevator behavior
            case (State)
                Stop: begin
                    FloorInOut[WhichFloor] = 2'b00; // Mark current floor as stopped
                    #100; // Delay for debounce or timing purposes
                end

                Up: begin
                    if (WhichFloor < 5) begin // Check if not already at the top floor
                        FloorInOut[WhichFloor] = 2'b10; // Mark floor as visited
                        WhichFloor = WhichFloor + 1;    // Move up one floor
                        FloorInOut[WhichFloor] = 2'b01; // Mark new floor as current
                    end
                    #20; // Delay for debounce or timing purposes
                end

                Down: begin
                    if (WhichFloor > 0) begin // Check if not already at the bottom floor
                        FloorInOut[WhichFloor] = 2'b10; // Mark floor as visited
                        WhichFloor = WhichFloor - 1;    // Move down one floor
                        FloorInOut[WhichFloor] = 2'b01; // Mark new floor as current
                    end
                    #20; // Delay for debounce or timing purposes
                end
                default: 
                    ; // No default action
            endcase
        end
endmodule