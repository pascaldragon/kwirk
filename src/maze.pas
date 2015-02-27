(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

unit Maze;

{$I kwirkdefs.inc}

interface

uses
  Dos,
  DefBase;

Function LoadMazes(FN: PathStr): Boolean;
Function SaveMazes(FN: PathStr): Boolean;
Const MazeNr: Int16 = 0;
Function CheckMazeP(var Maze: MazeType; y,x: Int16; RandWert: Int16): Int16;
Function CheckMaze(var Maze: MazeType; Compare: CharSet; y,x: Int16; RandWert: Int16): Int16;
Procedure KorregMaze(var Maze: MazeType);
Procedure AddRoomMade(Room: Word);
Function  GetNextRoom: Word;
Function  IsRoomMade(Room: Word): Boolean;
Function CalcDoorCenter(var M: MazeType; x,y: Int16; var DoorX,DoorY: Int16): Boolean;
Procedure CalcDoorWings(var M: MazeType; x,y: Int16; var re,ob,li,un: Boolean);
Procedure MoveDoor(var Maze: MazeType; x,y: Int16; ccw: Boolean; DrawDoor: Boolean);
Function CheckDoorMovable(var Maze: MazeType; x,y: Int16; ccw: Boolean): Boolean;
Function CheckBoxMovable(var Maze: MazeType; x1,y1,x2,y2: Int16; dx,dy: Int16): Boolean;
Procedure CalcBoxSize(var Maze: MazeType; xp,yp: Int16; var x1,y1,x2,y2: Int16);
Procedure MoveBox(var Maze: MazeType; x1,y1,x2,y2: Int16; dx,dy: Int16);

implementation

uses
  Compat, Renderer, KW_Snd, CrtUtils;

Function LoadMazes(FN: PathStr): Boolean;
  var  T: Text;
    s,s1: String;
       l: Byte absolute s;
      l1: Byte absolute s1;
       i: Int16;
      ln: Int16;
    NextMaze: Boolean;
    NextName: String;
  begin
  InOutRes:=0;
  Assign(T,FN); Reset(T); ln:=0; QuestName:='';
  nMazes:=0; NextMaze:=True;
  while (InOutRes=0) and not Eof(T) and (nMazes<=MaxMazes) do
    begin
    ReadLn(T,s); Inc(ln);
    if Copy(s,1,1)='['
      then begin
        NextMaze:=True;
        s:=copy(s,2,l-2);
        if l>MaxMazeNameLen then l:=MaxMazeNameLen;
        if QuestName='' then QuestName:=s
                        else NextName:=s
        end
      else begin
        if NextMaze then
          begin
          Inc(nMazes);
          if nMazes<=MaxMazes then
            begin
            Mazes[nMazes].Name:=NextName;
            Mazes[nMazes].xs:=0;
            Mazes[nMazes].ys:=0;
            end
          end;
        if (nMazes<=MaxMazes) and (Mazes[nMazes].ys<MaxMazeYsize) then
          begin
          i:=Pos('|',s);
          if i>0 then begin s1:=Copy(s,i+2,255); s:=Copy(s,1,i-2) end else s1:='';
          if l>MaxMazeXsize then l:=MaxMazeXsize;
          if l>Mazes[nMazes].xs then Mazes[nMazes].xs:=l;
          Inc(Mazes[nMazes].ys);
          for i:=1 to MaxMazeXsize do
            begin
            Mazes[nMazes].P[Mazes[nMazes].ys,i]:=(Copy(s1,i,1)='P') or (Copy(s,i,1)='P');
            if Copy(s,i,1)='P' then s[i]:=' ';  { Pf�tzen sind nur im P-Array vermerkt }
            end;
          Mazes[nMazes].M[Mazes[nMazes].ys]:=s;
          {$ifdef enable}
          vSetLen(Mazes[nMazes].M[Mazes[nMazes].ys],MaxMazeXsize);
          {$endif}
          end;
        NextMaze:=False;
        end;
    end;
  if nMazes>MaxMazes then nMazes:=MaxMazes;
  Close(T);
  LoadMazes:=IOResult=0
  end;

Procedure PutMaze(var T: Text; var M: MAzeType);
  var a: Boolean;
    x,y: Int16;
  begin
  a:=False;
  writeln(T,'['+M.Name+']');
  a:=False;
  for x:=1 to M.xs do
    for y:=1 to M.ys do
      if (M.M[y,x]<>' ') and M.P[y,x] then a:=True;

  for y:=1 to M.ys do
    begin
    if a
      then begin
        for x:=1 to M.xs do write(T,M.M[y,x]);
        write(T,' | ');
        for x:=1 to M.xs do
          if M.P[y,x] then write(T,'P') else write(T,M.M[y,x]);
        end
      else begin
        for x:=1 to M.xs do
          if M.P[y,x] then write(T,'P') else write(T,M.M[y,x]);
        end;
    writeln(T);
    end;
  end;

Function SaveMazes(FN: PathStr): Boolean;
  var  T: Text;
    s,s1: String;
       l: Byte absolute s;
      l1: Byte absolute s1;
       i: Int16;
      ln: Int16;
       a: Boolean;
  begin
  InOutRes:=0;
  Assign(T,FN); Rewrite(T);
  writeln(T,'['+QuestName+']');
  for i:=1 to nMazes do
    begin
    PutMaze(T,Mazes[i]);
    end;
  if nMazes>MaxMazes then nMazes:=MaxMazes;
  Close(T);
  SaveMazes:=IOResult=0
  end;

Function CheckMazeP(var Maze: MazeType; y,x: Int16; RandWert: Int16): Int16;
  begin
  if (x<1) or (x>Maze.xs) or (y<1) or (y>Maze.ys) then begin CheckMazeP:=RandWert; exit end;
  if Maze.P[y,x] then CheckMazeP:=1 else CheckMazeP:=0;
  end;
Function CheckMaze(var Maze: MazeType; Compare: CharSet; y,x: Int16; RandWert: Int16): Int16;
  begin
  if (x<1) or (x>Maze.xs) or (y<1) or (y>Maze.ys) then begin CheckMaze:=RandWert; exit end;
  if Maze.M[y,x] in Compare then CheckMaze:=1 else CheckMaze:=0;
  end;

Procedure KorregMaze(var Maze: MazeType);
  var x,y,i: Int16;
  begin
  Maze.nKwirks:=0;
  for x:=1 to Maze.xs do
    for y:=1 to Maze.ys do
      begin
      if Maze.M[y,x]='*' then { T�rdrehpunkt automatisch ermitteln }
        begin
        i:=1*CheckMaze(Maze,['D','�','�'],y  ,x+1,0)+  { rechts }
           2*CheckMaze(Maze,['D','�','�'],y-1,x  ,0)+  { oben   }
           4*CheckMaze(Maze,['D','�','�'],y  ,x-1,0)+  { links  }
           8*CheckMaze(Maze,['D','�','�'],y+1,x  ,0);  { unten  }
        case i of
          12: Maze.M[y,x]:='�';
           9: Maze.M[y,x]:='�';
           3: Maze.M[y,x]:='�';
           6: Maze.M[y,x]:='�';
          14: Maze.M[y,x]:='�';
          13: Maze.M[y,x]:='�';
          11: Maze.M[y,x]:='�';
           7: Maze.M[y,x]:='�';
          10: Maze.M[y,x]:='�';
           5: Maze.M[y,x]:='�';
           1: Maze.M[y,x]:='�';
           2: Maze.M[y,x]:='�';
           4: Maze.M[y,x]:='�';
           8: Maze.M[y,x]:='�';
          else Maze.M[y,x]:='�';
          end; {endcase}
        end
      else if Maze.M[y,x]='�' then { senkrechten T�rfl�gel automatisch ermitteln }
        begin
        if CheckMaze(Maze,['*','�','�','�','�','�','�','�','�'],y-1,x,0)=1
          then Maze.M[y,x]:='�'
          else Maze.M[y,x]:='�';
        end
      else if Maze.M[y,x]='�' then { waagerechten T�rfl�gel automatisch ermitteln }
        begin
        if CheckMaze(Maze,['*','�','�','�','�','�','�','�','�'],y-1,x,0)=1
          then Maze.M[y,x]:='�'
          else Maze.M[y,x]:='�';
        end
      else if Maze.M[y,x]='D' then { T�rfl�gel automatisch ermitteln }
        begin
        if CheckMaze(Maze,['*','�','�','�','�','�','�','�','�'],y  ,x+1,0)=1 then Maze.M[y,x]:='�' else
        if CheckMaze(Maze,['*','�','�','�','�','�','�','�','�'],y-1,x  ,0)=1 then Maze.M[y,x]:='�' else
        if CheckMaze(Maze,['*','�','�','�','�','�','�','�','�'],y  ,x-1,0)=1 then Maze.M[y,x]:='�' else
        if CheckMaze(Maze,['*','�','�','�','�','�','�','�','�'],y+1,x  ,0)=1 then Maze.M[y,x]:='�' else
           Maze.M[y,x]:=' '
        end
      else if Maze.M[y,x]='B' then { Kiste automatisch ermitteln }
        begin
        i:=1*CheckMaze(Maze,['B','�','�','�','�','�','�','�','�'],y,  x+1,0)+       { rechts }
           2*CheckMaze(Maze,['B','�','�','�','�','�','�','�','�'],y-1,x  ,0)+       { oben   }
           4*CheckMaze(Maze,['B','�','�','�','�','�','�','�','�'],y,  x-1,0)+       { links  }
           8*CheckMaze(Maze,['B','�','�','�','�','�','�','�','�'],y+1,x  ,0);       { unten  }
        case i of
           1: Maze.M[y,x]:='�';
           2: Maze.M[y,x]:='�';
           4: Maze.M[y,x]:='�';
           8: Maze.M[y,x]:='�';
           5: Maze.M[y,x]:='�';
          10: Maze.M[y,x]:='�';
           3: Maze.M[y,x]:='�';
           6: Maze.M[y,x]:='�';
           9: Maze.M[y,x]:='�';
          12: Maze.M[y,x]:='�';
          14: Maze.M[y,x]:='�';
          13: Maze.M[y,x]:='�';
          11: Maze.M[y,x]:='�';
           7: Maze.M[y,x]:='�';
          15: Maze.M[y,x]:='�';
          else Maze.M[y,x]:='�';
          end
        end
      else if Maze.M[y,x] in ['K','>','^','<','V'] then { Kwirk }
        begin
        if Maze.M[y,x]='K' then Maze.M[y,x]:='<';
        if Maze.nKwirks<MaxKwirksPerMaze then
          begin
          Inc(Maze.nKwirks);
          Maze.KwirkX[Maze.nKwirks]:=x;
          Maze.KwirkY[Maze.nKwirks]:=y;
          end
        end;
      end;
  end;

Function CalcDoorCenter(var M: MazeType; x,y: Int16; var DoorX,DoorY: Int16): Boolean;
  var r: Boolean;
  begin
  r:=True;
  DoorX:=x; DoorY:=y;
  case M.M[y,x] of
    '�': if M.M[y,x-1] in DoorCenterChar then Dec(DoorX) else r:=False;
    '�': if M.M[y+1,x] in DoorCenterChar then Inc(DoorY) else r:=False;
    '�': if M.M[y,x+1] in DoorCenterChar then Inc(DoorX) else r:=False;
    '�': if M.M[y-1,x] in DoorCenterChar then Dec(DoorY) else r:=False;
    else r:=False;
    end;
  CalcDoorCenter:=r
  end;

Procedure CalcDoorWings(var M: MazeType; x,y: Int16; var re,ob,li,un: Boolean);
  begin
  re:=CheckMaze(M,['�'],y  ,x+1,0)=1;
  ob:=CheckMaze(M,['�'],y-1,x  ,0)=1;
  li:=CheckMaze(M,['�'],y  ,x-1,0)=1;
  un:=CheckMaze(M,['�'],y+1,x  ,0)=1;
  end;

Procedure MoveDoor(var Maze: MazeType; x,y: Int16; ccw: Boolean; DrawDoor: Boolean);
  var x1,y1: Int16;
      i0,i1: Int16;
      c0,c1: char;
  begin
  i0:=1*CheckMaze(Maze,['�'],y  ,x+1,0)+
      2*CheckMaze(Maze,['�'],y-1,x  ,0)+
      4*CheckMaze(Maze,['�'],y  ,x-1,0)+
      8*CheckMaze(Maze,['�'],y+1,x  ,0);    { DoorCenterArr[i0] ist dann = Maze.M[y,x] }
  if ccw then i1:=(i0 shl 1)-15*ord(i0>7) else i1:=(i0 shr 1)+8*ord(odd(i0)); { Drehen }
                                    { DoorCenterArr[i1] ist nun neuer T�rmittelpunkt ! }
  c0:=Maze.M[y,x];
  if (i0 and 1)>0 then Maze.M[y  ,x+1]:=' ';
  if (i0 and 2)>0 then Maze.M[y-1,x  ]:=' ';
  if (i0 and 4)>0 then Maze.M[y  ,x-1]:=' ';
  if (i0 and 8)>0 then Maze.M[y+1,x  ]:=' ';

  c1:=DoorCenterArr[i1];
  if (i1 and 1)>0 then Maze.M[y  ,x+1]:='�';
  if (i1 and 2)>0 then Maze.M[y-1,x  ]:='�';
  if (i1 and 4)>0 then Maze.M[y  ,x-1]:='�';
  if (i1 and 8)>0 then Maze.M[y+1,x  ]:='�';
  Maze.M[y,x]:=c1;

  if DrawDoor then
    for y1:=y-1 to y+1 do
      for x1:=x-1 to x+1 do
        if {(x1=x) or (y1=y) and} (Maze.M[y1,x1]<>'W') then
          begin
          SetMazeImage(Maze,x1,y1);
          DrawMazeImage(Maze,x1,y1);
          end
  end;

Function CheckDoorMovable(var Maze: MazeType; x,y: Int16; ccw: Boolean): Boolean;
  var       i,j: Int16;
              r: Boolean;
    re,li,ob,un,
    ro,lo,lu,ru: Boolean;
  begin
  re:=(CheckMaze(Maze,[' ','J','�'],y  ,x+1,0)=1); { True: Feld ist frei }
  ob:=(CheckMaze(Maze,[' ','J','�'],y-1,x  ,0)=1);
  li:=(CheckMaze(Maze,[' ','J','�'],y  ,x-1,0)=1);
  un:=(CheckMaze(Maze,[' ','J','�'],y+1,x  ,0)=1);
  ro:=(CheckMaze(Maze,[' ','J'],y-1,x+1,0)=1);     { True: Feld ist frei }
  lo:=(CheckMaze(Maze,[' ','J'],y-1,x-1,0)=1);
  lu:=(CheckMaze(Maze,[' ','J'],y+1,x-1,0)=1);
  ru:=(CheckMaze(Maze,[' ','J'],y+1,x+1,0)=1);
  if ccw
    then case Maze.M[y,x] of   { Counter-Clockwise }
           '�': r:=ro and lo and lu and ru;
           '�': r:=ro and ob and lu and un;
           '�': r:=lo and li and ru and re;
           '�': r:=lu and ru and re;
           '�': r:=ru and ro and ob;
           '�': r:=ro and lo and li;
           '�': r:=lo and lu and un;
           '�': r:=lo and lu and ru and re;
           '�': r:=lu and ru and ro and ob;
           '�': r:=ru and ro and lo and li;
           '�': r:=ro and lo and lu and un;
           '�': r:=lu and un;
           '�': r:=ru and re;
           '�': r:=ro and ob;
           '�': r:=lo and li;
           else r:=False;
           end
    else case Maze.M[y,x] of   { Clockwise }
           '�': r:=ro and lo and lu and ru;
           '�': r:=ru and un and lo and ob;
           '�': r:=ro and re and lu and li;
           '�': r:=lu and lo and ob;
           '�': r:=ru and lu and li;
           '�': r:=ro and ru and un;
           '�': r:=lo and ro and re;
           '�': r:=lu and lo and ro and re;
           '�': r:=ru and lu and lo and ob;
           '�': r:=ro and ru and lu and li;
           '�': r:=lo and ro and ru and un;
           '�': r:=lo and ob;
           '�': r:=lu and li;
           '�': r:=ru and un;
           '�': r:=ro and re;
           else r:=False;
           end;
  { 4x1fach 4x90� 2x180� 4x3fach 1x4fach : 15 F�lle � 2 Richtungen }
  CheckDoorMovable:=r
  end;

Procedure CalcBoxSize(var Maze: MazeType; xp,yp: Int16; var x1,y1,x2,y2: Int16);
  var c: Char;
      e: Boolean;
  begin
  x1:=xp; x2:=xp; y1:=yp; y2:=yp;
  c:=Maze.M[yp,xp];
  if c='�' then exit;                    { Minni-Kiste }
  if c in ['�','�','�'] then
    begin
    while (y1>0)       and (Maze.M[y1,x1]<>'�') do Dec(y1); { senkrechte Kiste }
    while (y2<Maze.ys) and (Maze.M[y2,x2]<>'�') do Inc(y2);
    end else
  if c in ['�','�','�'] then
    begin
    while (x1>0)       and (Maze.M[y1,x1]<>'�') do Dec(x1); { waagerechte Kiste }
    while (x2<Maze.xs) and (Maze.M[y2,x2]<>'�') do Inc(x2);
    end else
  if c in ['�','�','�','�','�','�','�','�','�'] then
    begin
    while (x1>0)       and not(Maze.M[y1,x1] in ['�','�','�']) do Dec(x1); { Riesen-Kiste }
    while (x2<Maze.xs) and not(Maze.M[y2,x2] in ['�','�','�']) do Inc(x2);
    while (y1>0)       and not(Maze.M[y1,x1] in ['�','�','�']) do Dec(y1);
    while (y2<Maze.ys) and not(Maze.M[y2,x2] in ['�','�','�']) do Inc(y2);
    end;
  if (x1<1) or (x2>Maze.xs) then begin x1:=xp; x2:=xp end;
  if (y1<1) or (y2>Maze.ys) then begin y1:=yp; y2:=yp end;
  end;

Function CheckBoxMovable(var Maze: MazeType; x1,y1,x2,y2: Int16; dx,dy: Int16): Boolean;
  var i: Int16;
      r: Boolean;
  begin
  r:=True;
  if dx=-1 then for i:=y1 to y2 do if CheckMaze(Maze,[' ','J'],i,x1+dx,0)=0 then r:=False;
  if dx= 1 then for i:=y1 to y2 do if CheckMaze(Maze,[' ','J'],i,x2+dx,0)=0 then r:=False;
  if dy=-1 then for i:=x1 to x2 do if CheckMaze(Maze,[' ','J'],y1+dy,i,0)=0 then r:=False;
  if dy= 1 then for i:=x1 to x2 do if CheckMaze(Maze,[' ','J'],y2+dy,i,0)=0 then r:=False;
  CheckBoxMovable:=r
  end;

Procedure MoveBox(var Maze: MazeType; x1,y1,x2,y2: Int16; dx,dy: Int16);
  var x,y: Int16;
    x3,y3,
    x4,y4: Int16;
        a: Boolean;
        T: LongInt;
  begin
  x3:=x1; y3:=y1; x4:=x2; y4:=y2;
  if (dx=-1) or (dy=-1)
    then begin
      for x:=x1 to x2 do
        for y:=y1 to y2 do
          Maze.M[y+dy,x+dx]:=Maze.M[y,x];
      if dx=-1 then for y:=y1 to y2 do Maze.M[y,x2]:=' '
               else for x:=x1 to x2 do Maze.M[y2,x]:=' ';
      Inc(x3,dx); Inc(y3,dy);
      end
    else begin
      for x:=x2 downto x1 do
        for y:=y2 downto y1 do
          Maze.M[y+dy,x+dx]:=Maze.M[y,x];
      if dx=1 then for y:=y1 to y2 do Maze.M[y,x1]:=' '
              else for x:=x1 to x2 do Maze.M[y1,x]:=' ';
      Inc(x4,dx); Inc(y4,dy);
      end;

  Inc(x1,dx); Inc(y1,dy); Inc(x2,dx); Inc(y2,dy);     { neue Kistenposition }
  a:=True;
  for x:=x1 to x2 do
    for y:=y1 to y2 do
      if not Maze.P[y,x] then a:=False;
  if a then
    begin
    PlayFile('Fall*.*',True);
    StartTimer(T);
    for x:=x1 to x2 do                        { a=True -> Kiste versenken ! }
      for y:=y1 to y2 do
        begin
        Maze.M[y,x]:=' ';
        Maze.P[y,x]:=False;
        ImgMaze[y,x].Line1[1]:=0;
        ImgMaze[y,x].Mask1[1]:=0;
        end;
    for x:=x1 to x2 do
      for y:=y1 to y2 do
        begin
        DrawWater(x,y,1);
        ClearKbdRepeat;
        end;
    WaitTimerTick(T,WaterSpeed);
    StartTimer(T);
    for x:=x1 to x2 do
      for y:=y1 to y2 do
        begin
        DrawWater(x,y,2);
        ClearKbdRepeat;
        end;
    ClearKbdRepeat;
    WaitTimerTick(T,WaterSpeed);
    x3:=x1-1; y3:=y1-1; x4:=x2+1; y4:=y2+1;      { Refresh-Bereich anpassen }
    end;

  for x:=x3 to x4 do
    for y:=y3 to y4 do
      begin
      SetMazeImage(Maze,x,y);
      DrawMazeImage(Maze,x,y);
      end;
  end;

Procedure AddRoomMade(Room: Word);
  var s: String;
  begin
  if UserName<>'' then
    begin
    if Cfg.ReadKeyName(MazFN,s) then;
    Insert(' ',s,1);
    if Pos(' '+Int2Str(Room),s)=0 then
      begin
      Delete(s,1,1);
      if s<>'' then Insert(' ',s,255);
      Insert(Int2Str(Room),s,255);
      Cfg.WriteKeyName(MazFN,s);
      if GetNextRoom>nMazes then
        begin
        Insert(' Done.',s,255);
        Cfg.WriteKeyName(MazFN,s);
        end;
      end;
    end;
  end;

Function GetNextRoom: Word;
  var i: Word;
      s: String;
  begin
  GetNextRoom:=MazeNr+1;
  if UserName<>'' then
    begin
    if Cfg.ReadKeyName(MazFN,s) then;
    Insert(' ',s,1);
    i:=1;
    while (Pos(' '+Int2Str(i),s)<>0) and (i<=nMazes) do Inc(i);
    GetNextRoom:=i;
    end;
  end;

Function IsRoomMade(Room: Word): Boolean;
  var s: String;
  begin
  IsRoomMade:=False;
  if UserName<>'' then
    begin
    if Cfg.ReadKeyName(MazFN,s) then;
    Insert(' ',s,1);
    IsRoomMade:=Pos(' '+Int2Str(Room),s)<>0;
    end;
  end;

end.

