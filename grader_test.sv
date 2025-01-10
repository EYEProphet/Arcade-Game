`default_nettype none

module Grader_test; // Test Grader module and Grader_FMS
  logic [11:0] Guess, Guess_pos, masterPattern;
  logic Grade_it_L, Gclr, Gload, CLOCK_50, reset_L;
  logic AeqB1, AeqB2, AeqB3, AeqB4;
  logic [3:0] Znarly, Zood, sum1, sum2, sum3, sum4, sum5, sum6, sum7;
  logic [2:0] Tshape, Cshape, Oshape, Dshape, Ishape, Zshape;
  logic [3:0] T_count, C_count, O_count, D_count, I_count, Z_count;
  logic [2:0] partial_Zoods;

  Grader g1(.*);
  Grader_FSM f1(.*);

  initial begin
    CLOCK_50 = 0;
    reset_L <= 0;
    forever #5 CLOCK_50 = ~CLOCK_50;
  end

  initial begin
    $monitor("masterPattern = %b | Guess = %b | %d Znarly(s) | %d Zood(s)",
              masterPattern, Guess, Znarly, Zood);

  // Moore Machine, will output correct value on next clock edge

  /* T = 001
     C = 010
     O = 011
     D = 100
     I = 101
     Z = 110 */

    @(posedge CLOCK_50); // INIT, no value
    reset_L <= 1; // ignore reset
    Grade_it_L <=1;
    @(posedge CLOCK_50); // INIT, no value


    Grade_it_L <= 0;
    @(posedge CLOCK_50); // SAVE, no value
    @(posedge CLOCK_50); // SAVE, no value

    Grade_it_L <= 1;
    @(posedge CLOCK_50); // HOLD, no value

    $display("//masterPattern 1//");

    masterPattern <= 12'b101_110_100_001; // IZDT
    Guess <= 12'b001_001_010_010; // TTCC
    @(posedge CLOCK_50); // HOLD, 0 Znarlys, 1 Zood

    Guess <= 12'b011_011_100_100; // OODD
    @(posedge CLOCK_50); // HOLD, 1 Znarly, 0 Zoods

    Guess <= 12'b101_101_010_010; // IICC
    @(posedge CLOCK_50); // HOLD, 1 Znarly, 0 Zoods

    Guess <= 12'b101_011_001_110; // IOTZ
    @(posedge CLOCK_50); // HOLD, 1 Znarly, 2 Zoods

    Guess <= 12'b001_101_110_100; // TIZD
    @(posedge CLOCK_50); // HOLD, 0 Znarlys, 4 Zoods

    Guess <= 12'b101_110_100_001; // IZDT
    @(posedge CLOCK_50); // HOLD, 4 Znarlys, 0 Zoods

    Grade_it_L <= 0;
    @(posedge CLOCK_50); // SAVE, clear Register Guess value
    @(posedge CLOCK_50);



    Grade_it_L <= 1;
    @(posedge CLOCK_50); // HOLD

    $display("//masterPattern 2//");

    masterPattern <= 12'b011_011_011_011; // OOOO
    Guess <= 12'b001_001_010_010; // TTCC
    @(posedge CLOCK_50); // HOLD, 0 Znarlys, 0 Zood

    Guess <= 12'b011_011_100_100; // OODD
    @(posedge CLOCK_50); // HOLD, 2 Znarly, 0 Zoods

    Guess <= 12'b101_101_010_010; // IICC
    @(posedge CLOCK_50); // HOLD, 0 Znarly, 0 Zoods

    Guess <= 12'b101_011_001_110; // IOTZ
    @(posedge CLOCK_50); // HOLD, 1 Znarly, 0 Zoods

    Guess <= 12'b001_101_110_100; // TIZD
    @(posedge CLOCK_50); // HOLD, 0 Znarlys, 0 Zoods

    Guess <= 12'b011_011_011_011; // 0000
    @(posedge CLOCK_50); // HOLD, 4 Znarlys, 0 Zoods

    Grade_it_L <= 0;
    @(posedge CLOCK_50); // SAVE, clear Register Guess value
    @(posedge CLOCK_50);

    #5 $finish;
  end

endmodule: Grader_test