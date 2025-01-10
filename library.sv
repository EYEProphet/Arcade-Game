`default_nettype none

module Decoder
  #(parameter WIDTH = 8)
  (input logic [$clog2(WIDTH) - 1:0] I,
  input logic en,
  output logic [WIDTH-1:0] D);

  assign D = (en) ? (2**I) : '0;

endmodule: Decoder

module BarrelShifter
  (input logic [15:0] V,
  input logic [3:0] by,
  output logic [15:0] S);

  assign S = V << by;

endmodule: BarrelShifter


module Multiplexer
  #(parameter WIDTH = 8)
  (input logic [WIDTH-1:0] I,
  input logic [$clog2(WIDTH) - 1:0] S,
  output logic Y);

  assign Y = I[S];

endmodule: Multiplexer


module Mux2to1
  #(parameter WIDTH = 7)
  (input logic [WIDTH-1:0] I0,
  input logic [WIDTH-1:0] I1,
  input logic S,
  output logic [WIDTH-1:0] Y);

  assign Y = (S === 1'b1) ? I1 : I0; 


endmodule: Mux2to1


module MagComp
  #(parameter WIDTH = 8)
  (input logic [WIDTH-1:0] A,
  input logic [WIDTH-1:0] B,
  output logic AltB,
  output logic AeqB,
  output logic AgtB);

  assign AltB = (A < B);
  assign AeqB = (A === B);
  assign AgtB = (A > B);

endmodule: MagComp


module Comparator
  #(parameter WIDTH = 4)
  (input logic [WIDTH-1:0] A,
  input logic [WIDTH-1:0] B,
  output logic AeqB);

  assign AeqB = (A === B);


endmodule: Comparator


module Adder
  #(parameter WIDTH = 8)
  (input logic cin,
  input logic [WIDTH-1:0] A, B,
  output logic cout,
  output logic [WIDTH-1:0] sum);

  assign {cout, sum} = A + B + cin;

endmodule: Adder

module Subtracter
  #(parameter WIDTH = 8)
  (input logic bin,
  input logic [WIDTH-1:0] A, B,
  output logic bout,
  output logic [WIDTH-1:0] diff);

  assign {bout, diff} = A - B - bin;


endmodule: Subtracter


module DFlipFlop
  (input logic preset_L, D, clock, reset_L,
  output logic Q);

  always_ff @(posedge clock, negedge reset_L, negedge preset_L)
    if (~reset_L)
      Q <= 0;
    else if (~preset_L)
      Q <= 1;
    else
      Q <= D;

endmodule: DFlipFlop


module Register
  #(parameter WIDTH = 8)
  (input logic en, clear, clock,
  input logic [WIDTH - 1:0] D,
  output logic [WIDTH - 1:0] Q);

  always_ff @(posedge clock)
    if (en)
      Q <= D;
    else if (clear)
      Q <= '0;

endmodule: Register


module Counter
  #(parameter WIDTH = 8)
  (input logic en, clear, load, up, clock,
  input logic [WIDTH-1:0] D,
  output logic [WIDTH-1:0] Q);

   always_ff @(posedge clock)
    if (clear)
      Q <= '0;
    else if (load)
      Q <= D;
    else if (up && en)
      Q <= Q + 1'd1;
    else if (~up && en)
      Q <= Q - 1'd1;

endmodule: Counter


module Synchronizer
  (input logic async, clock,
  output logic sync);

    logic buffer;

    always_ff @(posedge clock) begin
      buffer <= async;
      sync <= buffer;
    end

endmodule: Synchronizer


module ShiftRegisterSIPO
  #(parameter WIDTH = 8)
  (input logic en, left, serial, clock,
  output logic [WIDTH-1:0] Q);

  always_ff @(posedge clock)
    if (left && en)
      Q <= {Q[WIDTH-2:0], serial};
    else if (~left && en)
      Q <= {serial, Q[WIDTH-1:1]};

endmodule: ShiftRegisterSIPO


module ShiftRegisterPIPO
  #(parameter WIDTH = 8)
  (input logic en, left, load, clock,
  input logic [WIDTH-1:0] D,
  output logic [WIDTH-1:0] Q);

  always_ff @(posedge clock)
    if (load)
      Q <= D;
    else if (left && en && ~load)
      Q <= Q << 1;
    else if (~left && en && ~load)
      Q <= Q >> 1;

endmodule: ShiftRegisterPIPO


module BarrelShiftRegister
  #(parameter WIDTH = 8)
  (input logic en, load, clock,
  input logic [1:0] by,
  input logic [WIDTH-1:0] D,
  output logic [WIDTH-1:0] Q);

  always_ff @(posedge clock)
    if (load)
      Q <= D;
    else if (en)
      Q <= Q << by;

endmodule: BarrelShiftRegister

module BusDriver
  #(parameter WIDTH = 8)
  (input logic en, 
  input logic [WIDTH-1:0] data,
  output logic [WIDTH-1:0] buff,
  inout tri [WIDTH-1:0] bus);

  assign bus = (en) ? data : 'bz;
  assign buff = bus; 

endmodule: BusDriver


module Memory
  #(parameter DW = 16,
              W  = 256,
              AW = $clog2(W))
  (input logic re, we, clock,
  input logic [AW-1:0] addr,
  inout tri [DW-1:0] data);
  
  logic [DW-1:0] M[W];
  logic [DW-1:0] rData;
  
  assign data = (re) ? rData: 'bz;
  
  always_ff @(posedge clock)
    if (we)
      M[addr] <= data;

  always_comb
    rData = M[addr];

endmodule: Memory
