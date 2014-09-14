(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

unit Misc; { for " The Quest of Kwirk's Castle " }
{ $D-,L-}

interface

uses Dos, Crt,{MyCrt,} ptcGraph, Compat,
     {GemBase, GemInit, Pum,} Mouse, //KbdRep,
     {vStrSubs, Num2Str, StdSubs,} DefBase{, Timer};

Procedure Init1;
Procedure Init2;
Procedure Init3;
Procedure InitError(s: String; Title,Help: Boolean);
Function LoadImages(FN: PathStr): Boolean;
Function LoadMazes(FN: PathStr): Boolean;
Function SaveMazes(FN: PathStr): Boolean;
Function MazeMenue(FN0: PathStr): PathStr;
Const MazeNr: integer = 0;
Function RoomMenue(Room0: integer): integer;
Procedure WriteHelpKey;
Procedure OutTextXYs(x,y: LongInt; s: String; c2,c1: integer);
Procedure ClearHelpKey;
Procedure WriteQuestMakerTitle;
Procedure WriteTitle;
Procedure WriteLevel(s: String);
Procedure WriteMazeNr(n: integer);
Procedure WriteAttempt(t: integer);
Procedure WriteTime1(t: LongInt);
Procedure WriteTime2(t: LongInt);
Function CheckMazeP(var Maze: MazeType; y,x: integer; RandWert: integer): integer;
Function CheckMaze(var Maze: MazeType; Compare: CharSet; y,x: integer; RandWert: integer): integer;
Procedure KorregMaze(var Maze: MazeType);
Function Char2ImgNr(c: Char): integer;
Function Char2ImgPtr(c: Char): Pointer;
Procedure SetMazeImage(var Maze: MazeType; x,y: integer);
Procedure SetImgMaze(var Maze: MazeType);
Procedure DrawImage(ix,iy: integer; Img: Pointer; dx,dy: integer; PutMode: integer);
Procedure DrawMazeImage(var Maze: MazeType; ix,iy: integer);
Procedure DrawField(var M: MazeType);
Procedure ShowHelp;
Function CalcDoorCenter(var M: MazeType; x,y: integer; var DoorX,DoorY: integer): Boolean;
Procedure CalcDoorWings(var M: MazeType; x,y: integer; var re,ob,li,un: Boolean);
Procedure MoveDoor(var Maze: MazeType; x,y: integer; ccw: Boolean; DrawDoor: Boolean);
Procedure XPum(var a; Size: Word; Lines,OneTime:integer; var y,Offset: integer);
Procedure GotoFldXY(x,y: Integer);
Procedure AddRoomMade(Room: Word);
Function  GetNextRoom: Word;
Function  IsRoomMade(Room: Word): Boolean;

{.$I KbdCodes.Pas}
Function KwirkReadKey: Word;
Function KwirkGetKey: Word;
Function KwirkKeyPressed: Boolean;
const LastKey: Word = 0;
Function LastChar: Char;
Procedure WaitKey;
Procedure ClearKbdBuffer;
Procedure ClearKbdRepeat;

Function CheckTimeout(Tol: LongInt): Boolean;

implementation

Procedure InitError(s: String; Title,Help: Boolean);
  begin
  if TextModeAtProgrammStart>=0 then TextMode(TextModeAtProgrammStart);
  if not Title then begin TextColor(LightGray); TextBackground(Black) end;
  if Title then
    begin
    writeln('The Quest of Kwirk''s Castle             PC-Version by Joe M.  1991');
    writeln;
    end;
  Writeln(s);
  if Help then
    begin
    writeln;
    writeln('Enter  Kwirk ?  for help');
    end;
  Halt;
  end;

Procedure Init1;
  begin
  {$ifdef enable}
  if sConfig.Screen1=Detect then
    begin
    DetectGraph(sConfig.Screen1,sConfig.Res1);
    if sConfig.Screen1=Cga then sConfig.Res1:=CgaC1;
    if sConfig.Screen1=Ega64 then sConfig.Res1:=Ega64Lo;
    end;
  if (sConfig.Screen1=Vga)      and (sConfig.Res1=VgaHi)      then ImgFN:='KwirkVga.Img' else
  if (sConfig.Screen1=IBM8514)  then ImgFN:='KwirkVga.Img' else
{  if (sConfig.Screen1=VESA16)   then ImgFN:='KwirkVga.Img' else{}
  if (sConfig.Screen1=Ega)      and (sConfig.Res1=EgaHi)      then ImgFN:='KwirkEga.Img' else
  if (sConfig.Screen1=Ega)      and (sConfig.Res1=EgaLo)      then ImgFN:='KwirkELo.Img' else
  if (sConfig.Screen1=MCga)     and (sConfig.Res1=MCgaHi)     then ImgFN:='KwirkMCg.Img' else
  if (sConfig.Screen1=HercMono) and (sConfig.Res1=HercMonoHi) then ImgFN:='KwirkHrc.Img' else
  if (sConfig.Screen1=Cga)      and (sConfig.Res1=CgaHi)      then ImgFN:='KwirkCHi.Img' else
  if (sConfig.Screen1=Cga)      and (sConfig.Res1 in [CgaC0..CgaC3]) then ImgFN:='KwirkCga.Img' else
    if not ParamHelp then InitError('Sorry, graphics-card or graphics-mode not supported in this version.',True,True);
  if QuestMakerFlag and (sConfig.Screen1 in [CGA,MCGA]) and (sConfig.Res1<CgaHi) then
    InitError('Need high resolution to run the QuestMaker.',True,True);
  {$endif}
  end;

Procedure Init2;
  var       i: integer;
       MemErr: Boolean;
  begin
  i:=1; MemErr:=False;
  while (i<=nImages) and not MemErr do
    begin
    MemErr:={$ifndef enable}False{$else}MaxAvail<3*SizeOf(ImgType){$endif};
    if not MemErr then New(Img[i]);
    Inc(i);
    end;
  if MemErr then InitError('To few memory to load the Images !',False,False);
  end;

Procedure Init3;
  var xasp,yasp: word;
      MaxX,MaxY: integer;
            i,j: LongInt;
          t0,t1: Real;
  begin
  {$ifdef enable}
  ChgPalette:=False;
  if not TextKwirk and not InitGem('') then Halt;
  KwirkXSpeed:=MS2Tick(Round(100/ImgXsize));
  KwirkYSpeed:=MS2Tick(Round(100/ImgYsize));
  JumpSpeed  :=MS2Tick(40);
  WaterSpeed :=MS2Tick(150);
  JoeMSpeed  :=MS2Tick(400);

  if KwirkSpeed<0 then KwirkSpeed:=0;
  if KwirkSpeed>0.9 then KwirkSpeed:=0.9;
  if KwirkSpeed=0 then
    begin
    QuickMoving:=True;
    KwirkBumpSteps:=0
    end
  else begin
    KwirkXSpeed:=MS2Tick(Round(1000*KwirkSpeed/ImgXsize));
    KwirkYSpeed:=MS2Tick(Round(1000*KwirkSpeed/ImgYsize));
    end;
  {$endif}
  end;

Procedure GetImg(var F: File; i: integer);
  var x1,y1,
      x2,y2,
       s,s1: integer;
  begin
  x1:=1;
  y1:=1;
  x2:=ImgXsize;
  y2:=ImgYsize;
  {s:=ImageSize(x1,y1,x2,y2);}
  s1:=(FileSize(F) div nImages);
  BlockRead(F,Img[i]^,s1);
  end;

Function LoadImages(FN: PathStr): Boolean;
  var F: File;
      i: integer;
    x,y: word;
  begin
  InOutRes:=0;
  Assign(F,FN); Reset(F,1);
  if InOutRes=0 then
    begin
    BlockRead(F,x,2);
    BlockRead(F,y,2);
    end;
  if InOutRes=0 then
    begin
    ImgXsize:=x+1;
    ImgYsize:=y+1;
    end;
  Reset(F,1);
  i:=1;
  while (InOutRes=0) and not Eof(F) and (i<=nImages) do
    begin GetImg(F,i); Inc(i) end;
  Close(F);
  LoadImages:=IOResult=0
  end;

Function LoadMazes(FN: PathStr): Boolean;
  var  T: Text;
    s,s1: String;
       l: Byte absolute s;
      l1: Byte absolute s1;
       i: integer;
      ln: integer;
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
            if Copy(s,i,1)='P' then s[i]:=' ';  { Pftzen sind nur im P-Array vermerkt }
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
    x,y: integer;
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
       i: integer;
      ln: integer;
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

Procedure SetTextStyle(Font,Direction,CharSize: Word);
  var m,d: integer;
  begin
  SetUserCharSize(CharSize,1,CharSize,1);
  SetUserCharSize(1,2,1,4);
  if (GetMaxY<200) and (CharSize<=1) then begin PtcGraph.SetTextStyle(DefaultFont,Direction,1); exit end;
  Case CharSize of
    1: begin m:=3; d:=5 end;
    2: begin m:=2; d:=3 end;
    3: begin m:=3; d:=4 end;
    4: begin m:=1; d:=1 end;
    end;
  SetUserCharSize(m*((GetMaxX+1) div 20),d*32,m*((GetMaxY+1) div 20),d*24);
  PtcGraph.SetTextStyle(Font,Direction,0);
  end;

Function VgaX(x: LongInt): LongInt; begin VgaX:=(x*(GetMaxX+1)) div 640 end;
Function VgaY(y: LongInt): LongInt; begin VgaY:=(y*(GetMaxY+1)) div 480 end;
Procedure Bar(x1,y1,x2,y2: integer);
  begin PtcGraph.Bar(VgaX(x1),VgaY(y1),VgaX(x2),VgaY(y2)) end;

Procedure ClrOutTextXY(x,y: LongInt; s: String);
  var  ti: TextSettingsType;
    tw,th: integer;
        i: integer;
  begin
  if x>500 then
    begin
    x:=GetMaxX-(((639-x)*(GetMaxX+1)) div 640);
    if (GetMaxX<320) and (x<315) then Dec(x,20);
    {$ifdef enable}
    if (iConfig.Screen1=HercMono) and (x<766) then Dec(x,40);
    {$endif}
    end;
  y:=VgaY(y);
  tw:=TextWidth(s); th:=TextHeight(s);
  GetTextSettings(ti);
  {if ti.Font<>DefaultFont then Inc(th,2);}
  if ti.Direction=VertDir then begin i:=tw; tw:=th; th:=i end;
  case ti.Horiz of
      LeftText:;
    CenterText: x:=x- tw div 2;
     RightText: x:=x-tw;
    end;
  case ti.Vert of
       TopText:;
    CenterText: y:=y- th div 2;
    BottomText: y:=y-th;
    end;
  SetFillStyle(SolidFill,Black);
  PtcGraph.Bar(x,y+1*ord(ti.Font<>DefaultFont),
            x+tw+4*ord(ti.Font<>DefaultFont),y+th+5*ord(ti.Font<>DefaultFont));
  end;

Procedure OutTextXY(x,y: LongInt; s: String);
  begin
  if x>500 then
    begin
    x:=GetMaxX-(((639-x)*(GetMaxX+1)) div 640);
    if (GetMaxX<320) and (x<315) then Dec(x,20);
    {$ifdef enable}
    if (iConfig.Screen1=HercMono) and (x<765) then Dec(x,40);
    {$endif}
    end;
  PtcGraph.OutTextXY(x,VgaY(y),s);
  end;

Procedure OutTextXYs(x,y: LongInt; s: String; c2,c1: integer);
  begin
  if x>500 then
    begin
    x:=GetMaxX-(((639-x)*(GetMaxX+1)) div 640);
    if (GetMaxX<320) and (x<315) then Dec(x,20);
    {$ifdef enable}
    if (iConfig.Screen1=HercMono) and (x<765) then Dec(x,40);
    {$endif}
    end;
  y:=VgaY(y);
  SetColor(c1); PtcGraph.OutTextXY(x+1,y+1,s);
  SetColor(c2); PtcGraph.OutTextXY(x,y,s);
  end;

Procedure XPum(var a; Size: Word; Lines,OneTime:integer; var y,Offset: integer);
  Type refStr = ^String;
  var    ti: TextSettingsType;
          i: integer;
         sp: refStr;
    w,w1,l1: integer;
  begin
  if Lines=0 then exit;
  SetTextJustify(LeftText,TopText);
  {$ifdef enable}
  if DefaultSpeedFont then SetTextDefault else SetTextStyle(TriplexFont,HorizDir,1);
  {$endif}
  GetTextSettings(ti);
  if ti.Font<>DefaultFont then
    begin
    w1:=0; l1:=1; sp:=Addr(a);
    for i:=0 to Lines do
      begin
      w:=TextWidth(sp^);
      if w>w1 then begin w1:=w; l1:=length(sp^) end;
      sp:=Pointer(LongInt(sp)+Size);
      end;
    {$ifdef enable}
    CHight:=TextHeight('Mg')+5; LnTab:=cHight+5;
    if GetMaxY<200 then begin Dec(LnTab,3); Dec(cHight,5) end;
    cWidth:=(w1 div l1)+1; RowTab:=cWidth;
    {$endif}
    end;
  {$ifdef enable}
  OneTimeLines:=OneTime;
  XPopUpMenue(a,Size,Lines,10050,10050,y,Offset,True,True,False,True,False,False);
  OneTimeLines:=32;                            { Pum-Default    }
  if not DefaultSpeedFont then SetTextDefault  { Gem cWidth ... }
  {$endif}
  end;

Const MaxMazeMenEntrys = 100;
Type  MazeMenEntryType = record FN,Title: PathStr end;
        MazeMenArrType = Array[0..MaxMazeMenEntrys+1] of MazeMenEntryType;

Procedure MazeMenueSort(var a: MazeMenArrType; n: integer);
  procedure QuickSort(L, R: Integer);
    var  I,J: Integer;
         X,Y: MazeMenEntryType;
    begin
    I:=L;
    J:=R;
    X:=a[(L+R) div 2];
    repeat
      while a[I].FN<X.FN do Inc(I);
      while X.FN<a[J].FN do Dec(J);
      if I<=J then
        begin
        Y:=a[I];
        a[I]:=a[J];
        a[J]:=Y;
        Inc(I);
        Dec(J)
        end
    until I>J;
    if L<J then QuickSort(L,J);
    if I<R then QuickSort(I,R)
    end;
  begin
  if 1<n then QuickSort(1,n)
  end;

Const  MazePumOffs: integer = 1;
Function MazeMenue(FN0: PathStr): PathStr;
  Type EntryType = record FN,Title: PathStr end;
  var     d: MazeMenArrType;
      i,j,n: integer;
         sr: SearchRec;
          T: Text;
          s: String;
          l: Byte absolute s;
  begin
  {$ifdef enable}
  vUpcaseStr(FN0);
  {$endif}
  FN0:=Copy(FN0,1,Pos('.',FN0)-1);
  FindFirst('*.Maz',Archive,sr);
  n:=0;
  d[n].Title:='Table of Contents';
  while (DosError=0) and (n<MaxMazeMenEntrys) do
    begin
    Inc(n);
    d[n].FN:=copy(sr.Name,1,Pos('.',sr.Name)-1);
    Assign(T,sr.Name); Reset(T);
    ReadLn(T,s);
    s:=Copy(s,2,l-2); if l>MaxMazeNameLen then l:=MaxMazeNameLen;
    d[n].Title:=s;
    Close(T);
    FindNext(sr);
    end;
  if n=0 then
    begin
    CloseGraph;
    InitError('no Maze-Files found !',False,False);
    end;
  MazeMenueSort(d,n);
  if QuestMakerFlag then begin Inc(n); d[n].FN:=''; d[n].Title:='[ new Quest ]' end;
  i:=MazeNr; if (i<1) or (i>n) then i:=1;
  for j:=1 to n do
    begin
    {$ifdef enable}
    vUpCaseStr(d[j].FN);
    {$endif}
    if FN0=d[j].FN then i:=j;
    end;
  XPum(d[0].Title,SizeOf(EntryType),n,6,i,MazePumOffs);
  i:=abs(i); MazeNr:=i;
  if i=0 then MazeMenue:='' else MazeMenue:=d[i].FN+'.Maz';
  end;

Const  RoomPumOffs: integer = 1;
Function RoomMenue(Room0: integer): integer;
  var   i,n: integer;
          d: Array[0..MaxMazes] of MazeNameStr;
  begin
  d[0]:=QuestName;
  for i:=1 to nMazes do d[i]:=Mazes[i].Name;
  n:=nMazes;
  if QuestMakerFlag and (nMazes<MaxMazes) then begin Inc(n); d[n]:='[ new Room ]' end;
  i:=Room0;
  XPum(d,SizeOf(MazeNameStr),n,10,i,RoomPumOffs);
  RoomMenue:=abs(i);
  end;

Procedure WriteHelpKey;
  var c1,c2: Byte;
  begin
  if TextKwirk then
    begin
    TextAttr:=Yellow+Cyan*16;
   {GotoXY(65,20); Write('  Help on Keys  ');}
    GotoXY(62,19); Write('** Tastenhilfe: **');
    c1:=White+Cyan*16;
    c2:=LightCyan+Cyan*16;
   {GotoXY(65,20); TextAttr:=c1; Write(' 2,4,6,8 '); TextAttr:=c2; Write(' Move  ');
    GotoXY(65,21); TextAttr:=c1; Write(' Enter ');   TextAttr:=c2; Write('ChgKwirk ');
    GotoXY(65,22); TextAttr:=c1; Write(' <-- ');     TextAttr:=c2; Write('Retry Room ');
    GotoXY(65,23); TextAttr:=c1; Write(' +/- ');     TextAttr:=c2; Write('Next Room  ');
    GotoXY(65,24); TextAttr:=c1; Write(' ^Q  ');     TextAttr:=c2; Write('Quit Game  ');}
    GotoXY(62,20); TextAttr:=c1; Write('2,4,6,8 '); TextAttr:=c2; Write('Bewegen   ');
    GotoXY(62,21); TextAttr:=c1; Write('^N  '); TextAttr:=c2; Write('Naechste Figur');
    GotoXY(62,22); TextAttr:=c1; Write('^Z  '); TextAttr:=c2; Write('Raum nochmal  ');
    GotoXY(62,23); TextAttr:=c1; Write('+/- '); TextAttr:=c2; Write('Naechster Raum');
    GotoXY(62,24); TextAttr:=c1; Write('^Q  '); TextAttr:=c2; Write('Spiel beenden ');
    end
  else begin
    if GetMaxX<320 then exit;
    c1:=DarkGray; c2:=LightGray; if GetMaxColor<4 then c1:=GetMaxColor-1;
    SetTextJustify(LeftText,BottomText);
    SetTextStyle(TriplexFont,HorizDir,2);
    OutTextXYs(541,474,'F1 Help',c1,c2);
    end;
  end;

Procedure ClearHelpKey;
  begin
  if TextKwirk then
    begin
    TextAttr:=0;
    GotoXY(73,24);
    Write('       ');
    end
  else begin
    if GetMaxX<320 then exit;
    SetFillStyle(SolidFill,Black);
    {Bar(540,455,614,479);}
    SetTextJustify(LeftText,BottomText);
    SetTextStyle(TriplexFont,HorizDir,2);
    ClrOutTextXY(541,474,'F1 Help');
    end;
  end;

Procedure WriteQuestMakerTitle;
  var c1,c2: Byte;
  begin
  c1:=DarkGray; c2:=white; if GetMaxColor<4 then c1:=GetMaxColor-1;
  SetTextJustify(LeftText,BottomText);
  SetTextStyle(GothicFont,HorizDir,4);
  OutTextXYs(180,50,'Kwirk ',c1,c2);
  SetTextStyle(GothicFont,HorizDir,2);
  OutTextXYs(260,50,'''s',c1,c2);
  SetTextStyle(GothicFont,HorizDir,4);
  OutTextXYs(300,50,'QuestMaker',c1,c2);
  end;

Procedure WriteTitle;
  var c1,c2: Byte;
  begin
  if TextKwirk then
    begin
    TextAttr:=Yellow+Brown*16;
    GotoXY(65,1); Write('                ');
    GotoXY(65,2); Write('  The Quest of  ');
    GotoXY(65,3); Write('                ');
    GotoXY(65,4); Write(' Kwirk''s Castle ');
    GotoXY(65,5); Write('                ');
    GotoXY(65,6); Write(' by Joe M. 1991 ');
    GotoXY(65,7); Write('                ');
    end
  else begin
    c1:=DarkGray; c2:=white; if GetMaxColor<4 then c1:=GetMaxColor-1;
    SetTextJustify(LeftText,BottomText);
    SetTextStyle(GothicFont,HorizDir,2);
    OutTextXYs(550,20,'  The',c1,c2);
    SetTextStyle(GothicFont,HorizDir,4);
    OutTextXYs(550,45,'Quest',c1,c2);
    SetTextStyle(GothicFont,HorizDir,2);
    OutTextXYs(550,68,'   of',c1,c2);
    SetTextStyle(GothicFont,HorizDir,4);
    OutTextXYs(540,100,'Kwirk ',c1,c2);
    SetTextStyle(GothicFont,HorizDir,2);
    OutTextXYs(620,100,'''s',c1,c2);
    SetTextStyle(GothicFont,HorizDir,4);
    OutTextXYs(550,125,'Castle',c1,c2);
    end;
  end;

Procedure WriteLevel(s: String);
  Const LastLevel: String = ' ';
  begin
  if TextKwirk then
    begin
    TextAttr:=White+Brown*16;
    GotoXY(1,20);
    Write('                                                            ');
    GotoXY(1,20);
    Write(s);
    end
  else begin
    SetFillStyle(SolidFill,Black);
    SetTextJustify(RightText,TopText);
    SetTextStyle(TriplexFont,VertDir,1);
    {Bar(610,148,639,479);}
    ClrOutTextXY(635,150,LastLevel);
    OutTextXYs(635,150,s,Black,LightRed);
    end;
  LastLevel:=s;
  end;

Procedure WriteMazeNr(n: integer);
  begin
  if TextKwirk then
    begin
    TextAttr:=White;
    GotoXY(66,10);
   {Write('Room ',n,' ');}
    Write('Raum ',n,' ');
    if IsRoomMade(n) then Write('û') else Write(' ');
    Write(' ');
    end
  else begin
    SetColor(Yellow);
    SetFillStyle(SolidFill,Black);
    SetTextJustify(LeftText,TopText);
    SetTextStyle(TriplexFont,HorizDir,1);
    OutTextXYs(540,160,'Room',Black,Yellow);
    {Bar(596,162,620,180);}
    ClrOutTextXY(596,160,Copy(Int2StrL(n,2), 1, 2));
    OutTextXYs(596,160,Int2Str(n),Black,Yellow);
    end;
  end;

Procedure WriteAttempt(t: integer);
  begin
  if TextKwirk then
    begin
    TextAttr:=White;
    GotoXY(66,11);
   {Write('Attm ',t,' ');}
    Write('Versuch ',t,' ');
    end
  else begin
    SetFillStyle(SolidFill,Black);
    SetTextJustify(LeftText,TopText);
    SetTextStyle(TriplexFont,HorizDir,1);
    OutTextXYs(540,180,'Attm',Black,Yellow);
    {Bar(590,182,620,200);}
    ClrOutTextXY(590,180,Int2StrL(t,2));
    OutTextXYs(590,180,Int2Str(t),Black,Yellow);
    end;
{  TextAttr:=DarkGray;
  GotoXY(66,12);
  Write('Mem=',MemAvail,' ');
  GotoXY(66,13);
  Write('Max=',MaxAvail,' ');}
  end;

Procedure GetTimeStr(t: LongInt; var ts: String);
  var h: String[3];
      m: String[3];
      s: String[3];
  begin
  h:=Int2Str(t div 3600);
  m:=Int2Str((t div 60) mod 60);
  s:=Int2Str(t mod 60);
  if Length(h)<2 then Insert(' ',h,1);
  if Length(m)<2 then Insert('0',m,1);
  if Length(s)<2 then Insert('0',s,1);
  ts:=h+':'+m+':'+s;
  end;

Procedure WriteTime1(t: LongInt);
  var s: String;
  begin
  GetTimeStr(t,s);
  if TextKwirk then
    begin
    TextAttr:=White;
    GotoXY(66,14);
   {Write('Time  ',s);}
    Write('Zeit  ',s);
    end
  else begin
    SetColor(Cyan);
    SetTextJustify(LeftText,TopText);
    if DefaultSpeedFont then SetTextStyle(DefaultFont,HorizDir,1) else SetTextStyle(TriplexFont,HorizDir,1);
    OutTextXY(540,220,'Time');
    ClrOutTextXY(540,240,s);
    OutTextXY(540,240,s);
    end;
  end;

Procedure WriteTime2(t: LongInt);
  var s: String;
  begin
  GetTimeStr(t,s);
  if TextKwirk then
    begin
    TextAttr:=White;
    GotoXY(66,15);
   {Write('Total ',s);}
    Write('Gesamt',s);
    end
  else begin
    SetColor(Cyan);
    SetTextJustify(LeftText,TopText);
    if DefaultSpeedFont then SetTextStyle(DefaultFont,HorizDir,1) else SetTextStyle(TriplexFont,HorizDir,1);
    OutTextXY(540,270,'Total');
    ClrOutTextXY(540,290,s);
    OutTextXY(540,290,s);
    end;
  end;

Function CheckMazeP(var Maze: MazeType; y,x: integer; RandWert: integer): integer;
  begin
  if (x<1) or (x>Maze.xs) or (y<1) or (y>Maze.ys) then begin CheckMazeP:=RandWert; exit end;
  if Maze.P[y,x] then CheckMazeP:=1 else CheckMazeP:=0;
  end;
Function CheckMaze(var Maze: MazeType; Compare: CharSet; y,x: integer; RandWert: integer): integer;
  begin
  if (x<1) or (x>Maze.xs) or (y<1) or (y>Maze.ys) then begin CheckMaze:=RandWert; exit end;
  if Maze.M[y,x] in Compare then CheckMaze:=1 else CheckMaze:=0;
  end;

Procedure KorregMaze(var Maze: MazeType);
  var x,y,i: integer;
  begin
  Maze.nKwirks:=0;
  for x:=1 to Maze.xs do
    for y:=1 to Maze.ys do
      begin
      if Maze.M[y,x]='*' then { Trdrehpunkt automatisch ermitteln }
        begin
        i:=1*CheckMaze(Maze,['D','Ä','µ'],y  ,x+1,0)+  { rechts }
           2*CheckMaze(Maze,['D','³','Ò'],y-1,x  ,0)+  { oben   }
           4*CheckMaze(Maze,['D','Ä','Æ'],y  ,x-1,0)+  { links  }
           8*CheckMaze(Maze,['D','³','Ð'],y+1,x  ,0);  { unten  }
        case i of
          12: Maze.M[y,x]:='»';
           9: Maze.M[y,x]:='É';
           3: Maze.M[y,x]:='È';
           6: Maze.M[y,x]:='¼';
          14: Maze.M[y,x]:='¹';
          13: Maze.M[y,x]:='Ë';
          11: Maze.M[y,x]:='Ì';
           7: Maze.M[y,x]:='Ê';
          10: Maze.M[y,x]:='º';
           5: Maze.M[y,x]:='Í';
           1: Maze.M[y,x]:='Ã';
           2: Maze.M[y,x]:='Á';
           4: Maze.M[y,x]:='´';
           8: Maze.M[y,x]:='Â';
          else Maze.M[y,x]:='Î';
          end; {endcase}
        end
      else if Maze.M[y,x]='³' then { senkrechten Trflgel automatisch ermitteln }
        begin
        if CheckMaze(Maze,['*','»','É','¹','Ë','Ì','º','Î','Â'],y-1,x,0)=1
          then Maze.M[y,x]:='Ð'
          else Maze.M[y,x]:='Ë';
        end
      else if Maze.M[y,x]='Ä' then { waagerechten Trflgel automatisch ermitteln }
        begin
        if CheckMaze(Maze,['*','»','¼','¹','Ë','Ê','Í','Î','´'],y-1,x,0)=1
          then Maze.M[y,x]:='Æ'
          else Maze.M[y,x]:='µ';
        end
      else if Maze.M[y,x]='D' then { Trflgel automatisch ermitteln }
        begin
        if CheckMaze(Maze,['*','»','¼','¹','Ë','Ê','Í','Î','´'],y  ,x+1,0)=1 then Maze.M[y,x]:='Æ' else
        if CheckMaze(Maze,['*','»','É','¹','Ë','Ì','º','Î','Â'],y-1,x  ,0)=1 then Maze.M[y,x]:='Ð' else
        if CheckMaze(Maze,['*','É','È','Ë','Ì','Ê','Í','Î','Ã'],y  ,x-1,0)=1 then Maze.M[y,x]:='µ' else
        if CheckMaze(Maze,['*','È','¼','¹','Ì','Ê','º','Î','Á'],y+1,x  ,0)=1 then Maze.M[y,x]:='Ò' else
           Maze.M[y,x]:=' '
        end
      else if Maze.M[y,x]='B' then { Kiste automatisch ermitteln }
        begin
        i:=1*CheckMaze(Maze,['B','×','¶','Ü','¿','Û','Ý','ß','Ù'],y,  x+1,0)+       { rechts }
           2*CheckMaze(Maze,['B','Ø','Ñ','Ú','Ü','¿','Þ','Û','Ý'],y-1,x  ,0)+       { oben   }
           4*CheckMaze(Maze,['B','×','Ç','Ú','Ü','Þ','Û','À','ß'],y,  x-1,0)+       { links  }
           8*CheckMaze(Maze,['B','Ø','Ï','Þ','Û','Ý','À','ß','Ù'],y+1,x  ,0);       { unten  }
        case i of
           1: Maze.M[y,x]:='Ç';
           2: Maze.M[y,x]:='Ï';
           4: Maze.M[y,x]:='¶';
           8: Maze.M[y,x]:='Ñ';
           5: Maze.M[y,x]:='×';
          10: Maze.M[y,x]:='Ø';
           3: Maze.M[y,x]:='À';
           6: Maze.M[y,x]:='Ù';
           9: Maze.M[y,x]:='Ú';
          12: Maze.M[y,x]:='¿';
          14: Maze.M[y,x]:='Ý';
          13: Maze.M[y,x]:='Ü';
          11: Maze.M[y,x]:='Þ';
           7: Maze.M[y,x]:='ß';
          15: Maze.M[y,x]:='Û';
          else Maze.M[y,x]:='²';
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

Procedure SetTextImage(c: Char; var Cell: CellType);
  var s: ^String;
      a: ^Byte;
  begin
  s:=@Cell.TextKwStr;
  a:=@Cell.TextKwAtr;
  case c of
    'W': begin s^:='±±±'; a^:=Brown+Red*16; end; { Wand   }
    '>': begin s^:='>>>'; a^:=LightMagenta+16*Magenta; end; { Kwirk Ausgangsposition }
    '^': begin s^:='^^^'; a^:=LightMagenta+16*Magenta; end; { Kwirk Ausgangsposition }
    '<': begin s^:='<<<'; a^:=LightMagenta+16*Magenta; end; { Kwirk Ausgangsposition }
    'V': begin s^:='vvv'; a^:=LightMagenta+16*Magenta; end; { Kwirk Ausgangsposition }
    '»': begin s^:='ÍO '; a^:=White+16*LightGray; end; { Tr Drehpunkt }
    'É': begin s^:=' OÍ'; a^:=White+16*LightGray; end; { Tr Drehpunkt }
    'È': begin s^:=' OÍ'; a^:=White+16*LightGray; end; { Tr Drehpunkt }
    '¼': begin s^:='ÍO '; a^:=White+16*LightGray; end; { Tr Drehpunkt }
    '¹': begin s^:='ÍO '; a^:=White+16*LightGray; end; { Tr Drehpunkt }
    'Ë': begin s^:='ÍOÍ'; a^:=White+16*LightGray; end; { Tr Drehpunkt }
    'Ì': begin s^:=' OÍ'; a^:=White+16*LightGray; end; { Tr Drehpunkt }
    'Ê': begin s^:='ÍOÍ'; a^:=White+16*LightGray; end; { Tr Drehpunkt }
    'Í': begin s^:='ÍOÍ'; a^:=White+16*LightGray; end; { Tr Drehpunkt }
    'º': begin s^:=' O '; a^:=White+16*LightGray; end; { Tr Drehpunkt }
    '´': begin s^:='ÍO '; a^:=White+16*LightGray; end; { Tr Drehpunkt }
    'Â': begin s^:=' O '; a^:=White+16*LightGray; end; { Tr Drehpunkt }
    'Ã': begin s^:=' OÍ'; a^:=White+16*LightGray; end; { Tr Drehpunkt }
    'Á': begin s^:=' O '; a^:=White+16*LightGray; end; { Tr Drehpunkt }
    'Î': begin s^:='ÍOÍ'; a^:=White+16*LightGray; end; { Tr Drehpunkt }
    'µ': begin s^:='ÍÍ '; a^:=White+16*LightGray; end; { Trflgel }
    'Ò': begin s^:=' Ò '; a^:=White+16*LightGray; end; { Trflgel }
    'Æ': begin s^:=' ÍÍ'; a^:=White+16*LightGray; end; { Trflgel }
    'Ð': begin s^:=' Ð '; a^:=White+16*LightGray; end; { Trflgel }
    '²': begin s^:='[ð]'; a^:=DarkGray+Cyan*16; end; { Kiste }
    'Ñ': begin s^:='ÚÄ¿'; a^:=DarkGray+Cyan*16; end; { Kiste }
    'Ø': begin s^:='³þ³'; a^:=DarkGray+Cyan*16; end; { Kiste }
    'Ï': begin s^:='ÀÄÙ'; a^:=DarkGray+Cyan*16; end; { Kiste }
    'Ç': begin s^:='[ðð'; a^:=DarkGray+Cyan*16; end; { Kiste }
    '×': begin s^:='ððð'; a^:=DarkGray+Cyan*16; end; { Kiste }
    '¶': begin s^:='ðð]'; a^:=DarkGray+Cyan*16; end; { Kiste }
    '¿': begin s^:='ÄÄ¿'; a^:=DarkGray+Cyan*16; end; { Kiste }
    'Ú': begin s^:='ÚÄÄ'; a^:=DarkGray+Cyan*16; end; { Kiste }
    'À': begin s^:='ÀÄÄ'; a^:=DarkGray+Cyan*16; end; { Kiste }
    'Ù': begin s^:='ÄÄÙ'; a^:=DarkGray+Cyan*16; end; { Kiste }
    'Ý': begin s^:='þþ³'; a^:=DarkGray+Cyan*16; end; { Kiste }
    'Ü': begin s^:='ÄÄÄ'; a^:=DarkGray+Cyan*16; end; { Kiste }
    'Þ': begin s^:='³þþ'; a^:=DarkGray+Cyan*16; end; { Kiste }
    'ß': begin s^:='ÄÄÄ'; a^:=DarkGray+Cyan*16; end; { Kiste }
    'Û': begin s^:='þþþ'; a^:=DarkGray+Cyan*16; end; { Kiste }
    'J': if QuestMakerFlag then begin s^:='<J>'; a^:=Green; end; { Jump Position }
    'M': begin s^:='Joe'; a^:=Green; end;
    'E': begin s^:='JME'; a^:=Green; end;
    'Z': begin s^:='<#>'; a^:=Yellow; end; { lokales Ziel }
    end;
  end;

Function Char2ImgNr(c: Char): integer;
  var f: integer;
  begin
  case c of
    'W': f:=WallFld;   { Wand   }
    '>': f:=MoveRightImg.Img[0];  { Kwirk Ausgangsposition }
    '^': f:=MoveUpImg.   Img[0];  { Kwirk Ausgangsposition }
    '<': f:=MoveLeftImg. Img[0];  { Kwirk Ausgangsposition }
    'V': f:=MoveDownImg. Img[0];  { Kwirk Ausgangsposition }
    '»': f:=DoorEcke1;  { Tr Drehpunkt }
    'É': f:=DoorEcke2;  { Tr Drehpunkt }
    'È': f:=DoorEcke3;  { Tr Drehpunkt }
    '¼': f:=DoorEcke4;  { Tr Drehpunkt }
    '¹': f:=DoorDrei1;  { Tr Drehpunkt }
    'Ë': f:=DoorDrei2;  { Tr Drehpunkt }
    'Ì': f:=DoorDrei3;  { Tr Drehpunkt }
    'Ê': f:=DoorDrei4;  { Tr Drehpunkt }
    'Í': f:=DoorZwei1;  { Tr Drehpunkt }
    'º': f:=DoorZwei2;  { Tr Drehpunkt }
    '´': f:=DoorEins1;  { Tr Drehpunkt }
    'Â': f:=DoorEins2;  { Tr Drehpunkt }
    'Ã': f:=DoorEins3;  { Tr Drehpunkt }
    'Á': f:=DoorEins4;  { Tr Drehpunkt }
    'Î': f:=DoorVier;   { Tr Drehpunkt }
    'µ': f:=DoorWing1;  { Trflgel }
    'Ò': f:=DoorWing2;  { Trflgel }
    'Æ': f:=DoorWing3;  { Trflgel }
    'Ð': f:=DoorWing4;  { Trflgel }
    '²': f:=Box0;       { Kiste }
    'Ñ': f:=BoxSo;      { Kiste }
    'Ø': f:=BoxSm;      { Kiste }
    'Ï': f:=BoxSu;      { Kiste }
    'Ç': f:=BoxWl;      { Kiste }
    '×': f:=BoxWm;      { Kiste }
    '¶': f:=BoxWr;      { Kiste }
    '¿': f:=BoxRO;      { Kiste }
    'Ú': f:=BoxLO;      { Kiste }
    'À': f:=BoxLU;      { Kiste }
    'Ù': f:=BoxRU;      { Kiste }
    'Ý': f:=BoxRe;      { Kiste }
    'Ü': f:=BoxOb;      { Kiste }
    'Þ': f:=BoxLi;      { Kiste }
    'ß': f:=BoxUn;      { Kiste }
    'Û': f:=BoxMi;      { Kiste }
    'J': if QuestMakerFlag then f:=JoeMFld else f:=0; { Jump Position }
    'M': f:=JoeMFld;
    'E': f:=JMEFld;
    'Z': f:=AimFld;     { lokales Ziel }
    else f:=0;
    end;
  Char2ImgNr:=f
  end;

Function Char2ImgPtr(c: Char): Pointer;
  var f: integer;
  begin
  f:=Char2ImgNr(c);
  if f=0 then Char2ImgPtr:=Nil else Char2ImgPtr:=Img[f];
  end;

Procedure SetMazeImage(var Maze: MazeType; x,y: integer);
  var   i,l,m,f: integer;
              c: char;
             cs: CharSet;
    re,ob,li,un: Boolean;
    ro,lo,ru,lu: Boolean;
  Procedure AddLine(Ln: integer);
    begin if l<=MaxLines then begin if f=WallFld then ImgMaze[y,x].Line1[l]:=Ln else ImgMaze[y,x].Line2[l]:=Ln; Inc(l) end end;
  Procedure AddMask(Mk: integer);
    begin if m<=MaxMasks then begin if f=WallFld then ImgMaze[y,x].Mask1[m]:=Mk else ImgMaze[y,x].Mask2[m]:=Mk; Inc(m) end end;
  Function CheckWallWater(y,x: integer): integer;
    var i: integer;
      a,b: Boolean;
    begin
    CheckWallWater:=0;
    if RandRadius then i:=0 else i:=1;
    a:=CheckMaze(Maze,['W'],y,x,i)=1;
    b:=CheckMazeP(Maze,y,x,i)=1;
    if WaterToWall
      then begin if a or b then CheckWallWater:=1 end
      else if f=WallFld then begin if a then CheckWallWater:=1 end
                        else       if b then CheckWallWater:=1
    end;

  begin
  with Maze do if (x<1) or (x>xs) or (y<1) or (y>ys) then exit;
  ImgMaze[y,x].Source1:=0;
  for i:=1 to MaxLines do ImgMaze[y,x].Line1[i]:=0;
  for i:=1 to MaxMasks do ImgMaze[y,x].Mask1[i]:=0;
  ImgMaze[y,x].Source2:=0;
  for i:=1 to MaxLines do ImgMaze[y,x].Line2[i]:=0;
  for i:=1 to MaxMasks do ImgMaze[y,x].Mask2[i]:=0;
  ImgMaze[y,x].TextKwStr:='   ';
  ImgMaze[y,x].TextKwAtr:=0;
  ImgMaze[y,x].TextKwStr2:='   ';
  ImgMaze[y,x].TextKwAtr2:=0;
  l:=1; m:=1;
  c:=Maze.M[y,x];
  f:=Char2ImgNr(c);
  if TextKwirk then
    begin
    SetTextImage(c,ImgMaze[y,x]);
    if Maze.P[y,x] then
      begin
      ImgMaze[y,x].TextKwStr2:='÷÷÷';
      ImgMaze[y,x].TextKwAtr2:=LightBlue+Blue*16;
      end;
    end
  else begin
    ImgMaze[y,x].Source1:=f;
    if Maze.P[y,x] then ImgMaze[y,x].Source2:=WatrFld;
    if (f=WallFld) or Maze.P[y,x] then with ImgMaze[y,x] do
      begin
      re:=CheckWallWater(y  ,x+1)=1;  { rechts }
      ob:=CheckWallWater(y-1,x  )=1;  { oben   }
      li:=CheckWallWater(y  ,x-1)=1;  { links  }
      un:=CheckWallWater(y+1,x  )=1;  { unten  }
      ro:=CheckWallWater(y-1,x+1)=1;  { rechts }
      lo:=CheckWallWater(y-1,x-1)=1;  { oben   }
      lu:=CheckWallWater(y+1,x-1)=1;  { links  }
      ru:=CheckWallWater(y+1,x+1)=1;  { unten  }
      i:=1*ord(re)+2*ord(ob)+4*ord(li)+8*ord(un);
      case i of
         0: begin AddMask(arMask0);   AddLine(arLine0)    end;
         5: begin AddMask(BandMask2); AddMask(BandMask4); AddLine(BandLine2); AddLine(BandLine4) end;
        10: begin AddMask(BandMask1); AddMask(BandMask3); AddLine(BandLine1); AddLine(BandLine3) end;
         1: begin AddMask(arMask2);   AddMask(arMask3);   AddLine(EndLine3) end;
         2: begin AddMask(arMask3);   AddMask(arMask4);   AddLine(EndLine2) end;
         4: begin AddMask(arMask1);   AddMask(arMask4);   AddLine(EndLine1) end;
         8: begin AddMask(arMask1);   AddMask(arMask2);   AddLine(EndLine4) end;
         3: begin AddMask(arMask3);   AddLine(arLine3)    end;
         6: begin AddMask(arMask4);   AddLine(arLine4)    end;
        12: begin AddMask(arMask1);   AddLine(arLine1)    end;
         9: begin AddMask(arMask2);   AddLine(arLine2)    end;
        14: begin AddMask(BandMask1); AddLine(BandLine1)  end;
        13: begin AddMask(BandMask2); AddLine(BandLine2)  end;
        11: begin AddMask(BandMask3); AddLine(BandLine3)  end;
         7: begin AddMask(BandMask4); AddLine(BandLine4)  end;
        end;
      if re and ob and not ro then begin AddMask(irMask3); AddLine(irLine3) end;
      if li and ob and not lo then begin AddMask(irMask4); AddLine(irLine4) end;
      if li and un and not lu then begin AddMask(irMask1); AddLine(irLine1) end;
      if re and un and not ru then begin AddMask(irMask2); AddLine(irLine2) end;
      end;
    end;
  end;

Procedure SetImgMaze(var Maze: MazeType);
  var x,y: integer;
  begin
  for x:=1 to Maze.xs do
    for y:=1 to Maze.ys do
      SetMazeImage(Maze,x,y);
  end;

Procedure DrawImage(ix,iy: integer; Img: Pointer; dx,dy: integer; PutMode: integer);
  var x,y,i: integer;
  begin
  if TextKwirk then
    begin
    if (Img=Nil) and (dx=0) and (dy=0) then
      begin
      TextAttr:=0;
      GotoFldXY(ix,iy);
      Write('   ');
      end;
    end
  else begin
    IncMouseHide;
    x:=(ix-1)*ImgXsize+dx+MazeXoffs;
    y:=(iy-1)*ImgYsize+dy+MazeYoffs;
    if Img=Nil
      then begin
        if PutMode=CopyPut then
          begin
          SetFillStyle(SolidFill,Black);
          PtcGraph.Bar(x,y,x+ImgXsize-1,y+ImgYsize-1);
          end;
        end
      else PutImage(x,y,Img^,PutMode);
    DecMouseHide
    end;
  end;

Procedure DrawMazeImage(var Maze: MazeType; ix,iy: integer);
  var x,y,i: integer;
    PutMode: integer;
  begin
  with Maze do if (ix<1) or (ix>xs) or (iy<1) or (iy>ys) then exit;
  if TextKwirk then
    begin
    GotoFldXY(ix,iy);
    if (ImgMaze[iy,ix].TextKwStr='   ') and (ImgMaze[iy,ix].TextKwStr2<>'   ') then
      begin
      TextAttr:=ImgMaze[iy,ix].TextKwAtr2;
      Write(ImgMaze[iy,ix].TextKwStr2);
      end
    else begin
      TextAttr:=ImgMaze[iy,ix].TextKwAtr;
      Write(ImgMaze[iy,ix].TextKwStr);
      end;
    end
  else begin
    if (iy=9) and (ix=17) then
      begin
      IncMouseHide;
      DecMouseHide;
      end;
    IncMouseHide;
    x:=(ix-1)*ImgXsize+MazeXoffs;
    y:=(iy-1)*ImgYsize+MazeYoffs;

    if (ImgMaze[iy,ix].Source2>0) and ((ImgMaze[iy,ix].Source1=0) or QuestMakerFlag) then
      begin
      PutImage(x,y,Img[ImgMaze[iy,ix].Source2]^,CopyPut);
      if EckenRadius then
        begin
        i:=1;
        while (i<=MaxMasks) and (ImgMaze[iy,ix].Mask2[i]>0) do
          begin PutImage(x,y,Img[ImgMaze[iy,ix].Mask2[i]]^,AndPut); Inc(i) end;
        i:=1;
        while (i<=MaxLines) and (ImgMaze[iy,ix].Line2[i]>0) do
          begin PutImage(x,y,Img[ImgMaze[iy,ix].Line2[i]]^,OrPut); Inc(i) end;
        end
      end;

    if ImgMaze[iy,ix].Source1>0 then
      begin
      if QuestMakerFlag and (ImgMaze[iy,ix].Source2>0) then PutMode:=OrPut else PutMode:=CopyPut;
      PutImage(x,y,Img[ImgMaze[iy,ix].Source1]^,PutMode);
      if EckenRadius then
        begin
        i:=1;
        while (i<=MaxMasks) and (ImgMaze[iy,ix].Mask1[i]>0) do
          begin PutImage(x,y,Img[ImgMaze[iy,ix].Mask1[i]]^,AndPut); Inc(i) end;
        i:=1;
        while (i<=MaxLines) and (ImgMaze[iy,ix].Line1[i]>0) do
          begin PutImage(x,y,Img[ImgMaze[iy,ix].Line1[i]]^,OrPut); Inc(i) end;
        end
      end;

    if ((ImgMaze[iy,ix].Source1=0) and (ImgMaze[iy,ix].Source2=0)) then
      begin
      SetFillStyle(SolidFill,Black);
      PtcGraph.Bar(x,y,x+ImgXsize-1,y+ImgYsize-1);
      end;
    DecMouseHide;
    end;
  end;

Procedure DrawField(var M: MazeType);
  var x,y: integer;
    xs,ys: integer;
        i: integer;
  begin
  IncMouseHide;
  {ClearDevice;}
  if TextKwirk and AnsiVideo then
    begin
    for y:=1 to M.ys do
      for x:=1 to M.xs do
        DrawMazeImage(M,x,y);
    end
  else begin
    for x:=1 to M.xs do
      for y:=1 to M.ys do
        DrawMazeImage(M,x,y);
    end;
  if TextKwirk then
    begin
    TextAttr:=White+Brown*16;
    x:=(60-Length(M.Name)) div 2 +1;
    if x<1 then x:=1;
    GotoXY(1,1);
    Write('                                                            ');
    GotoXY(x,1);
    Write(M.Name);
    end
  else begin
    SetColor(Black);
    SetTextJustify(CenterText,TopText);
    SetTextStyle(GothicFont,HorizDir,3);
    OutTextXYs((M.xs*ImgXsize) div 2 +MazeXoffs,MazeYoffs,M.Name,Black,DarkGray);
    end;
  DecMouseHide
  end;

Procedure ShowHelp;
  Const xs=440; ys=340;  { Ges. Box }
        xo=-15; yo=-90;  { Abstand v. Box zum Text     }
        tt=50;           { Y-Abstand v. Titel zum Text }
  var xp: integer;       { f. Titel }
      yp: integer;
      x : integer;       { f. Text  }
      y : integer;
  Procedure HelpTitle;
    begin
    SetFillStyle(SolidFill,DarkGray);  Bar(x+xo,y+yo,x+xo+xs,y+yo+ys);
    SetTextJustify(LeftText,BottomText);
    SetTextStyle(GothicFont,HorizDir,2);
    OutTextXYs(xp,yp,'The',Black,LightGray);
    OutTextXYs(xp+128,yp,'of',Black,LightGray);
    OutTextXYs(xp+238,yp,'''s',Black,LightGray);
    SetTextStyle(GothicFont,HorizDir,4);
    OutTextXYs(xp+42,yp,'Quest',Black,LightGray);
    OutTextXYs(xp+158,yp,'Kwirk',Black,LightGray);
    OutTextXYs(xp+266,yp,'Castle',Black,LightGray);
    end;

  Procedure ShowQMakeHelp;
    begin
    SetTextStyle(TriplexFont,HorizDir,1); SetColor(Black);
    OutTextXY(x,y+ 00,'Use the Mouse to design the Room.');
    OutTextXY(x,y+ 30,'Press P to Play.');
    OutTextXY(x,y+ 60,'Press F2 to save your changes.');
    OutTextXY(x,y+ 90,'Press F4 to save and quit.');
    OutTextXY(x,y+120,'Press Esc to get the room menue');
    OutTextXY(x+90,y+145,'(without saving).');
    OutTextXYs(x+3,y+230,'Enter  -  back to the QuestMaker',Black,LightGray);
    WaitKey;
    end;

  begin
  if GetMaxX<320 then exit;
  IncMouseHide;
  {$ifdef enable}
  if iConfig.Screen1=HercMono then begin xp:=65; x:=30 end else begin xp:=120; x:=85 end;
  {$endif}
  yp:=110; y:=160;
  if not QuestMakerFlag then ClearHelpKey;
  SetFillStyle(SolidFill,LightGray);
  if GetMaxColor<4 then SetFillStyle(SolidFill,GetMaxColor-1);
  Bar(x+xo+20,y+yo+20,x+xo+xs+20,y+yo+ys+20);

  HelpTitle;
  if QuestMakerFlag then ShowQMakeHelp
    else begin
      SetTextStyle(TriplexFont,HorizDir,1); SetColor(Black);
      OutTextXY(x,y+00,'Use the CURSORKEYS to move the Kwirk.');
      OutTextXY(x,y+30,'Try to enter the staircase.');
      OutTextXY(x,y+60,'Move a box completely into the water-puddle');
      OutTextXY(x,y+80,'to remove both box and water.');
      OutTextXY(x,y+110,'Use the BACKSPACE key to retry if you think');
      OutTextXY(x,y+130,'that you are in a deadlock, use the TAB key');
      OutTextXY(x,y+150,'to skip a room.');
      OutTextXYs(x+3,y+230,'ESC back to the game  -  ENTER next page',Black,LightGray);
      WaitKey;

      if LastKey<>Escap then begin
      SetFillStyle(SolidFill,DarkGray); Bar(x+xo,y-tt+10,x+xo+xs,y+yo+ys-tt);
      SetTextStyle(TriplexFont,HorizDir,1); SetColor(Black);
      OutTextXY(x,y+00,'If there are more than one Kwirk in a room,');
      OutTextXY(x,y+20,'use the ENTER key to switch your control to');
      OutTextXY(x,y+40,'the next Kwirk. You have to move all Kwirks');
      OutTextXY(x,y+60,'to the staircase.');
      OutTextXY(x,y+100,'Use the F3 key to to stop the programm');
      OutTextXY(x,y+120,'immediately (e.g. if your boss suddenly enter');
      OutTextXY(x,y+140,'your office). While your are handling a');
      OutTextXY(x,y+160,'menue use the ESC key to abort the menue');
      OutTextXY(x,y+180,'function.');
      WaitKey;

      if LastKey<>Escap then begin
      SetFillStyle(SolidFill,DarkGray); Bar(x+xo,y-tt+10,x+xo+xs,y+yo+ys-tt);
      SetTextStyle(TriplexFont,HorizDir,1); SetColor(Black);
      OutTextXY(x,y+00,'To abort a quest use the ESC key while you');
      OutTextXY(x,y+20,'are playing. Then you will get back to the');
      OutTextXY(x,y+40,'first menue.');
      WaitKey;

      if False and (LastKey<>Escap) then begin
      SetFillStyle(SolidFill,DarkGray); Bar(x+xo,y-tt+10,x+xo+xs,y+yo+ys-tt);
      SetTextStyle(TriplexFont,HorizDir,1); SetColor(Black);
      OutTextXY(x,y+00,'If you think that this game is usable,');
      OutTextXY(x,y+20,'please send '+DMstr+' to:');
      OutTextXY(x+100,y+50,'J. A. Merten');
      OutTextXY(x+100,y+70,'Mariendorfer Damm 373');
      OutTextXY(x+100,y+92,'12107 Berlin');
      OutTextXY(x+100,y+115,'Germany');
      OutTextXY(x,y+150,'For questions call: Germany-30-762 03 22-1.');
      OutTextXY(x+215,y+180,'greetings from Joe M.');
      WaitKey;

      end end end;
      WriteHelpKey;
      end; { else }
  LastKey:=0;
  DecMouseHide;
  end;

Function CalcDoorCenter(var M: MazeType; x,y: integer; var DoorX,DoorY: integer): Boolean;
  var r: Boolean;
  begin
  r:=True;
  DoorX:=x; DoorY:=y;
  case M.M[y,x] of
    'µ': if M.M[y,x-1] in DoorCenterChar then Dec(DoorX) else r:=False;
    'Ò': if M.M[y+1,x] in DoorCenterChar then Inc(DoorY) else r:=False;
    'Æ': if M.M[y,x+1] in DoorCenterChar then Inc(DoorX) else r:=False;
    'Ð': if M.M[y-1,x] in DoorCenterChar then Dec(DoorY) else r:=False;
    else r:=False;
    end;
  CalcDoorCenter:=r
  end;

Procedure CalcDoorWings(var M: MazeType; x,y: integer; var re,ob,li,un: Boolean);
  begin
  re:=CheckMaze(M,['µ'],y  ,x+1,0)=1;
  ob:=CheckMaze(M,['Ò'],y-1,x  ,0)=1;
  li:=CheckMaze(M,['Æ'],y  ,x-1,0)=1;
  un:=CheckMaze(M,['Ð'],y+1,x  ,0)=1;
  end;

Procedure MoveDoor(var Maze: MazeType; x,y: integer; ccw: Boolean; DrawDoor: Boolean);
  var x1,y1: integer;
      i0,i1: integer;
      c0,c1: char;
  begin
  i0:=1*CheckMaze(Maze,['µ'],y  ,x+1,0)+
      2*CheckMaze(Maze,['Ò'],y-1,x  ,0)+
      4*CheckMaze(Maze,['Æ'],y  ,x-1,0)+
      8*CheckMaze(Maze,['Ð'],y+1,x  ,0);    { DoorCenterArr[i0] ist dann = Maze.M[y,x] }
  if ccw then i1:=(i0 shl 1)-15*ord(i0>7) else i1:=(i0 shr 1)+8*ord(odd(i0)); { Drehen }
                                    { DoorCenterArr[i1] ist nun neuer Trmittelpunkt ! }
  c0:=Maze.M[y,x];
  if (i0 and 1)>0 then Maze.M[y  ,x+1]:=' ';
  if (i0 and 2)>0 then Maze.M[y-1,x  ]:=' ';
  if (i0 and 4)>0 then Maze.M[y  ,x-1]:=' ';
  if (i0 and 8)>0 then Maze.M[y+1,x  ]:=' ';

  c1:=DoorCenterArr[i1];
  if (i1 and 1)>0 then Maze.M[y  ,x+1]:='µ';
  if (i1 and 2)>0 then Maze.M[y-1,x  ]:='Ò';
  if (i1 and 4)>0 then Maze.M[y  ,x-1]:='Æ';
  if (i1 and 8)>0 then Maze.M[y+1,x  ]:='Ð';
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

Procedure GotoFldXY(x,y: Integer);
  begin
  GotoXY((x-1)*3+1+MazeXoffs,y+MazeYoffs);
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

Const StartTime: LongInt =0;
    TriggerTime: LongInt =0;

Function CheckTimeout(Tol: LongInt): Boolean;
  begin
  CheckTimeout:=False;
  if (MaxTime<>0) or (Timeout<>0) then
    begin
    if StartTime=0 then
      begin
      StartTimer(StartTime);
      StartTimer(TriggerTime);
      end
    else begin
      if (MaxTime<>0) and (ReadTimerMS(StartTime) div 1000 > MaxTime+Tol) then CheckTimeout:=True;
      if (TimeOut<>0) and (ReadTimerMS(TriggerTime) div 1000 > Timeout+Tol) then CheckTimeout:=True;
      end;
    end;
  end;

Procedure TriggerTimeout;
  begin
  if Timeout<>0 then
    begin
    StartTimer(TriggerTime);
    end;
  end;

Procedure ClearKbdBuffer;
  begin
  {if not TextKwirk then{}
    begin
    while KeyPressed do if ReadKey=#0 then;
    end;
  end;

Procedure ClearKbdRepeat;
  var c: Word;
     lk: Word;
  begin
  if KbdRepeated then
    begin
    lk:=LastKey;
    while KeyPressed and (lk=LastKey) do
      begin
      c:=KwirkReadKey;
      end;
    if lk<>LastKey then KbdRepeated:=False;
    end;
  end;

Function KwirkReadKey: Word;
  begin
  while not KeyPressed do
    begin
    if CheckTimeout(10) then Halt;
    end;
  LastKey:=ReadKey2;
  KwirkReadKey:=LastKey;
  TriggerTimeout;
  end;

Function KwirkKeyPressed: Boolean;
  begin
  KwirkKeyPressed:=KeyPressed;
  if CheckTimeout(10) then Halt;
  end;

Function KwirkGetKey: Word;
  begin
  if CheckTimeout(10) then Halt;
  KwirkGetKey:=0;
  if KeyPressed then
    begin
    KwirkGetKey:=KwirkReadKey;
    end;
  end;

Procedure WaitKey;
  begin
  if KwirkReadKey=0 then;
  end;

Function LastChar: Char;
  begin
  LastChar:=#0;
  if LastKey<255 then LastChar:=Char(LastKey);
  end;

end.