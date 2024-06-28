module TB;
    wire Process;
    wire Dir;
    wire [4:0] PushedButtons;
    reg clk;
    reg [4:0] InToggle;
    reg [4:0] OutToggle;
    wire [4:0] WhichFloor;
    wire [1:0] FloorInOut [4:0];

    Asansor asansor (
        .Clk(clk),
        .State({Dir, Process}),
        .WhichFloor(WhichFloor),
        .FloorInOut(FloorInOut)
    );

    Handler handler (
        .clk(clk),
        .WhichFloor(WhichFloor),
        .InToggle(InToggle),
        .OutToggle(OutToggle),
        .Dir(Dir),
        .Process(Process),
        .PushedButtons(PushedButtons)
    );


    always #10 clk = ~clk;

    task handle_in_toggle(input [4:0] floor, input integer delay_time);
        begin
            InToggle[floor] = 1'b1;
            #delay_time InToggle[floor] = 1'b0;
        end
    endtask

    task handle_out_toggle(input [4:0] floor, input integer delay_time);
        begin
            OutToggle[floor] = 1'b1;
            #delay_time OutToggle[floor] = 1'b0;
        end
    endtask

    initial begin
        clk = 0;
        InToggle = 0;
        OutToggle = 0;

        handle_out_toggle(0, 20);
        handle_in_toggle(2, 20);
        #400
        handle_out_toggle(1, 20);
        handle_in_toggle(2, 20);
        handle_out_toggle(3, 20);
        handle_in_toggle(0, 20);
        #400
        handle_out_toggle(2, 20);
        handle_out_toggle(4, 20);
        #400
        handle_in_toggle(0, 20);
        handle_in_toggle(2, 20);
        #1000;
        $stop();
    end

    reg [1:0] TmpFloor [4:0];
    reg TmpProcess;
    reg TmpDir;
    reg [4:0] TmpButtons;
    integer i;

    always @(posedge clk) begin
        if (FloorInOut !== TmpFloor || Process !== TmpProcess || Dir !== TmpDir || PushedButtons !== TmpButtons) begin
            $display("Time: %3d | PushedButtons: %b | Process: %b | Dir: %b | Floors: %s | %s | %s | %s | %s", 
                     $time, PushedButtons, Process, Dir,
                     FloorInOut[0] == 2'b00 ? "STOP" : (FloorInOut[0] == 2'b01 ? "IN" : (FloorInOut[0] == 2'b10 ? "OUT" : "-")),
                     FloorInOut[1] == 2'b00 ? "STOP" : (FloorInOut[1] == 2'b01 ? "IN" : (FloorInOut[1] == 2'b10 ? "OUT" : "-")),
                     FloorInOut[2] == 2'b00 ? "STOP" : (FloorInOut[2] == 2'b01 ? "IN" : (FloorInOut[2] == 2'b10 ? "OUT" : "-")),
                     FloorInOut[3] == 2'b00 ? "STOP" : (FloorInOut[3] == 2'b01 ? "IN" : (FloorInOut[3] == 2'b10 ? "OUT" : "-")),
                     FloorInOut[4] == 2'b00 ? "STOP" : (FloorInOut[4] == 2'b01 ? "IN" : (FloorInOut[4] == 2'b10 ? "OUT" : "-")));
        end
        TmpFloor <= FloorInOut;
        TmpProcess <= Process;
        TmpDir <= Dir;
        TmpButtons <= PushedButtons;
    end
endmodule
