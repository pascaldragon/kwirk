(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

unit Engine; { for " The Quest of Kwirk's Castle " }
interface

{$I kwirkdefs.inc}
{ $D+,L+} { $D-,L-}

uses DefBase;

Function PlayKwirk(Const MazeP: MazeType): Boolean;

implementation

uses CrtUnit,{KbdRep,}GraphUnit,{StdSubs,}{Timer,}KW_Snd,Chat,Compat,CrtUtils,Renderer,Utils,Maze,Kwirks;

Const ChangeKbdVector = True;

Function PlayKwirk(Const MazeP: MazeType): Boolean;
  var         c: Word;
           Maze: MazeType;
              i: Int16;
            _Try: Int16;
  RoomStartTime: LongInt;
           t,t0: LongInt;
              a: Boolean;
             DT: LongInt;
              s: String[63];
        bBorder: Boolean;
        bAllAim: Boolean;

  var t7: Real;
      a0: Boolean;
      RefT1,RefT2: Boolean;
            First: Boolean;
       bRetryRoom: Boolean;

  begin { of PlayKwirk }
  LastKey:=0;
  PlayKwirk:=False;
  First:=True;
  t0:=round(rTime);
  RoomStartTime:=t0;
  {$ifdef enable}
  KbdRep.ChangeKbdVector:=ChangeKbdVector;
  if not QuickMoving then InstallKbdRepHandler;
  {$endif}
  KbdRepeated:=False;
  _Try:=0; a0:=False;
  RefT1:=False; RefT2:=False;
  repeat
    Maze:=MazeP;
    KorregMaze(Maze);
    SetImgMaze(Maze);
    DrawField(Maze);
    if First then
      begin
      t:=round(rTime);
      writeTime1(t-RoomStartTime);
      writeTime2(t-LevelStartTime);
      First:=False
      end;
    Inc(_Try); WriteAttempt(_Try);
    for i:=1 to MaxKwirksPerMaze do Maze.Jump[i]:=True;
    ClearKbdBuffer; c:=0;
    ActiveKwirk:=0; ChangeKwirk(Maze);
    repeat
      {repeat}
      a := False;//KbdKeyDown;

        if ShowMovingTime then
          begin
          if a and not a0 then t7:=rTime;
          if not a and a0 then begin GotoXY(1,1); write(rTime-t7:8:2) end;
          a0:=a;
          end;
        if not KwirkStands and QuickMoving then
          begin
          DrawKwirk;
          KwirkStands:=True
          end;
        if KwirkKeyPressed then
          begin
          c:=KwirkReadKey;
          writeln(c);
          end
        else begin
          if QuickMoving
                 then c:=0
                 else if a {KbdKeyDown}
                        then c:=LastKey { wenn Taste noch niedergehalten wird -> nocheinmal }
                        else c:=0;
          end;
        if (c=0) then
          begin
          if not KwirkStands then
            begin
            DrawKwirk;
            KwirkStands:=True
            end;
          t:=round(rTime);
          if t<>t0 then
            begin
            RefT1:=True;
            RefT2:=True;
            t0:=t
            end;
          if RefT1 then begin writeTime1(t0-RoomStartTime); RefT1:=False end;
          if RefT2 then begin writeTime2(t0-LevelStartTime); RefT2:=False end;
          end;
      {until c<>0;}
      case c of
        0:;
        KeyF1: if not TextKwirk then
                 begin
                 ShowHelp;
                 SetImgMaze(Maze);
                 DrawField(Maze);
                 DrawKwirk;
                 JumpKwirk;
                 end;
        Ord('N')-Ord('@'): ChangeKwirk(Maze);
        CsrRg,Ord('6'): begin SetKwirkDir('>'); MoveKwirk(Maze,1,0) end;
        CsrUp,Ord('8'): begin SetKwirkDir('^'); MoveKwirk(Maze,0,-1) end;
        CsrLf,Ord('4'): begin SetKwirkDir('<'); MoveKwirk(Maze,-1,0) end;
        CsrDn,Ord('2'): begin SetKwirkDir('V'); MoveKwirk(Maze,0,1) end;
        {iBckSp: {MoveBack; {im Moment noch fr Retry verwendet}
        {iHome,Ord('Z')-Ord('@'): {MoveBack; {im Moment noch fr Retry verwendet}
        Ord('+'),Ord('-'):;
        else if TextKwirk and CopyVideo then DoChat(Word(c));{}
        end;
      if not TextKwirk then
        begin
        if c=Ord('M')-Ord('@') then {if Maze.nKwirks>1 then} ChangeKwirk(Maze);(**)
        end;
      bRetryRoom:=(c=CsrHm) or (c=Ord('Z')-Ord('@'));
      {if TextKwirk and CopyVideo then DoChat(Word(c));}
      if Maze.Jump[ActiveKwirk] and ((MazeP.M[KwirkY,KwirkX]='J') or
         (KwirkX<=1) or (KwirkX>=Maze.xs) or (KwirkY<=1) or (KwirkY>=Maze.ys)) then
        begin
        JumpKwirk;
        Maze.Jump[ActiveKwirk]:=False;
        end;
      if Maze.M[KwirkY,KwirkX]='Z' then
        begin
        DrawMazeImage(Maze,KwirkX,KwirkY);
        for i:=ActiveKwirk to Maze.nKwirks-1 do
          begin
          Maze.KwirkX[i]:=Maze.KwirkX[i+1];
          Maze.KwirkY[i]:=Maze.KwirkY[i+1];
          Maze.Jump[i]:=Maze.Jump[i+1];
          end;
        ActiveKwirk:=0;
        Dec(Maze.nKwirks);
        if Maze.nKwirks>0 then ChangeKwirk(Maze);
        ClearKbdBuffer;
        end;
      bBorder:=(Maze.nKwirks<=0) or (KwirkX<=1) or (KwirkX>=Maze.xs) or (KwirkY<=1) or (KwirkY>=Maze.ys);
      bAllAim:=Maze.nKwirks<=0;
    until bAllAim or bBorder or (not TextKwirk and (LastKey=Escap)) or (LastKey=ord('Q')-Ord('@')) or
          (LastKey=KeyTb) or (LastKey=Ord('+')) or (LastKey=ShfTb) or (LastKey=Ord('-')) or
          (LastKey=KeyF3) or (LastKey=Alt_X) or bRetryRoom or CheckTimeout(0);
  until not bRetryRoom;
  t:=round(rTime); if t<>t0 then begin writeTime1(t-RoomStartTime); writeTime2(t-LevelStartTime) end;
  PlayKwirk:=bBorder or bAllAim;
  if Maze.M[KwirkY,KwirkX]='Z' then
    begin
    if TextKwirk then
      begin
      s:='   Joe Merten, JME Engineering Berlin   ';
      TextAttr:=Yellow;
      while Length(s)>=3 do
        begin
        GotoFldXY(KwirkX,KwirkY);
        Write(Copy(s,1,3));
        Delete(s,1,1);
        StartTimer(DT);
        while (ReadTimerTick(DT)<500) do;
        end;
      end
    else begin
      StartTimer(DT); while (ReadTimerTick(DT)<JoeMSpeed) do;
      StartTimer(DT);
      DrawImage(KwirkX,KwirkY,Img[JMEFld],0,0,XorPut);
      while (ReadTimerTick(DT)<JoeMSpeed) do;

      StartTimer(DT);
      DrawImage(KwirkX,KwirkY,Img[AimFld],0,0,XorPut);
      while (ReadTimerTick(DT)<1.5*JoeMSpeed) do;

      StartTimer(DT);
      DrawImage(KwirkX,KwirkY,Img[JoeMFld],0,0,XorPut);
      while (ReadTimerTick(DT)<JoeMSpeed) do;

      StartTimer(DT);
      DrawImage(KwirkX,KwirkY,Img[JMEFld],0,0,XorPut);
      while (ReadTimerTick(DT)<2*JoeMSpeed) do;
      end;
    PlayKwirk:=True;
    end;
  {$ifdef enable}
  RemoveKbdRepHandler;
  {$endif}
  end;

end.