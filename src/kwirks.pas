(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

unit Kwirks;

{$I kwirkdefs.inc}

interface

uses
  DefBase;

Procedure DrawKwirk;
Procedure JumpKwirk;
Procedure ChangeKwirk(var Maze: MazeType);
Procedure SetKwirkDir(c: Char);
Procedure MoveKwirk(var Maze: MazeType; dx,dy: Int16);

var ActiveKwirk: Int16;
       //KwirkDir: Char;
         KwirkX,
         KwirkY: Int16;
        //MoveImg: KwirkMoveImgType;
    KwirkStands: Boolean;

implementation

uses
  CrtUnit, GraphUnit, CrtUtils, Renderer, Compat, Maze, KW_Snd;

var ///ActiveKwirk: Int16;
       KwirkDir: Char;
         //KwirkX,
         //KwirkY: Int16;
        MoveImg: KwirkMoveImgType;
    //KwirkStands: Boolean;

Procedure DrawKwirk;
  begin
  if TextKwirk then
    begin
    TextAttr:=Yellow+16*Magenta;
    GotoFldXY(KwirkX,KwirkY);
    case KwirkDir of
      '>': Write('>>>');
      '^': Write('^^^');
      '<': Write('<<<');
      'V': Write('vvv');
      else Write('***');
      end;
    end
  else begin
    DrawImage(KwirkX,KwirkY,Img[MoveImg.Img[0]],0,0,CopyPut);
    end;
  end;

Procedure JumpKwirk;
  var i,y,y0: Int16;
           T: LongInt;
  begin
  if not KwirkStands then DrawKwirk;
  KwirkStands:=True;
  y:=0;
  for i:=-3 to 4 do
    begin
    StartTimer(T);
    y0:=y;
    y:=round((i*i-16)/27*ImgYsize);
    DrawImage(KwirkX,KwirkY,Img[MoveImg.Img[0]],0,y0,XorPut);
    DrawImage(KwirkX,KwirkY,Img[MoveImg.Img[0]],0,y,XorPut);
    WaitTimerTick(T,JumpSpeed);
    ClearKbdRepeat;
    end;
  DrawKwirk;
  end;

Procedure ChangeKwirk(var Maze: MazeType);
  var x,y: Int16;
  begin
  if ActiveKwirk>0 then
    begin
    Maze.KwirkX[ActiveKwirk]:=KwirkX;
    Maze.KwirkY[ActiveKwirk]:=KwirkY;
    Maze.M[KwirkY,KwirkX]:=KwirkDir;
    if not KwirkStands then DrawKwirk;
    SetMazeImage(Maze,KwirkX,KwirkY);
    DrawMazeImage(Maze,KwirkX,KwirkY);
    end;
  Inc(ActiveKwirk);
  if ActiveKwirk>Maze.nKwirks then ActiveKwirk:=1;
  x:=Maze.KwirkX[ActiveKwirk];
  y:=Maze.KwirkY[ActiveKwirk];
  KwirkDir:=Maze.M[y,x]; Maze.M[y,x]:=' ';
  case KwirkDir of
    '>': MoveImg:=MoveRightImg;
    '^': MoveImg:=MoveUpImg;
    '<': MoveImg:=MoveLeftImg;
    'V': MoveImg:=MoveDownImg;
    else MoveImg:=MoveLeftImg;
    end;
  KwirkStands:=True;
  KwirkX:=x; KwirkY:=y;
  JumpKwirk;
  end;

Procedure SetKwirkDir(c: Char);
  var T: LongInt;
  begin
  if c=KwirkDir then exit;
  StartTimer(T);
  KwirkDir:=c;
  case KwirkDir of
    '>': MoveImg:=MoveRightImg;
    '^': MoveImg:=MoveUpImg;
    '<': MoveImg:=MoveLeftImg;
    'V': MoveImg:=MoveDownImg;
    else MoveImg:=MoveLeftImg;
    end;
  DrawKwirk;
  WaitTimerTick(T,KwirkXSpeed);
  end;

Procedure MoveKwirk(var Maze: MazeType; dx,dy: integer);
  var i,n,j,j0,s: Int16;
     x0,y0,x1,y1: Int16;
         PutMode: Int16;
            Bump: Boolean;
      XorPutMode: Boolean;
     MoveBoxFlag,
    MoveDoorFlag,
  DoorDoubleMove,
         DoorCCW,                 { Door Counter-Clockwise }
         DW1,DW2,
         DW3,DW4: Boolean;
              m1: MazeType;
       Xneu,Yneu: Int16;
     DoorX,DoorY,
     BoxX1,BoxY1,
     BoxX2,BoxY2: Int16;
               f: Char;
      DelayTimer: LongInt;

  Procedure PutKwirk(a,i: Int16; dx,dy: Int16; PutMode: Int16);
    var x,y,m: Int16;
    begin
    DrawImage(KwirkX,KwirkY,Img[MoveImg.Img[i]],dx,dy,PutMode);
    if MoveBoxFlag then
      for x:=BoxX1 to BoxX2 do
        for y:=BoxY1 to BoxY2 do
          begin
          DrawImage(x,y,Img[ImgMaze[y,x].Source1],dx,dy,PutMode);
          end;
    if MoveDoorFlag then
      begin
      m:=n;
      if ImgXsize>ImgYsize
        then    begin if dx<>0 then begin a:=(a*ImgYsize) div ImgXsize; m:=(m*ImgYsize) div ImgXsize end end
        else if ImgYsize>ImgXsize then
                begin if dy<>0 then begin a:=(a*ImgXsize) div ImgYsize; m:=(m*ImgXsize) div ImgYsize end end;

      if not DoorCCW then a:=-a;
      if Bump or (abs(a)<(m div 2))
        then begin
          if DW1 then DrawImage(DoorX+1,DoorY  ,Img[DoorWing1], 0,-a,PutMode);
          if DW2 then DrawImage(DoorX  ,DoorY-1,Img[DoorWing2],-a, 0,PutMode);
          if DW3 then DrawImage(DoorX-1,DoorY  ,Img[DoorWing3], 0, a,PutMode);
          if DW4 then DrawImage(DoorX  ,DoorY+1,Img[DoorWing4], a, 0,PutMode);
          end
        else begin
          a:=m-abs(a);
          if not DoorCCW then a:=-a;
          if not DoorCCW
            then begin
              if DW2 then DrawImage(DoorX+1,DoorY  ,Img[DoorWing1], 0, a,PutMode);
              if DW3 then DrawImage(DoorX  ,DoorY-1,Img[DoorWing2], a, 0,PutMode);
              if DW4 then DrawImage(DoorX-1,DoorY  ,Img[DoorWing3], 0,-a,PutMode);
              if DW1 then DrawImage(DoorX  ,DoorY+1,Img[DoorWing4],-a, 0,PutMode);
              end
            else begin
              if DW4 then DrawImage(DoorX+1,DoorY  ,Img[DoorWing1], 0, a,PutMode);
              if DW1 then DrawImage(DoorX  ,DoorY-1,Img[DoorWing2], a, 0,PutMode);
              if DW2 then DrawImage(DoorX-1,DoorY  ,Img[DoorWing3], 0,-a,PutMode);
              if DW3 then DrawImage(DoorX  ,DoorY+1,Img[DoorWing4],-a, 0,PutMode);
              end
          end
      end;
    ClearKbdRepeat;
    end;
  begin { of MoveKwirk }
  Xneu:=KwirkX+dx; Yneu:=KwirkY+dy;
  if (CheckMazeP(Maze,Yneu,Xneu,0)=1) or    { Wasser oder am Rand }
     (Xneu>Maze.xs) or (Xneu<1) or (Yneu>Maze.ys) or (Yneu<1) then
       begin
       DrawKwirk;
       KwirkStands:=True;
       exit;
       end;
  Bump:=False; XorPutMode:=False; MoveDoorFlag:=False; MoveBoxFlag:=False;
  f:=Maze.M[Yneu,Xneu];
  if f in BoxChar then
    begin
    MoveBoxFlag:=True;
    CalcBoxSize(Maze,Xneu,Yneu,BoxX1,BoxY1,BoxX2,BoxY2);
    Bump:=not CheckBoxMovable(Maze,BoxX1,BoxY1,BoxX2,BoxY2,dx,dy);
    end else
  if f in DoorWingChar then
    begin
    DoorX:=Xneu; DoorY:=Yneu; MoveDoorFlag:=True; DoorDoubleMove:=False;
    case f of
      '“': if dy=0 then Inc(DoorY) else MoveDoorFlag:=False;
      '∆': if dx=0 then Inc(DoorX) else MoveDoorFlag:=False;
      'µ': if dx=0 then Dec(DoorX) else MoveDoorFlag:=False;
      '–': if dy=0 then Dec(DoorY) else MoveDoorFlag:=False;
      end;
    if MoveDoorFlag then
      begin
      if   dx=-1 then DoorCCW:=DoorY>KwirkY else   { Drehrichtung ermitteln }
        if dx=1  then DoorCCW:=DoorY<KwirkY else
        if dy=-1 then DoorCCW:=DoorX<KwirkX else
        if dy=1  then DoorCCW:=DoorX>KwirkX;
      DW1:=CheckMaze(Maze,['µ'],DoorY  ,DoorX+1,0)=1;
      DW2:=CheckMaze(Maze,['“'],DoorY-1,DoorX  ,0)=1;
      DW3:=CheckMaze(Maze,['∆'],DoorY  ,DoorX-1,0)=1;
      DW4:=CheckMaze(Maze,['–'],DoorY+1,DoorX  ,0)=1;
      Bump:=not CheckDoorMovable(Maze,DoorX,DoorY,DoorCCW);
      M1:=Maze;
      MoveDoor(M1,DoorX,DoorY,DoorCCW,False);
      DoorDoubleMove:=M1.M[Yneu,Xneu] in DoorWingChar;
      if DoorDoubleMove and (CheckMazeP(Maze,Yneu+dy,Xneu+dx,0)=1) then Bump:=True;
      end else Bump:=True;
    end;
  Bump:=Bump or (f in ['W']+DoorCenterChar+KwirkChar);
  if Bump then ClearKbdBuffer;
  XorPutMode:=XorPutMode or Bump or (f='Z');
  if dx=0 then begin n:=ImgYsize; s:=KwirkYsteps end  else begin n:=ImgXsize; s:=KwirkXsteps end;
  if MoveDoorFlag and DoorDoubleMove then n:=2*n;
  if Bump then begin n:=KwirkBumpSteps; Xneu:=KwirkX; Yneu:=KwirkY end;
  if XorPutMode and not KwirkStands then DrawKwirk;
  if not Bump or (KwirkBumpSteps>0) then
    begin
    if QuickMoving and not Bump
      then begin
        {DrawMazeImage(Maze,KwirkX,KwirkY);}
        DrawImage(KwirkX,KwirkY,Nil,0,0,CopyPut)
        end
      else begin
        if Bump then PlayFile('Wall*.*',False)
        else if MoveDoorFlag then PlayFile('TÅr*.*',True);
        x0:=0; y0:=0; x1:=dx; y1:=dy; j:=1; j0:=0;
        for i:=1 to n do
          begin
          StartTimer(DelayTimer);
          if XorPutMode
            then begin
              PutKwirk(i-1,j0,x0,y0,XorPut);
              PutKwirk(i,j,x1,y1,XorPut);
              end
            else PutKwirk(i,j,x1,y1,CopyPut);
          if dy=0 then WaitTimerTick(DelayTimer,KwirkXSpeed) else WaitTimerTick(DelayTimer,KwirkYSpeed);
          j0:=j;  Inc(j); if j>s then j:=1;  {j ist ZÑhler fÅr die Schritte des Kwirks}
          x0:=x1; y0:=y1; Inc(x1,dx); Inc(y1,dy)
          end;
        if Bump then
          for i:=n downto ord(MoveDoorFlag) do
            begin
            StartTimer(DelayTimer);
            Dec(j); if j<1 then j:=s;
            Dec(x1,dx); Dec(y1,dy);
            PutKwirk(i,j0,x0,y0,XorPut);
            PutKwirk(i-1,j,x1,y1,XorPut);
            if dy=0 then WaitTimerTick(DelayTimer,KwirkXSpeed) else WaitTimerTick(DelayTimer,KwirkYSpeed);
            j0:=j; x0:=x1; y0:=y1;
            end;
        end;
    if not Bump then
      begin
      Inc(KwirkX,dx); Inc(KwirkY,dy);
      if MoveDoorFlag then MoveDoor(Maze,DoorX,DoorY,DoorCCW,True);
      if MoveBoxFlag then MoveBox(Maze,BoxX1,BoxY1,BoxX2,BoxY2,dx,dy);
      if MoveDoorFlag and DoorDoubleMove then begin Inc(KwirkX,dx); Inc(KwirkY,dy) end;
      end;
    end;
  KwirkStands:=False;
  if KbdRepeated then
    begin
    ClearKbdRepeat;
    KbdRepeated:=False
    end;
  end; { of MoveKwirk }

end.

