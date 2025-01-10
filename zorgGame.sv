`default_nettype none

module ChipInterface // Chip Interface for FPGA and VGA connections
  (input logic [17:0] SW,
  input logic [3:0] KEY,
  input logic CLOCK_50,
  output logic [7:0] LEDG,
  output logic [8:0] LEDR,
  output logic [6:0] HEX3, HEX2, HEX1, HEX0,
  output logic [7:0]  VGA_R, VGA_G, VGA_B,
  output logic        VGA_BLANK_N, VGA_CLK, VGA_SYNC_N,
  output logic        VGA_VS, VGA_HS);

  logic [3:0] znarlyOut, zoodOut, roundOut, gamesOut;
  logic [11:0] masterOut;
  logic GameWonOut, maxRoundOut, clearGameOut, done, loadValue, syncGradeIt;

  assign clearGameOut = (GameWonOut|maxRoundOut);
  assign LEDG[0] = GameWonOut;


  ZorgGame game(.CoinValue(SW[17:16]), .ShapeLocation(SW[4:3]), 
                .CoinInserted(KEY[1]), .StartGame(KEY[2]), .GradeIt(KEY[3]), 
                .LoadShapeNow(KEY[3]), .reset(KEY[0]), .clock(CLOCK_50), 
                .Guess(SW[11:0]), .LoadShape(SW[2:0]),.Znarly(znarlyOut), 
                .Zood(zoodOut), .RoundNumber(roundOut), .NumGames(gamesOut),
                .GameWon(GameWonOut), .maxRound(maxRoundOut),
                .masterPattern(masterOut), .doneMasterPattern(done), 
                .syncGradeIt);


  mastermindVGA vgaDisplay(.CLOCK_50, .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N, 
                           .VGA_CLK, .VGA_SYNC_N, .VGA_VS, .VGA_HS, 
                           .numGames(gamesOut), .loadNumGames(1'b1), 
                           .roundNumber(roundOut), .guess(SW[11:0]), 
                           .loadGuess(done), .znarly(znarlyOut), 
                           .zood(zoodOut), .loadZnarlyZood(syncGradeIt),
                           .clearGame(clearGameOut), .masterPattern(masterOut),
                           .displayMasterPattern(SW[15]), .reset(~KEY[0]));


  SevenSegmentDisplay seg(.BCD0(gamesOut), .BCD1(roundOut), .BCD2(zoodOut), 
                          .BCD3(znarlyOut), .blank(8'b1111_0000), .HEX0, .HEX1,
                          .HEX2, .HEX3);
  
endmodule: ChipInterface


// Expanded version of the abstract FSM implemented in Task 2
module myAbstractFSMExpanded (
  output logic [3:0] credit,
  output logic drop,
  input logic [1:0] CoinValue,
  input logic CoinInserted_L, clock, reset_L);

  enum logic [4:0] {NOCREDIT, HOLDC00, HOLDT00, HOLDP00, 
                    CRED1DROP0, HOLDC10, HOLDT10, HOLDP10, 
                    CRED2DROP0, HOLDC20, HOLDT20, HOLDP20, 
                    CRED3DROP0, HOLDC30, HOLDT30, HOLDP30, 
                    CRED0DROP1, HOLDC01, HOLDT01, HOLDP01,
                    CRED1DROP1, HOLDC11, HOLDT11, HOLDP11, 
                    CRED2DROP1, HOLDC21, HOLDT21, HOLDP21, 
                    CRED3DROP1, HOLDC31, HOLDT31, HOLDP31} currState, nextState;

//Next State Logic
always_comb begin
  case (currState)
    NOCREDIT: begin
        if (CoinValue == 2'b01 & ~CoinInserted_L)
          nextState = HOLDC00;
        else if (CoinValue == 2'b10 & ~CoinInserted_L)
          nextState = HOLDT00;
        else if (CoinValue == 2'b11 & ~CoinInserted_L)
          nextState = HOLDP00;
        else
          nextState = NOCREDIT;
    end
    HOLDC00: begin
        if (~CoinInserted_L)
          nextState = HOLDC00;
        else
          nextState = CRED1DROP0;
    end
    HOLDT00: begin
        if (~CoinInserted_L)
          nextState = HOLDT00;
        else
          nextState = CRED3DROP0;
    end
    HOLDP00: begin
        if (~CoinInserted_L)
          nextState = HOLDP00;
        else
          nextState = CRED1DROP1;
    end

    CRED1DROP0: begin
        if (CoinValue == 2'b01 & ~CoinInserted_L)
          nextState = HOLDC10;
        else if (CoinValue == 2'b10 & ~CoinInserted_L)
          nextState = HOLDT10;
        else if (CoinValue == 2'b11 & ~CoinInserted_L)
          nextState = HOLDP10;
        else
          nextState = CRED1DROP0;
    end
    HOLDC10: begin
        if (~CoinInserted_L)
          nextState = HOLDC10;
        else
          nextState = CRED2DROP0;
    end
    HOLDT10: begin
        if (~CoinInserted_L)
          nextState = HOLDT10;
        else
          nextState = CRED0DROP1;
    end
    HOLDP10: begin
        if (~CoinInserted_L)
          nextState = HOLDP10;
        else
          nextState = CRED2DROP1;
    end

    CRED2DROP0: begin
        if (CoinValue == 2'b01 & ~CoinInserted_L)
          nextState = HOLDC20;
        else if (CoinValue == 2'b10 & ~CoinInserted_L)
          nextState = HOLDT20;
        else if (CoinValue == 2'b11 & ~CoinInserted_L)
          nextState = HOLDP20;
        else
          nextState = CRED2DROP0;
    end
    HOLDC20: begin
        if (~CoinInserted_L)
          nextState = HOLDC20;
        else
          nextState = CRED3DROP0;
    end
    HOLDT20: begin
        if (~CoinInserted_L)
          nextState = HOLDT20;
        else
          nextState = CRED1DROP1;
    end
    HOLDP20: begin
        if (~CoinInserted_L)
          nextState = HOLDP20;
        else
          nextState = CRED3DROP1;
    end

    CRED3DROP0: begin
        if (CoinValue == 2'b01 & ~CoinInserted_L)
          nextState = HOLDC30;
        else if (CoinValue == 2'b10 & ~CoinInserted_L)
          nextState = HOLDT30;
        else if (CoinValue == 2'b11 & ~CoinInserted_L)
          nextState = HOLDP30;
        else
          nextState = CRED3DROP0;
    end
    HOLDC30: begin
        if (~CoinInserted_L)
          nextState = HOLDC30;
        else
          nextState = CRED0DROP1;
    end
    HOLDT30: begin
        if (~CoinInserted_L)
          nextState = HOLDT30;
        else
          nextState = CRED2DROP1;
    end
    HOLDP30: begin
        if (~CoinInserted_L)
          nextState = HOLDP30;
        else
          nextState = CRED0DROP1;
    end

    CRED0DROP1: begin
        if (CoinValue == 2'b01 & ~CoinInserted_L)
          nextState = HOLDC01;
        else if (CoinValue == 2'b10 & ~CoinInserted_L)
          nextState = HOLDT01;
        else if (CoinValue == 2'b11 & ~CoinInserted_L)
          nextState = HOLDP01;
        else
          nextState = NOCREDIT;
    end    
    HOLDC01: begin
        if (~CoinInserted_L)
          nextState = HOLDC01;
        else
          nextState = CRED1DROP0;
    end
    HOLDT01: begin
        if (~CoinInserted_L)
          nextState = HOLDT01;
        else
          nextState = CRED3DROP0;
    end
    HOLDP01: begin
        if (~CoinInserted_L)
          nextState = HOLDP01;
        else
          nextState = CRED1DROP1;
    end

    CRED1DROP1: begin
        if (CoinValue == 2'b01 & ~CoinInserted_L)
          nextState = HOLDC11;
        else if (CoinValue == 2'b10 & ~CoinInserted_L)
          nextState = HOLDT11;
        else if (CoinValue == 2'b11 & ~CoinInserted_L)
          nextState = HOLDP11;
        else
          nextState = CRED1DROP0;
    end
    HOLDC11: begin
        if (~CoinInserted_L)
          nextState = HOLDC11;
        else
          nextState = CRED2DROP0;
    end
    HOLDT11: begin
        if (~CoinInserted_L)
          nextState = HOLDT11;
        else
          nextState = CRED0DROP1;
    end
    HOLDP11: begin
        if (~CoinInserted_L)
          nextState = HOLDP11;
        else
          nextState = CRED2DROP1;
    end

    CRED2DROP1: begin
        if (CoinValue == 2'b01 & ~CoinInserted_L)
          nextState = HOLDC21;
        else if (CoinValue == 2'b10 & ~CoinInserted_L)
          nextState = HOLDT21;
        else if (CoinValue == 2'b11 & ~CoinInserted_L)
          nextState = HOLDP21;
        else
          nextState = CRED2DROP0;
    end
    HOLDC21: begin
        if (~CoinInserted_L)
          nextState = HOLDC21;
        else
          nextState = CRED3DROP0;
    end
    HOLDT21: begin
        if (~CoinInserted_L)
          nextState = HOLDT21;
        else
          nextState = CRED1DROP1;
    end
    HOLDP21: begin
        if (~CoinInserted_L)
          nextState = HOLDP21;
        else
          nextState = CRED3DROP1;
    end

    CRED3DROP1: begin
        if (CoinValue == 2'b01 & ~CoinInserted_L)
          nextState = HOLDC31;
        else if (CoinValue == 2'b10 & ~CoinInserted_L)
          nextState = HOLDT31;
        else if (CoinValue == 2'b11 & ~CoinInserted_L)
          nextState = HOLDP31;
        else
          nextState = CRED3DROP0;
    end
    HOLDC31: begin
        if (~CoinInserted_L)
          nextState = HOLDC31;
        else
          nextState = CRED0DROP1;
    end
    HOLDT31: begin
        if (~CoinInserted_L)
          nextState = HOLDT31;
        else
          nextState = CRED2DROP1;
    end
    HOLDP31: begin
        if (~CoinInserted_L)
          nextState = HOLDP31;
        else
          nextState = CRED0DROP1;
    end
  
    default: begin
        nextState = NOCREDIT;
    end
  endcase
end

//Output logic
always_comb begin
  credit = 4'b0000; drop = 1'b0;
  unique case (currState)
    NOCREDIT: begin
      drop = 1'b0;
      credit = 4'b0000;
    end
    HOLDC00: begin
      drop = 1'b0;
      credit = 4'b0000;
    end
    HOLDT00: begin
      drop = 1'b0;
      credit = 4'b0000;
    end
    HOLDP00: begin
      drop = 1'b0;
      credit = 4'b0000;
    end

    CRED1DROP0: begin
      drop = 1'b0;
      credit = 4'b0001;
    end
    HOLDC10: begin
      drop = 1'b0;
      credit = 4'b0001;
    end
    HOLDT10: begin
      drop = 1'b0;
      credit = 4'b0001;
    end
    HOLDP10: begin
      drop = 1'b0;
      credit = 4'b0001;
    end
    
    CRED2DROP0: begin
      drop = 1'b0;
      credit = 4'b0010;
    end
    HOLDC20: begin
      drop = 1'b0;
      credit = 4'b0010;
    end
    HOLDT20: begin
      drop = 1'b0;
      credit = 4'b0010;
    end
    HOLDP20: begin
      drop = 1'b0;
      credit = 4'b0010;
    end
    
    CRED3DROP0: begin
      drop = 1'b0;
      credit = 4'b0011;
    end
    HOLDC30: begin
      drop = 1'b0;
      credit = 4'b0011;
    end
    HOLDT30: begin
      drop = 1'b0;
      credit = 4'b0011;
    end
    HOLDP30: begin
      drop = 1'b0;
      credit = 4'b0011;
    end

    CRED0DROP1: begin
      drop = 1'b1;
      credit = 4'b0000;
    end
    HOLDC01: begin
      drop = 1'b0;
      credit = 4'b0000;
    end
    HOLDT01: begin
      drop = 1'b0;
      credit = 4'b0000;
    end
    HOLDP01: begin
      drop = 1'b0;
      credit = 4'b0000;
    end

    CRED1DROP1: begin
      drop = 1'b1;
      credit = 4'b0001;
    end
    HOLDC11: begin
      drop = 1'b0;
      credit = 4'b0001;
    end
    HOLDT11: begin
      drop = 1'b0;
      credit = 4'b0001;
    end
    HOLDP11: begin
      drop = 1'b0;
      credit = 4'b0001;
    end
    
    CRED2DROP1: begin
      drop = 1'b1;
      credit = 4'b0010;
    end
    HOLDC21: begin
      drop = 1'b0;
      credit = 4'b0010;
    end
    HOLDT21: begin
      drop = 1'b0;
      credit = 4'b0010;
    end
    HOLDP21: begin
      drop = 1'b0;
      credit = 4'b0010;
    end
    
    CRED3DROP1: begin
      drop = 1'b1;
      credit = 4'b0011;
    end
    HOLDC31: begin
      drop = 1'b0;
      credit = 4'b0011;
    end
    HOLDT31: begin
      drop = 1'b0;
      credit = 4'b0011;
    end
    HOLDP31: begin
      drop = 1'b0;
      credit = 4'b0011;
    end
  endcase
end

always_ff @(posedge clock, negedge reset_L)
    if (~reset_L)
      currState <= NOCREDIT;
    else
      currState <= nextState;

endmodule: myAbstractFSMExpanded


module ZorgGame // Task 2 Datapath
  (input logic [1:0] CoinValue, ShapeLocation,
  input logic CoinInserted, StartGame, GradeIt, LoadShapeNow, reset, clock,
  input logic [11:0] Guess,
  input logic [2:0] LoadShape,
  output logic [3:0] Znarly, Zood, RoundNumber, NumGames,
  output logic [11:0] masterPattern,
  output logic GameWon, maxRound, doneMasterPattern, syncGradeIt);

  logic numGameEn, numGameClr, numGameUp, notPaid, maxGames, shapeEn1, 
        shapeEn2, shapeClr1, shapeClr2, firstLoc, 
        secondLoc, thirdLoc, fourthLoc, validLocation, roundEn, roundClr, 
        guessedIt, underRoundLimit, syncCoinInserted, 
        syncStartGame, syncLoadShapeNow, syncReset, 
        drop, nextGame, Gclr, Gload, ldZnarly, ldZood, clrZnarly, clrZood;

  logic [11:0] newShape, moveShapeOut, savedShiftedShapeOut,
               choosePositionOut;
  logic [1:0] checkLocationOut;
  logic [3:0] shiftedByValue, numGamesOut, credit;
  
  //Lab3 (Input here)
  myAbstractFSMExpanded takeCoins(.credit, .drop, .CoinValue, 
                                  .CoinInserted_L(syncCoinInserted), 
                                  .clock, .reset_L(syncReset));

  Synchronizer sync1(.async(CoinInserted), .clock, .sync(syncCoinInserted));
  Synchronizer sync2(.async(StartGame), .clock, .sync(syncStartGame));
  Synchronizer sync3(.async(GradeIt), .clock, .sync(syncGradeIt));
  Synchronizer sync4(.async(LoadShapeNow), .clock, .sync(syncLoadShapeNow));
  Synchronizer sync5(.async(reset), .clock, .sync(syncReset));

  masterPatternFSM f1(.StartGame_L(syncStartGame), .GradeIt_L(syncGradeIt), 
                  .LoadShapeNow_L(syncLoadShapeNow), .reset_L(syncReset), 
                  .GameWon, .*);
  numOfGameFSM f2(.reset_L(syncReset), .*);

  Counter #(4) numberOfGames(.en(numGameEn), .clear(numGameClr), 
                             .up(numGameUp), .load(1'b0), .clock, .D(), 
                             .Q(numGamesOut));

  assign NumGames = numGamesOut;

  Counter #(4) numberOfRounds(.en(roundEn), .clear(roundClr), .load(1'b0), 
                              .up(1'b1), .clock, .D(), .Q(RoundNumber));

  Comparator #(4) paidOrNot(.A(numGamesOut), .B(4'd0), .AeqB(notPaid));
  Comparator #(4) maxNumberOfGames(.A(numGamesOut), .B(4'd7), .AeqB(maxGames));
  Comparator #(4) guess(.A(Znarly), .B(4'd4), .AeqB(guessedIt));

  Comparator #(3) locationOne(.A(masterPattern[2:0]), .B(3'd0),
                              .AeqB(firstLoc));
  Comparator #(3) locationTwo(.A(masterPattern[5:3]), .B(3'd0),
                              .AeqB(secondLoc));
  Comparator #(3) locationThird(.A(masterPattern[8:6]), .B(3'd0),
                              .AeqB(thirdLoc));
  Comparator #(3) locationFourth(.A(masterPattern[11:9]), .B(3'd0),
                              .AeqB(fourthLoc));

  MagComp #(4) c1(.A(RoundNumber), .B(4'd8), .AltB(underRoundLimit), .AgtB(),
               .AeqB(maxRound));
                    
  always_comb begin
    newShape[11:3] = 9'b0;
    newShape[2:0] = LoadShape[2:0];
    shiftedByValue = 4'd0;
    if (ShapeLocation == 2'b00)
      shiftedByValue = 4'd0;
    else if (ShapeLocation == 2'b01)
      shiftedByValue = 4'd3;
    else if (ShapeLocation == 2'b10)
      shiftedByValue = 4'd6;
    else if (ShapeLocation == 2'b11)
      shiftedByValue = 4'd9;
  end
    
  BarrelShifter moveShape(.V(newShape), .by(shiftedByValue), 
                          .S(moveShapeOut));

  Register #(12) saveShiftValue(.en(shapeEn1), .clear(shapeClr1), .clock, 
                                .D(moveShapeOut), .Q(savedShiftedShapeOut));
  Register #(12) finalPos(.en(shapeEn2), .clear(shapeClr2), .clock, 
                          .D(choosePositionOut), .Q(masterPattern));

  assign choosePositionOut = masterPattern | savedShiftedShapeOut;

  Multiplexer #(4) m1(.I({fourthLoc, thirdLoc, secondLoc, firstLoc}), 
                    .S(ShapeLocation), .Y(validLocation));

  assign doneMasterPattern = ~(firstLoc | secondLoc | thirdLoc | fourthLoc);
  assign nextGame = GameWon | maxRound;

  Grader grade(.Guess, .masterPattern, .Gclr, .Gload, 
               .clock(clock), .Znarly(Znarly), .Zood(Zood), .doneMasterPattern,
               .ldZnarly, .ldZood, .clrZnarly, .clrZood);

endmodule: ZorgGame


module masterPatternFSM // FSM for controlling game based on masterPattern input
  (input logic StartGame_L, GradeIt_L, LoadShapeNow_L, notPaid, 
   doneMasterPattern, validLocation, guessedIt, underRoundLimit, maxRound, 
   reset_L, clock,
   output logic GameWon, shapeClr1, shapeClr2, roundEn, roundClr, shapeEn1, 
   shapeEn2, Gclr, Gload, ldZnarly, ldZood, clrZnarly, clrZood);

  enum logic [3:0] {INIT, PREP, FINISHPREP, FINISH, EXIT, INCROUND, WON, HOLD1,
                    HOLD2} currState, nextState;

  //Next State Logic
  always_comb begin
    nextState = INIT;
    case(currState)
      INIT: begin
        if (StartGame_L)
          nextState = INIT;
        else if (~StartGame_L && ~notPaid)
          nextState = PREP;
      end
      PREP: begin
        if (LoadShapeNow_L)
          nextState = PREP;
        else if (~LoadShapeNow_L)
          nextState = FINISHPREP;
      end
      FINISHPREP: begin
        if (~validLocation & LoadShapeNow_L)
          nextState = PREP;
        else if (validLocation & LoadShapeNow_L)
          nextState = FINISH;
        else if (~LoadShapeNow_L)
          nextState = FINISHPREP;
      end
      FINISH: begin
        if (~doneMasterPattern)
          nextState = HOLD1;
        else if (doneMasterPattern)
          nextState = EXIT;
      end
      HOLD1: begin
        if (~doneMasterPattern)
          nextState = PREP;
        else if (doneMasterPattern)
          nextState = EXIT;
      end
      EXIT: begin
        if (maxRound)
          nextState = INIT;
        else if (~GradeIt_L & ~guessedIt & ~maxRound)
          nextState = HOLD2;
        else if (GradeIt_L)
          nextState = EXIT;
      end
      HOLD2: begin
        if (~GradeIt_L)
          nextState = HOLD2;
        else if(GradeIt_L)
          nextState = INCROUND;
      end
      INCROUND: 
        if (guessedIt & underRoundLimit)
          nextState = WON;
        else
          nextState = EXIT;
      WON: begin
        nextState = INIT;
      end
    endcase
  end

  //Output Logic
  always_comb begin
    shapeClr1 = 0; shapeClr2 = 0; roundClr = 0; roundEn = 0; 
    shapeEn1 = 0; shapeEn2 = 0; GameWon = 0; Gclr = 0; Gload = 0; ldZnarly = 0;
    ldZood = 0; clrZnarly = 0; clrZood = 0;
    unique case(currState)
      INIT: begin
        shapeClr1 = 1;
        shapeClr2 = 1;
        roundClr = 1;
        roundEn = 0;
        shapeEn1 = 0;
        shapeEn2 = 0;
        GameWon = 0;
        Gclr = 1; 
        Gload = 0; 
        ldZnarly = 0;
        ldZood = 0; 
        clrZnarly = 1;
        clrZood = 1;
      end
      PREP: begin
        shapeClr1 = 1;
        shapeClr2 = 0;
        roundClr = 0;
        roundEn = 0;
        shapeEn1 = 0;
        shapeEn2 = 0;
        Gclr = 0; 
        Gload = 0; 
        ldZnarly = 0;
        ldZood = 0; 
        clrZnarly = 0;
        clrZood = 0;
      end
      FINISHPREP: begin
        shapeClr1 = 0;
        shapeClr2 = 0;
        roundClr = 0;
        roundEn = 0;
        shapeEn1 = 1;
        shapeEn2 = 0;
        Gclr = 0; 
        Gload = 0; 
        ldZnarly = 0;
        ldZood = 0; 
        clrZnarly = 0;
        clrZood = 0;
      end
      FINISH: begin
        shapeClr1 = 1;
        shapeClr2 = 0;
        roundClr = 0;
        roundEn = 0;
        shapeEn1 = 0;
        shapeEn2 = 1;
        Gclr = 0; 
        Gload = 0; 
        ldZnarly = 0;
        ldZood = 0; 
        clrZnarly = 0;
        clrZood = 0;
      end
      HOLD1: begin
        shapeClr1 = 1;
        shapeClr2 = 0;
        roundClr = 0;
        roundEn = 0;
        shapeEn1 = 0;
        shapeEn2 = 1;
        Gclr = 0; 
        Gload = 0; 
        ldZnarly = 0;
        ldZood = 0; 
        clrZnarly = 0;
        clrZood = 0;
      end
      EXIT: begin
        shapeClr1 = 0;
        shapeClr2 = 0;
        roundClr = 0;
        roundEn = 0;
        shapeEn1 = 0;
        shapeEn2 = 0;
        Gclr = 1; 
        Gload = 0; 
        ldZnarly = 0;
        ldZood = 0; 
        clrZnarly = 0;
        clrZood = 0;
      end
      HOLD2: begin
        shapeClr1 = 0;
        shapeClr2 = 0;
        roundClr = 0;
        roundEn = 0;
        shapeEn1 = 0;
        shapeEn2 = 0;
        Gclr = 0; 
        Gload = 1; 
        ldZnarly = 1;
        ldZood = 1; 
        clrZnarly = 0;
        clrZood = 0;
      end
      INCROUND: begin
        shapeClr1 = 0;
        shapeClr2 = 0;
        roundClr = 0;
        roundEn = 1;
        shapeEn1 = 0;
        shapeEn2 = 0;
        Gclr = 1; 
        Gload = 0; 
        ldZnarly = 0;
        ldZood = 0; 
        clrZnarly = 1;
        clrZood = 1;
      end
      WON: begin
        shapeClr1 = 1;
        shapeClr2 = 1;
        roundClr = 0;
        roundEn = 0;
        shapeEn1 = 0;
        shapeEn2 = 0;
        GameWon = 1;
        Gclr = 1; 
        Gload = 0; 
        ldZnarly = 0;
        ldZood = 0; 
        clrZnarly = 1;
        clrZood = 1;
      end
    endcase
  end   

  always_ff @(posedge clock, negedge reset_L)
    if (~reset_L)
      currState <= INIT;
    else
      currState <= nextState; 

endmodule: masterPatternFSM


module numOfGameFSM // FSM for controlling number of games
  (input logic drop, maxGames, nextGame, reset_L, clock,
  output logic numGameEn, numGameClr, numGameUp);

  enum logic [1:0] {INIT, PAID, STOP, REMOVEGAME} currState, nextState;

  //Next State Logic
  always_comb begin
    nextState = INIT;
    case(currState)
      INIT: begin
        if (~drop | maxGames)
          nextState = INIT;
        else if (drop & ~maxGames)
          nextState = PAID;
      end
      PAID: begin
        if (drop & ~maxGames & ~nextGame)
          nextState = PAID;
        else if (~nextGame & (~drop | maxGames))
          nextState = STOP;
        else if (nextGame)
          nextState = REMOVEGAME;
      end
      STOP: begin
        if (~nextGame & (~drop | maxGames))
          nextState = STOP;
        else if (drop & ~maxGames & ~nextGame)
          nextState = PAID;
        else if (nextGame)
          nextState = REMOVEGAME;
      end
      REMOVEGAME: begin
        nextState = STOP;
      end
    endcase
  end

  //Output Logic
  always_comb begin
    numGameEn = 0; numGameClr = 0; numGameUp = 0;
    unique case(currState)
      INIT: begin
        numGameEn = 0;
        numGameClr = 1;
        numGameUp = 0;
      end
      PAID: begin
        numGameEn = 1;
        numGameClr = 0;
        numGameUp = 1;
      end
      STOP: begin
        numGameEn = 0;
        numGameClr = 0;
        numGameUp = 1;    
      end
      REMOVEGAME: begin
        numGameEn = 1;
        numGameClr = 0;
        numGameUp = 0;
      end
    endcase
  end

  always_ff @(posedge clock, negedge reset_L)
    if (~reset_L)
      currState <= INIT;
    else
      currState <= nextState; 

endmodule: numOfGameFSM


// Count Znarlys and Zoods in Guess compared to masterPattern
module Grader
  (input logic [11:0] Guess, masterPattern,
   input logic Gclr, Gload, clock, doneMasterPattern, ldZnarly, ldZood, 
   input logic clrZnarly, clrZood,
   output logic AeqB1, AeqB2, AeqB3, AeqB4,
   output logic [11:0] Guess_pos,
   output logic [3:0] Znarly, Zood, sum1, sum2, sum3, sum4, sum5, sum6, sum7);

   logic [3:0] znarlyOut, zoodOut, finalZnarly, finalZood;

   // Znarly Counter //
   Register #(12) r1(.D(Guess), .Q(Guess_pos), 
                     .clock(clock), .en(Gload), .clear(Gclr));

   Comparator #(4) znc1(.A(Guess_pos[2:0]), .B(masterPattern[2:0]), 
                          .AeqB(AeqB1));
   Comparator #(4) znc2(.A(Guess_pos[5:3]), .B(masterPattern[5:3]), 
                          .AeqB(AeqB2));
   Comparator #(4) znc3(.A(Guess_pos[8:6]), .B(masterPattern[8:6]), 
                          .AeqB(AeqB3));
   Comparator #(4) znc4(.A(Guess_pos[11:9]), .B(masterPattern[11:9]), 
                          .AeqB(AeqB4));

   Adder #(4) zna1(.A(AeqB1), .B(AeqB2), .sum(sum1), .cin(0), .cout());
   Adder #(4) zna2(.A(AeqB3), .B(AeqB4), .sum(sum2), .cin(0), .cout());
   Adder #(4) zna3(.A(sum1), .B(sum2), .sum(znarlyOut), .cin(0), .cout());

   // Zood Counter //
   logic [2:0] Tshape, Cshape, Oshape, Dshape, Ishape, Zshape;
   logic [3:0] T_count, C_count, O_count, D_count, I_count, Z_count;

   assign Tshape = 3'b001;
   assign Cshape = 3'b010;
   assign Oshape = 3'b011;
   assign Dshape = 3'b100;
   assign Ishape = 3'b101;
   assign Zshape = 3'b110;
   
   // Compare number of specific shape in Guess vs. masterPattern
   Shape_Counter tc(.Shape(Tshape),
                    .partial_Zoods(T_count), .Guess_pos(Guess_pos), 
                    .masterPattern(masterPattern));
   Shape_Counter cc(.Shape(Cshape), 
                    .partial_Zoods(C_count), .Guess_pos(Guess_pos), 
                    .masterPattern(masterPattern));
   Shape_Counter oc(.Shape(Oshape), 
                    .partial_Zoods(O_count), .Guess_pos(Guess_pos), 
                    .masterPattern(masterPattern));
   Shape_Counter dc(.Shape(Dshape), 
                    .partial_Zoods(D_count), .Guess_pos(Guess_pos), 
                    .masterPattern(masterPattern));
   Shape_Counter ic(.Shape(Ishape), 
                    .partial_Zoods(I_count), .Guess_pos(Guess_pos), 
                    .masterPattern(masterPattern));
   Shape_Counter zc(.Shape(Zshape), 
                    .partial_Zoods(Z_count), .Guess_pos(Guess_pos), 
                    .masterPattern(masterPattern));

   Adder #(3) zoa1(.A(T_count), .B(C_count), .sum(sum3), .cin(0), .cout());
   Adder #(3) zoa2(.A(O_count), .B(D_count), .sum(sum4), .cin(0), .cout());
   Adder #(3) zoa3(.A(I_count), .B(Z_count), .sum(sum5), .cin(0), .cout());
   Adder #(3) zoa4(.A(sum3), .B(sum4), .sum(sum6), .cin(0), .cout());
   Adder #(3) zoa5(.A(sum6), .B(sum5), .sum(sum7), .cin(0), .cout());

   // Subtract Znarly count from shape count to obtain Zood count
   Subtracter #(3) sub(.A(sum7), .B(znarlyOut), .diff(zoodOut), .bin(0), 
                       .bout());
                       
   Register #(4) z1(.D(znarlyOut), .Q(finalZnarly), 
                     .clock(clock), .en(ldZnarly), .clear(clrZnarly));
   Register #(4) z2(.D(zoodOut), .Q(finalZood), 
                     .clock(clock), .en(ldZood), .clear(clrZood));

   always_comb begin
    if (~doneMasterPattern) begin
      Znarly = 4'b0;
      Zood = 4'b0;
    end
    else begin
      Znarly = finalZnarly;
      Zood = finalZood;
    end
   end

endmodule: Grader


// Count number of shapes in Guess and masterPattern
module Shape_Counter
  (input logic [11:0] Guess_pos, masterPattern,
   input logic [2:0] Shape,
   output logic [2:0] partial_Zoods,
   output logic mp_AeqB1, mp_AeqB2, mp_AeqB3, mp_AeqB4,
   output logic [3:0] mp_sum1, mp_sum2, mp_sum3,
   output logic g_AeqB1, g_AeqB2, g_AeqB3, g_AeqB4,
   output logic [3:0] g_sum1, g_sum2, g_sum3,
   output logic mag_AgtB);

  // Count Shape in masterPattern
  Comparator #(3) zocmp1(.A(Shape), .B(masterPattern[2:0]),
                          .AeqB(mp_AeqB1));
  Comparator #(3) zocmp2(.A(Shape), .B(masterPattern[5:3]), 
                          .AeqB(mp_AeqB2));
  Comparator #(3) zocmp3(.A(Shape), .B(masterPattern[8:6]), 
                          .AeqB(mp_AeqB3));
  Comparator #(3) zocmp4(.A(Shape), .B(masterPattern[11:9]), 
                          .AeqB(mp_AeqB4));

  Adder #(3) zoamp1(.A(mp_AeqB1), .B(mp_AeqB2), .sum(mp_sum1), 
                    .cin(0), .cout());
  Adder #(3) zoamp2(.A(mp_AeqB3), .B(mp_AeqB4), .sum(mp_sum2), 
                    .cin(0), .cout());
  Adder #(3) zoamp3(.A(mp_sum1), .B(mp_sum2), .sum(mp_sum3), 
                    .cin(0), .cout());

  // Count Shape in Guess
  Comparator #(3) zocg1(.A(Shape), .B(Guess_pos[2:0]), 
                        .AeqB(g_AeqB1));
  Comparator #(3) zocg2(.A(Shape), .B(Guess_pos[5:3]), 
                        .AeqB(g_AeqB2));
  Comparator #(3) zocg3(.A(Shape), .B(Guess_pos[8:6]), 
                        .AeqB(g_AeqB3));
  Comparator #(3) zocg4(.A(Shape), .B(Guess_pos[11:9]), 
                        .AeqB(g_AeqB4));

  Adder #(3) zoag1(.A(g_AeqB1), .B(g_AeqB2), .sum(g_sum1), 
                   .cin(0), .cout());
  Adder #(3) zoag2(.A(g_AeqB3), .B(g_AeqB4), .sum(g_sum2), 
                   .cin(0), .cout());
  Adder #(3) zoag3(.A(g_sum1), .B(g_sum2), .sum(g_sum3), 
                   .cin(0), .cout());

  // Compare masterPattern and Guess Shape counts
  MagComp #(3) mg(.A(mp_sum3), .B(g_sum3), 
                  .AltB(), .AeqB(), .AgtB(mag_AgtB));

  // Select lowest count
  Mux2to1 #(3) mult(.I0(mp_sum3), .I1(g_sum3), .S(mag_AgtB), .Y(partial_Zoods));

endmodule: Shape_Counter


//Helps to display the variables we defined onto the FPGA board BCDs
module SevenSegmentDisplay
(input logic [3:0] BCD7, BCD6, BCD5, BCD4, BCD3, BCD2, BCD1, BCD0,
input logic [7:0] blank,
output logic [6:0] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);

logic [6:0] preHEX7, preHEX6, preHEX5, preHEX4, preHEX3, preHEX2, preHEX1, 
            preHEX0;
logic [6:0] nonInvertedHEX7,nonInvertedHEX6,nonInvertedHEX5,nonInvertedHEX4,
            nonInvertedHEX3,nonInvertedHEX2, nonInvertedHEX1, nonInvertedHEX0;

BCDtoSevenSegment d0(.bcd(BCD0), .segment(preHEX0));
BCDtoSevenSegment d1(.bcd(BCD1), .segment(preHEX1));
BCDtoSevenSegment d2(.bcd(BCD2), .segment(preHEX2));
BCDtoSevenSegment d3(.bcd(BCD3), .segment(preHEX3));
BCDtoSevenSegment d4(.bcd(BCD4), .segment(preHEX4));
BCDtoSevenSegment d5(.bcd(BCD5), .segment(preHEX5));
BCDtoSevenSegment d6(.bcd(BCD6), .segment(preHEX6));
BCDtoSevenSegment d7(.bcd(BCD7), .segment(preHEX7));

Mux2to1 m0(.I0(preHEX0), .I1(7'b0), .S(blank[0]), .Y(nonInvertedHEX0));
Mux2to1 m1(.I0(preHEX1), .I1(7'b0), .S(blank[1]), .Y(nonInvertedHEX1));
Mux2to1 m2(.I0(preHEX2), .I1(7'b0), .S(blank[2]), .Y(nonInvertedHEX2));
Mux2to1 m3(.I0(preHEX3), .I1(7'b0), .S(blank[3]), .Y(nonInvertedHEX3));
Mux2to1 m4(.I0(preHEX4), .I1(7'b0), .S(blank[4]), .Y(nonInvertedHEX4));
Mux2to1 m5(.I0(preHEX5), .I1(7'b0), .S(blank[5]), .Y(nonInvertedHEX5));
Mux2to1 m6(.I0(preHEX6), .I1(7'b0), .S(blank[6]), .Y(nonInvertedHEX6));
Mux2to1 m7(.I0(preHEX7), .I1(7'b0), .S(blank[7]), .Y(nonInvertedHEX7));

assign HEX0 = ~nonInvertedHEX0;
assign HEX1 = ~nonInvertedHEX1;
assign HEX2 = ~nonInvertedHEX2;
assign HEX3 = ~nonInvertedHEX3;
assign HEX4 = ~nonInvertedHEX4;
assign HEX5 = ~nonInvertedHEX5;
assign HEX6 = ~nonInvertedHEX6;
assign HEX7 = ~nonInvertedHEX7;

endmodule: SevenSegmentDisplay


//Converts the BCDs into the seven segments for the displays on the FPGA
module BCDtoSevenSegment
  (input logic [3:0] bcd,
  output logic [6:0] segment);

  always_comb begin
    unique case(bcd)
      4'b0000: segment = 7'b011_1111;
      4'b0001: segment = 7'b000_0110;
      4'b0010: segment = 7'b101_1011;
      4'b0011: segment = 7'b100_1111;
      4'b0100: segment = 7'b110_0110;
      4'b0101: segment = 7'b110_1101;
      4'b0110: segment = 7'b111_1101;
      4'b0111: segment = 7'b000_0111;
      4'b1000: segment = 7'b111_1111;
      4'b1001: segment = 7'b110_0111;
      default: segment = 7'b000_0000;
    endcase
  end
endmodule: BCDtoSevenSegment


module ZorgGame_test; // Testbench for ZorgGame
  logic [1:0] CoinValue, ShapeLocation;
  logic CoinInserted, StartGame, GradeIt, LoadShapeNow, reset, clock, GameWon;
  logic maxRound;
  logic [11:0] Guess, masterPattern;
  logic [2:0] LoadShape;
  logic [3:0] Znarly, Zood, RoundNumber, NumGames;
  logic doneMasterPattern;

  ZorgGame DUT(.*);

  initial begin
    clock = 0;
    forever #5 clock = ~clock;
  end

  initial begin
    $monitor($time,, "Coin = %b location = %b coinInserted = %b start = %b",
    CoinValue, ShapeLocation, CoinInserted, StartGame,
    " grade = %b loadShape = %b loadNow = %b guess = %b", GradeIt, LoadShape, 
    LoadShapeNow, Guess,
    " Znarly = %d Zood = %d, RoundNumber = %d, NumGames = %d Won = %d",
    Znarly, Zood, RoundNumber, NumGames, GameWon);

    //Initial Values
    reset <= 0; CoinValue <= 2'b01; ShapeLocation <= 2'b00; CoinInserted <= 1;
    StartGame <= 1; GradeIt <= 1; LoadShapeNow <= 1; LoadShape <= 3'b110; 
    Guess <= 12'b010_001_110_001;

    @(posedge clock);
    
    reset <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    StartGame <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    LoadShapeNow <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    StartGame <= 1; LoadShapeNow <= 1; CoinInserted <= 0; 
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    CoinInserted <= 1; 
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    CoinValue <= 2'b10; CoinInserted <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    CoinInserted <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    CoinValue <= 2'b11; CoinInserted <= 0;
    @(posedge clock);
    @(posedge clock);
    CoinInserted <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    CoinInserted <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    CoinInserted <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    CoinInserted <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    CoinInserted <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    CoinInserted <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    CoinInserted <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    CoinInserted <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    CoinInserted <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    CoinInserted <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    CoinInserted <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    StartGame <= 0;
    @(posedge clock);
    StartGame <= 1;
    @(posedge clock);
    @(posedge clock);
    LoadShapeNow <= 0; ShapeLocation <= 2'b10;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    LoadShapeNow <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    LoadShapeNow <= 0; LoadShape <= 3'b110;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    LoadShapeNow <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    LoadShapeNow <= 0; LoadShape <= 3'b001; ShapeLocation <= 2'b00;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    LoadShapeNow <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    LoadShapeNow <= 0; LoadShape <= 3'b110;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    LoadShapeNow <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    LoadShapeNow <= 0; LoadShape <= 3'b101; ShapeLocation <= 2'b11;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    LoadShapeNow <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
     LoadShapeNow <= 0; LoadShape <= 3'b100; ShapeLocation <= 2'b01;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    LoadShapeNow <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 0; Guess <= 12'b101_011_001_110;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 0; Guess <= 12'b101_011_001_110;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 0; Guess <= 12'b101_011_001_110;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 0; Guess <= 12'b101_011_001_110;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 0; Guess <= 12'b101_011_001_110;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 0; Guess <= 12'b101_110_100_001;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    #1 $finish;
  end

endmodule: ZorgGame_test