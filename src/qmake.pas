(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

{$V-}

Unit QMake; { QuestMaker for " The Quest of Kwirk's Castle " }
{ $D-,L-}

interface

Procedure QuestMaker;

implementation

uses Crt, Graph, Compat,{GemInit, GrInput, Pum,} Mouse, {StdSubs, vStrSubs, }DefBase, Misc, PlayKwrk;

Procedure GetRoomName(var s: String);
  begin
  SetTextDefault;
  if StringInput(10050,10050,'RoomName: ',s,MaxMazeNameLen,0) then
  end;

Procedure GetQuestName(var MazFN,QuestName: String);
  begin
  SetTextDefault;
  if StringInput(10050,10050,'|Filename of the Quest: ',MazFN,8,0) then
    if StringInput(10050,10050,'Name of the Quest:',QuestName,MaxMazeNameLen,0) then;
  end;

Procedure DrawMen(var M: MazeType);
  var xo,yo: integer;
  begin
  xo:=MazeXoffs;
  yo:=MazeYoffs;
  MazeXoffs:=MenXoffs;
  MazeYoffs:=MenYoffs;
  SetImgMaze(M);
  ImgMaze[1,1].Mask1[1]:=0; ImgMaze[1,1].Line1[1]:=0;
  ImgMaze[1,3].Mask2[1]:=0; ImgMaze[1,3].Line2[1]:=0;
  SetFillStyle(SolidFill,Black);
  Bar(540,0,GetMaxX,GetMaxY);
  DrawField(M);
  MazeXoffs:=xo;
  MazeYoffs:=yo;
  end;

Procedure InitMen(var Men: MazeType);
  var x,y: integer;
  begin
  with Men do
    begin
    Name:='';
    xs:=3; ys:=17;
    { nKwirks,KwirkX,KwirkY,Jump sind uninteressant }
    M[ 1]:='WÒ ';
    M[ 2]:='ÆÎµ';
    M[ 3]:=' ÐÒ';
    M[ 4]:='ÒÆ¹';
    M[ 5]:='ÌµÐ';
    M[ 6]:='ÐÂÒ';
    M[ 7]:='ÒÐÁ';
    M[ 8]:='ºÆ»';
    M[ 9]:='ÐÒÐ';
    M[10]:='JÈµ';
    M[11]:='ÚÜ¿';
    M[12]:='ÞÛÝ';
    M[13]:='ÀßÙ';
    M[14]:='Ç×¶';
    M[15]:='Ñ²Z';
    M[16]:='ØV^';
    M[17]:='Ï<>';
    for x:=1 to MaxMazeXsize do
      for y:=1 to MaxMazeYsize do
        P[y,x]:=False;
    P[1,3]:=True;
    end;
  MenXoffs:=GetMaxX-3*ImgXsize;
  MenYoffs:=0;
  end;

Function PickMazeField(var M: MazeType; mx,my: integer; var x,y: integer): Boolean;
  var r: Boolean;
  begin
  r:=True;
  x:=((mx-MazeXoffs) div ImgXsize) +1;
  if x<1 then begin x:=1; r:=False end;
  if x>M.xs then begin x:=M.xs; r:=False end;
  y:=((my-MazeYoffs) div ImgYsize) +1;
  if y<1 then begin y:=1; r:=False end;
  if y>M.ys then begin y:=M.ys; r:=False end;
  PickMazeField:=r
  end;

Function PickMenField(var M: MazeType; mx,my: integer; var x,y: integer): Boolean;
  var r: Boolean;
  begin
  r:=True;
  x:=((mx-MenXoffs) div ImgXsize) +1;
  if x<1 then begin x:=1; r:=False end;
  if x>M.xs then begin x:=M.xs; r:=False end;
  y:=((my-MenYoffs) div ImgYsize) +1;
  if y<1 then begin y:=1; r:=False end;
  if y>M.ys then begin y:=M.ys; r:=False end;
  PickMenField:=r
  end;

Procedure QMPlayKwirk(var M: MazeType; Room: integer);
  begin
  IncMouseHide;
  QuestMakerFlag:=False;
  SetFillStyle(SolidFill,Black);
  Bar(ImgXsize*20,0,GetMaxX,GetMaxY);
  WriteTitle;
  WriteLevel(QuestName);
  WriteMazeNr(Room);
  LevelStartTime:=round(rTime);
  WriteHelpKey;
  if PlayKwirk(M) then;
  QuestMakerFlag:=True;
  if LastKey=Escap then LastKey:=0;
  DecMouseHide
  end;

Procedure InsertDoor(var Men,M: MazeType; DoorX,DoorY: integer);
  var            a: Boolean;
       re,ob,li,un: Boolean;
    dp,rp,op,lp,up: Pointer;
     mx,my,mx0,my0: word;
               Mbs: Byte;
       xf,yf,xi,yi: integer;
       x1,y1,x0,y0: integer;
            Inside: Boolean;
  Procedure PutDoor(x,y,PutMode: integer);
    begin
    if ob then Inc(y,ImgYsize);
    if li then Inc(x,ImgXsize);
    PutImage(x,y,dp^,PutMode);
    if re then PutImage(x+ImgXsize,y,rp^,PutMode);
    if ob then PutImage(x,y-ImgYsize,op^,PutMode);
    if li then PutImage(x-ImgXsize,y,lp^,PutMode);
    if un then PutImage(x,y+ImgYsize,up^,PutMode);
    end;
  begin
  if Men.M[DoorY,DoorX] in DoorWingChar then if CalcDoorCenter(Men,DoorX,DoorY,DoorX,DoorY) then;
  CalcDoorWings(Men,DoorX,DoorY,re,ob,li,un); a:=False;
  dp:=Char2ImgPtr(Men.M[DoorY,DoorX]);
  if re then rp:=Char2ImgPtr(Men.M[DoorY,DoorX+1]);
  if ob then op:=Char2ImgPtr(Men.M[DoorY-1,DoorX]);
  if li then lp:=Char2ImgPtr(Men.M[DoorY,DoorX-1]);
  if un then up:=Char2ImgPtr(Men.M[DoorY+1,DoorX]);
  IncMouseHide;
  MousePos(mx0,my0); x0:=-1;
  repeat
    repeat
      MousePos(mx,my);
      Mbs:=MouseButton;
    until (mx<>mx0) or (my<>my0) or (Mbs=0);
    x1:=mx; y1:=my;
    Inside:=PickMazeField(M,mx,my,xf,yf) and (xf+ord(li)+ord(re)<=M.xs) and (yf+ord(ob)+ord(un)<=M.ys);
    if Inside then
      begin
      x1:=MazeXoffs+(xf-1)*ImgXsize;
      y1:=MazeYoffs+(yf-1)*ImgYsize
      end;

    if (x1<>x0) or (y1<>y0) then
      begin
      if a then PutDoor(x0,y0,XorPut);
      PutDoor(x1,y1,XorPut); a:=True;
      end;
    mx0:=mx; my0:=my; x0:=x1; y0:=y1;
  until Mbs<>1;
  if a then PutDoor(x0,y0,XorPut);
  if (Mbs=0) and Inside then
    begin
    if li then Inc(xf);
    if ob then Inc(yf);
    M.M[yf,xf]:=Men.M[DoorY,DoorX];
    if re then M.M[yf,xf+1]:=Men.M[DoorY,DoorX+1];
    if ob then M.M[yf-1,xf]:=Men.M[DoorY-1,DoorX];
    if li then M.M[yf,xf-1]:=Men.M[DoorY,DoorX-1];
    if un then M.M[yf+1,xf]:=Men.M[DoorY+1,DoorX];
    for xi:=xf-2 to xf+2 do
      for yi:=yf-2 to yf+2 do
        begin
        SetMazeImage(M,xi,yi);
        DrawMazeImage(M,xi,yi);
        end;
    end;
  DecMouseHide;
  end;

Procedure MakeRoom(var M: MazeType; Room: integer);
  var       Men: MazeType;
          mx,my: word;
        mx0,my0: word;
            Mbs: Byte;
              k: integer;
              c: Char;
      MenX,MenY: integer;
      cMnX,cMnY: integer;
      MazX,MazY: integer;
       MenPtr,p: Pointer;
          xi,yi: integer;
              a: Boolean;
  begin
  InitMen(Men);
  DrawMen(Men);
  KorregMaze(M);
  SetImgMaze(M);
  DrawField(M);
  MenPtr:=Nil; cMnX:=1; cMnY:=1;
  PushMouse;
  MouseShape(HoleCrossHair);{}
{  MouseShape(TouchingHand);{}
  ShowMouse;
  repeat
    {while MouseButton>0 do;}
    repeat
      k:=KwirkGetKey;
      Mbs:=MouseButton;
      MousePos(mx,my);
    until True or (k<>0) or (Mbs>0);
    if k=0 then LastKey:=0;
    c:=UpCase(LastChar);
    if (Mbs=1) and PickMenField(Men,mx,my,MenX,MenY) then
      begin
      if (MenX=3) and (MenY=1) then p:=Img[WatrFld] else p:=Char2ImgPtr(Men.M[MenY,MenX]);
      if Men.M[MenY,MenX] in DoorCenterChar+DoorWingChar then InsertDoor(Men,M,MenX,MenY)
        else
      if (p<>Nil) and (p<>MenPtr) then
        begin
        IncMouseHide;
        if MenPtr<>Nil then PutImage(MenXoffs+(cMnX-1)*ImgXsize,MenYoffs+(cMnY-1)*ImgYsize,MenPtr^,CopyPut);
        PutImage(MenXoffs+(MenX-1)*ImgXsize,MenYoffs+(MenY-1)*ImgYsize,p^,NotPut);
        DecMouseHide;
        MenPtr:=p;
        cMnX:=MenX;
        cMnY:=MenY;
        end;
      end;
    if PickMazeField(M,mx,my,MazX,MazY) then
      begin
      if (Mbs=2) and ((M.M[MazY,MazX]<>' ') or M.P[MazY,MazX]) then
        begin
        M.M[MazY,MazX]:=' ';
        M.P[MazY,MazX]:=False;
        IncMouseHide;
        for xi:=MazX-1 to MazX+1 do
          for yi:=MazY-1 to MazY+1 do
            begin
            SetMazeImage(M,xi,yi);
            DrawMazeImage(M,xi,yi);
            end;
        DecMouseHide;
        end;
      if (Mbs=1) then
        begin
        if M.M[MazY,MazX] in DoorWingChar+DoorCenterChar
          then begin
            if (M.M[MazY,MazX] in DoorCenterChar) or (CalcDoorCenter(M,MazX,MazY,MazX,MazY)) then
              begin
              IncMouseHide;
              MoveDoor(M,MazX,MazY,True,True);
              DecMouseHide;
              { for xi:=MazX-2 to MazX+2 do
                  for yi:=MazY-2 to MazY+2 do
                    begin
                    SetMazeImage(M,xi,yi);
                    DrawMazeImage(M,xi,yi);
                    end; }
              while MouseButton>0 do;
              end
            end
          else begin
            a:=False;
            if (cMnX=3) and (cMnY=1)
              then begin if not M.P[MazY,MazX] then begin M.P[MazY,MazX]:=True; a:=True end end
              else if M.M[MazY,MazX]<>Men.M[cMnY,cMnX] then begin M.M[MazY,MazX]:=Men.M[cMnY,cMnX]; a:=True end;
            if a then
              begin
              IncMouseHide;
              for xi:=MazX-1 to MazX+1 do
                for yi:=MazY-1 to MazY+1 do
                  begin
                  SetMazeImage(M,xi,yi);
                  DrawMazeImage(M,xi,yi);
                  end;
              DecMouseHide;
              end;
            end
        end;
      end;

    if c='P' then
      begin
      QMPlayKwirk(M,Room);
      if LastKey<>KeyF3 then begin DrawMen(Men); SetImgMaze(M); DrawField(M) end;
      end;
    if k=KeyF1 then begin ShowHelp; SetImgMaze(M); DrawField(M) end;
    if (k=KeyF2) or (k=KeyF4) then
      begin
      if SaveMazes(MazFN) and (k=KeyF4) then LastKey:=KeyF3;
      end;
  until (LastKey=Escap) or (LastKey=KeyF3);
  PopMouse
  end;

Procedure MakeQuest;
  var x,y: integer;
  begin
  WriteLevel(QuestName);
  repeat
    if nMazes>0 then Room:=RoomMenue(Room);
    if (Room>nMazes) then
      begin
      Inc(nMazes);
      Mazes[nMazes].Name:='';
      GetRoomName(Mazes[nMazes].Name);
      if Mazes[nMazes].Name<>'' then
        begin
        Mazes[nMazes].xs:=20; Mazes[nMazes].ys:=18;
        for y:=1 to MaxMazeYsize do
          begin
          {$ifdef enable}
          vNChar('W',MaxMazeXsize,Mazes[nMazes].M[y]);
          {$endif}
          for x:=1 to MaxMazeXsize do
            Mazes[nMazes].P[y,x]:=False;
          end;
        Room:=nMazes;
        end else Room:=0;
      end;
    if Room>0 then MakeRoom(Mazes[Room],Room);
  until (Room=0) or (LastKey=KeyF3);
  end;

Procedure QuestMaker;
  begin
  repeat
    ClearDevice;
    WriteQuestMakerTitle;
    WriteLevel('1991 by Joe M.   ');
    MazFN:=MazeMenue(MazFN);
    {$ifdef enable}
    if MazFN='' then begin ExitGem; Halt(0) end;
    {$endif}
    if MazFN='.Maz'
      then begin
        nMazes:=0;
        MazFN:='';
        QuestName:='The Quest Of The Century';
        GetQuestName(MazFN,QuestName);
        MazFN:=MazFN+'.Maz';
        if MazFN<>'.Maz' then MakeQuest;
        end
      else if LoadMazes(MazFN) then MakeQuest;
  until LastKey=KeyF3;
  {$ifdef enable}
  ExitGem;
  {$endif}
  if TextModeAtProgrammStart>=0 then TextMode(TextModeAtProgrammStart);
  GotoXY(1,1); TextColor(White);
  writeln('The Quest of Kwirk''s Castle             PC-Version by Joe M.  1991');
  TextColor(LightGray);
  writeln;
  Halt(0)
  end;

end.