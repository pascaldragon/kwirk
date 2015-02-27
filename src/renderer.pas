(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

unit Renderer;

{$I kwirkdefs.inc}

interface

uses
  Dos,
  DefBase;

Procedure DrawImage(ix,iy: Int16; Img: Pointer; dx,dy: Int16; PutMode: Int16);
Procedure DrawMazeImage(var Maze: MazeType; ix,iy: Int16);
Procedure DrawField(var M: MazeType);
Function RoomMenue(Room0: Int16): Int16;
Procedure WriteHelpKey;
Procedure ClearHelpKey;
Procedure WriteQuestMakerTitle;
Procedure WriteTitle;
Procedure WriteLevel(s: String);
Procedure WriteMazeNr(n: Int16);
Procedure WriteAttempt(t: Int16);
Procedure WriteTime1(t: LongInt);
Procedure WriteTime2(t: LongInt);
Procedure ShowHelp;
Function LoadImages(FN: PathStr): Boolean;
Function MazeMenue(FN0: PathStr): PathStr;
function SupportsMazeSelection: Boolean;
Function Char2ImgNr(c: Char): Int16;
Function Char2ImgPtr(c: Char): Pointer;
Procedure SetMazeImage(var Maze: MazeType; x,y: Int16);
Procedure SetImgMaze(var Maze: MazeType);
Procedure DrawWater(x,y: Int16; Mode: Int16);
procedure RendererDone;
procedure RendererInit;

implementation

uses
  CrtUnit, GraphUnit,
  CrtUtils, GraphUtils, Compat, Maze, Utils;

Procedure DrawImage(ix,iy: Int16; Img: Pointer; dx,dy: Int16; PutMode: Int16);
  var x,y,i: Int16;
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
          GraphUnit.Bar(x,y,x+ImgXsize-1,y+ImgYsize-1);
          end;
        end
      else PutImage(x,y,Img^,PutMode);
    DecMouseHide
    end;
  end;

Procedure DrawMazeImage(var Maze: MazeType; ix,iy: Int16);
  var x,y,i: Int16;
    PutMode: Int16;
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
      GraphUnit.Bar(x,y,x+ImgXsize-1,y+ImgYsize-1);
      end;
    DecMouseHide;
    end;
  end;

Procedure DrawField(var M: MazeType);
  var x,y: Int16;
    xs,ys: Int16;
        i: Int16;
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
    SetColor(CalcColor(Black));
    SetTextJustify(CenterText,TopText);
    SetTextStyle(GothicFont,HorizDir,3);
    OutTextXYs((M.xs*ImgXsize) div 2 +MazeXoffs,MazeYoffs,M.Name,Black,DarkGray);
    end;
  DecMouseHide
  end;

Procedure DrawWater(x,y: Int16; Mode: Int16);
  begin
  if TextKwirk then
    begin
    TextAttr:=LightBlue+16*Blue;
    GotoFldXY(x,y);
    if Mode=1 then
      Write('ùùù')
    else
      Write('OOO');
    end
  else begin
    if Mode=1 then
      DrawImage(x,y,Img[WatrWeg1],0,0,XOrPut)
    else
      DrawImage(x,y,Img[WatrWeg2],0,0,CopyPut);
    end;
  end;

procedure RendererDone;
begin
  if not TextKwirk then
    begin
    {$if declared(TextMode)}
    if (TextModeAtProgrammStart>=0) then TextMode(TextModeAtProgrammStart);
    {$endif}
    end
  else begin
    {$if declared(TextMode)}
    NormVideo;
    {$endif}
    Write(' ');
    ClrScr;
    end;
end;

procedure RendererInit;
var
  i: Int16;
  MemErr: Boolean;
begin
  if not TextKwirk then
    begin
    i:=1; MemErr:=False;
    while (i<=nImages) and not MemErr do
      begin
      MemErr:={$ifndef enable}False{$else}MaxAvail<3*SizeOf(ImgType){$endif};
      if not MemErr then New(Img[i]);
      Inc(i);
      end;
    if MemErr then InitError('To few memory to load the Images !',False,False);
    if not LoadImages(ImgFn) then
      begin
      ExitGem;
      InitError('IO-error while reading image file ['+ImgFn+']',False,False);
      end;
    end;
end;


Const  RoomPumOffs: Int16 = 1;
Function RoomMenue(Room0: Int16): Int16;
  var   i,n: Int16;
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

Procedure WriteMazeNr(n: Int16);
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
    SetColor(CalcColor(Yellow));
    SetFillStyle(SolidFill,CalcColor(Black));
    SetTextJustify(LeftText,TopText);
    SetTextStyle(TriplexFont,HorizDir,1);
    OutTextXYs(540,160,'Room',Black,Yellow);
    {Bar(596,162,620,180);}
    ClrOutTextXY(596,160,Copy(Int2StrL(n,2), 1, 2));
    OutTextXYs(596,160,Int2Str(n),Black,Yellow);
    end;
  end;

Procedure WriteAttempt(t: Int16);
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
    SetColor(CalcColor(Cyan));
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
    SetColor(CalcColor(Cyan));
    SetTextJustify(LeftText,TopText);
    if DefaultSpeedFont then SetTextStyle(DefaultFont,HorizDir,1) else SetTextStyle(TriplexFont,HorizDir,1);
    OutTextXY(540,270,'Total');
    ClrOutTextXY(540,290,s);
    OutTextXY(540,290,s);
    end;
  end;

Procedure ShowHelp;
  Const xs=440; ys=340;  { Ges. Box }
        xo=-15; yo=-90;  { Abstand v. Box zum Text     }
        tt=50;           { Y-Abstand v. Titel zum Text }
  var xp: Int16;       { f. Titel }
      yp: Int16;
      x : Int16;       { f. Text  }
      y : Int16;
  Procedure HelpTitle;
    begin
    SetFillStyle(SolidFill,CalcColor(DarkGray));  Bar(x+xo,y+yo,x+xo+xs,y+yo+ys);
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
    SetTextStyle(TriplexFont,HorizDir,1); SetColor(CalcColor(Black));
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
  if iConfig.Screen1=HercMono then begin xp:=65; x:=30 end else begin xp:=120; x:=85 end;
  yp:=110; y:=160;
  if not QuestMakerFlag then ClearHelpKey;
  SetFillStyle(SolidFill,CalcColor(LightGray));
  if GetMaxColor<4 then SetFillStyle(SolidFill,GetMaxColor-1);
  Bar(x+xo+20,y+yo+20,x+xo+xs+20,y+yo+ys+20);

  HelpTitle;
  if QuestMakerFlag then ShowQMakeHelp
    else begin
      SetTextStyle(TriplexFont,HorizDir,1); SetColor(CalcColor(Black));
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
      SetFillStyle(SolidFill,CalcColor(DarkGray)); Bar(x+xo,y-tt+10,x+xo+xs,y+yo+ys-tt);
      SetTextStyle(TriplexFont,HorizDir,1); SetColor(CalcColor(Black));
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
      SetFillStyle(SolidFill,CalcColor(DarkGray)); Bar(x+xo,y-tt+10,x+xo+xs,y+yo+ys-tt);
      SetTextStyle(TriplexFont,HorizDir,1); SetColor(CalcColor(Black));
      OutTextXY(x,y+00,'To abort a quest use the ESC key while you');
      OutTextXY(x,y+20,'are playing. Then you will get back to the');
      OutTextXY(x,y+40,'first menue.');
      WaitKey;

      if False and (LastKey<>Escap) then begin
      SetFillStyle(SolidFill,CalcColor(DarkGray)); Bar(x+xo,y-tt+10,x+xo+xs,y+yo+ys-tt);
      SetTextStyle(TriplexFont,HorizDir,1); SetColor(CalcColor(Black));
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

Procedure GetImg(var F: File; i: Int16);
  var x1,y1,
      x2,y2,
       s,s1: Int16;
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
      i: Int16;
    x,y: {$ifdef fpc}longword{$else}word{$endif};
  begin
  InOutRes:=0;
  Assign(F,FN); Reset(F,1);
  if InOutRes=0 then
    begin
    BlockRead(F,x,{$ifdef fpc}4{$else}2{$endif});
    BlockRead(F,y,{$ifdef fpc}4{$else}2{$endif});
    end;
  if InOutRes=0 then
    begin
    {$ifdef fpc}
    ImgXsize := x;
    ImgXsize := y;
    {$else}
    ImgXsize:=x+1;
    ImgYsize:=y+1;
    {$endif}
    end;
  Reset(F,1);
  i:=1;
  while (InOutRes=0) and not Eof(F) and (i<=nImages) do
    begin GetImg(F,i); Inc(i) end;
  Close(F);
  LoadImages:=IOResult=0
  end;

Const MaxMazeMenEntrys = 100;
Type  MazeMenEntryType = record FN,Title: PathStr end;
        MazeMenArrType = Array[0..MaxMazeMenEntrys+1] of MazeMenEntryType;

Procedure MazeMenueSort(var a: MazeMenArrType; n: Int16);
  procedure QuickSort(L, R: Int16);
    var  I,J: Int16;
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

Const  MazePumOffs: Int16 = 1;
Function MazeMenue(FN0: PathStr): PathStr;
  Type EntryType = record FN,Title: PathStr end;
  var     d: MazeMenArrType;
      i,j,n: Int16;
         sr: SearchRec;
          T: Text;
          s: String;
          l: Byte absolute s;
  begin
  {$ifdef enable}
  vUpcaseStr(FN0);
  {$endif}
  FN0:=Copy(FN0,1,Pos('.',FN0)-1);
  FindFirst('*.maz',Archive,sr);
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
  if i=0 then MazeMenue:='' else MazeMenue:=d[i].FN+'.maz';
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

function SupportsMazeSelection: Boolean;
begin
  SupportsMazeSelection := not TextKwirk;
end;

Function Char2ImgNr(c: Char): Int16;
  var f: Int16;
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
  var f: Int16;
  begin
  f:=Char2ImgNr(c);
  if f=0 then Char2ImgPtr:=Nil else Char2ImgPtr:=Img[f];
  end;

Procedure SetMazeImage(var Maze: MazeType; x,y: Int16);
  var   i,l,m,f: Int16;
              c: char;
             cs: CharSet;
    re,ob,li,un: Boolean;
    ro,lo,ru,lu: Boolean;
  Procedure AddLine(Ln: Int16);
    begin if l<=MaxLines then begin if f=WallFld then ImgMaze[y,x].Line1[l]:=Ln else ImgMaze[y,x].Line2[l]:=Ln; Inc(l) end end;
  Procedure AddMask(Mk: Int16);
    begin if m<=MaxMasks then begin if f=WallFld then ImgMaze[y,x].Mask1[m]:=Mk else ImgMaze[y,x].Mask2[m]:=Mk; Inc(m) end end;
  Function CheckWallWater(y,x: Int16): Int16;
    var i: Int16;
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
  var x,y: Int16;
  begin
  for x:=1 to Maze.xs do
    for y:=1 to Maze.ys do
      SetMazeImage(Maze,x,y);
  end;

end.

