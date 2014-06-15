(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

Program iPaint; { ImagePainter }

uses Graph,Desk,GemBase,GemInit,Mouse,MsgAlert,Dir,Pum,GrInput,Crt,Dos,StrSubs,Str2Num;

const xSize: integer = 27;
      ySize: integer = 27;
   MaxXsize = 27;
   MaxYSize = 27;
  MaxFields = 112;
  GridColor: Byte = DarkGray;
 FrameColor: Byte = White;
ActiveColor: Byte = LightGray;
  ImgFN: PathStr = 'Test.Img';
ImgPath: PathStr = '';

Type  FieldType = Array[1..MaxXSize,1..MaxYSize] of Byte;
      ref_Field = ^FieldType;

Type ref_Img = ^ImgType;
     ImgType = record xs,ys: integer; Buf: Array[1..65531] of Byte end;

var   Maze: Array[1..MaxFields] of ref_Field;
  PasteFld: FieldType;
   nFields: integer;
      xPal: integer;
      yPal: integer;
     xMaze: integer;
     yMaze: integer;
    xMazes: integer;
    yMazes: integer;
   PalxTab: integer;
   PalyTab: integer;
  BigXsize,
  BigYsize: integer;
  ImgLines,
   ImgRows: integer;

const     Fld: integer = 1;
  Mouse1Color: integer = LightGray;
  Mouse2Color: integer = Red;
  Mouse3Color: integer = Black;
      nImages: integer = MaxFields;
 MinWinColors: Boolean = True;

Procedure SetMinWinColorPalette;
  var i: integer;
  begin
  if MonoChrome then exit;
  if MinWinColors
    then begin
      for i:=0 to 15 do SetPalette(i,i);
        (*
        SetRGBPalette(00,00,00,00);
        SetRGBPalette(01,09,09,09);
        SetRGBPalette(02,18,18,18);
        SetRGBPalette(03,27,27,27);
        SetRGBPalette(04,36,36,36);
        SetRGBPalette(05,45,45,45);
        SetRGBPalette(06,54,54,54);
        SetRGBPalette(07,63,63,63);

        SetRGBPalette(08,00,00,00);
        SetRGBPalette(09,00,00,63);
        SetRGBPalette(10,63,00,00);
        SetRGBPalette(11,63,00,63);
        SetRGBPalette(12,00,63,00);
        SetRGBPalette(13,00,63,63);
        SetRGBPalette(14,63,63,00);
        SetRGBPalette(15,63,63,63);*)
      { vvv Weil die Reihenfolge der 4 Planes vertauscht ist vvv }
        SetRGBPalette(00,00,00,00);
        SetRGBPalette(08,09,09,09);
        SetRGBPalette(04,18,18,18);
        SetRGBPalette(12,27,27,27);
        SetRGBPalette(02,36,36,36);
        SetRGBPalette(10,45,45,45);
        SetRGBPalette(06,54,54,54);
        SetRGBPalette(14,63,63,63);

        SetRGBPalette(01,00,00,00);
        SetRGBPalette(09,00,00,63);
        SetRGBPalette(05,63,00,00);
        SetRGBPalette(13,63,00,63);
        SetRGBPalette(03,00,63,00);
        SetRGBPalette(11,00,63,63);
        SetRGBPalette(07,63,63,00);
        SetRGBPalette(15,63,63,63);
      FrameColor:=6;
      GridColor:=2;
      GemBoxColor:=10;
      end
    else begin
      GridColor:=DarkGray;
      FrameColor:=White;
      SetColorDefault;
      SetDefaultPalette;
      end;
  end;

Procedure SetScrObjVars;
  begin
  {if not InitGem('') then halt;}

  PalxTab:=GetMaxX div ((GetMaxColor+1) div 2 +3);
  xPal:=GetMaxX-((GetMaxColor+1) div 2)*PalxTab;
  PalyTab:=(30*GetMaxY) div 480; yPal:=GetMaxY-2*PalyTab;

  ImgLines:=(yPal-10) div (ySize+1); ImgLines:=14; { fÅr Kwirk 14x8 }
  if nFields<ImgLines then ImgLines:=nFields;
  ImgRows:=(nFields-1) div ImgLines +1;
  xMazes:=ImgRows*(xSize+1);
  yMazes:=ImgLines*(ySize+1);

  BigXsize:=(GetMaxX-(ImgRows*(xSize+1)+4{10})) div xSize {+1};
  BigYsize:=(yPal-4{10}) div ySize;
  if BigXsize<BigYsize then BigYsize:=BigXsize else BigXsize:=BigYsize;
  yMaze:=ySize*BigYsize;
  xMaze:=GetMaxX-xSize*BigXsize;
  end;

Procedure ScrInit;
  var f,i,j: integer;
  begin
  if not InitGem('') then halt;
  SetScrObjVars;
  if MinWinColors then SetMinWinColorPalette;
  end;

Procedure Init;
  var f,i,j: integer;
     MemErr: Boolean;
  begin
  i:=1; MemErr:=False;
  if nImages>MaxFields then nImages:=MaxFields;
  if nImages<1 then nImages:=1;
  while (i<=MaxFields{nImages}) and not MemErr do
    begin
    MemErr:=MaxAvail<3*SizeOf(FieldType);
    if not MemErr then
      begin
      New(Maze[i]);
      FillChar(Maze[i]^,SizeOf(Maze[i]^),0);
      end;
    Inc(i);
    end;
  nFields:=i-1;
  ScrInit;
  FillChar(PasteFld,SizeOf(PasteFld),0);
  end;

Procedure DrawSmallPixel(Fld,x,y: integer);
  begin
  IncMouseHide;
  PutPixel(x+((Fld-1) div ImgLines)*(xSize+1),y+((Fld-1) mod ImgLines)*(ySize+1),Maze[Fld]^[x,y]);
  DecMouseHide
  end;

Procedure DrawBigPixel(Fld,x,y: integer);
  var x1,y1: integer;
  begin
  y1:=(y-1)*BigYsize; x1:=GetMaxX-(xSize-(x-1))*BigXsize;
  SetColor(GridColor);
  SetFillStyle(SolidFill,Maze[Fld]^[x,y]);
  IncMouseHide;
  Bar(x1+1,y1+1,x1+BigXsize-1,y1+BigYsize-1);
  Rectangle(x1,y1,x1+BigXsize,y1+BigYsize);
  DecMouseHide
  end;

Procedure DrawMaze(Fld: integer);
  var i,j: integer;
  begin
  IncMouseHide;
  for i:=1 to xSize do
    for j:=1 to ySize do
      begin
      DrawBigPixel(Fld,i,j);
      DrawSmallPixel(Fld,i,j);
      end;
  DecMouseHide
  end;

Procedure DrawSmallField(Fld: integer);
  var i,j: integer;
  begin
  IncMouseHide;
  for i:=1 to xSize do
    for j:=1 to ySize do
      DrawSmallPixel(Fld,i,j);
  DecMouseHide
  end;

Procedure FrameSmallField(Fld,c: integer);
  begin
  SetColor(c);
  IncMouseHide;
  Rectangle(((Fld-1) div ImgLines)*(xSize+1),
            ((Fld-1) mod ImgLines)*(ySize+1),
            ((Fld-1) div ImgLines)*(xSize+1)+xSize+1,
            ((Fld-1) mod ImgLines)*(ySize+1)+ySize+1);
  DecMouseHide;
  end;

Procedure DrawMouseColor;
  var xt: integer;
  begin
  xt:=PalxTab div 2;
  IncMouseHide;
  SetColor(FrameColor);
  SetFillStyle(SolidFill,Mouse1Color);
  Bar(0,yPal,xt,GetMaxY);  Rectangle(0,yPal,xt,GetMaxY);
  SetFillStyle(SolidFill,Mouse2Color);
  Bar(xt,yPal,2*xt,GetMaxY);  Rectangle(xt,yPal,2*xt,GetMaxY);
  SetFillStyle(SolidFill,Mouse3Color);
  Bar(2*xt,yPal,3*xt,GetMaxY);  Rectangle(2*xt,yPal,3*xt,GetMaxY);
  DecMouseHide
  end;

Function ConvColor(c: Byte): Byte;
  begin
  if MinWinColors {and False{} then
    begin
    case c of
       0: c:= 0;
       1: c:= 8;
       2: c:= 4;
       3: c:=12;
       4: c:= 2;
       5: c:=10;
       6: c:= 6;
       7: c:=14;
       8: c:= 1;
       9: c:= 9;
      10: c:= 5;
      11: c:=13;
      12: c:= 3;
      13: c:=11;
      14: c:= 7;
      15: c:=15;
      end;
    end;
  ConvColor:=c;
  end;

Procedure DrawPalette;
  var i: integer;
  begin
  IncMouseHide;
  SetColor(FrameColor);
  for i:=0 to ((GetMaxColor+1) div 2) -1 do
    begin
    SetFillStyle(SolidFill,ConvColor(i));
    Bar(xPal+i*PalxTab,yPal,xPal+i*PalxTab+PalxTab,yPal+PalyTab);
    Rectangle(xPal+i*PalxTab,yPal,xPal+i*PalxTab+PalxTab,yPal+PalyTab);
    SetFillStyle(SolidFill,ConvColor(i+(GetMaxColor+1) div 2));
    Bar(xPal+i*PalxTab,yPal+PalyTab,xPal+i*PalxTab+PalxTab,yPal+2*PalyTab);
    Rectangle(xPal+i*PalxTab,yPal+PalyTab,xPal+i*PalxTab+PalxTab,yPal+2*PalyTab)
    end;
  DecMouseHide
  end;



Function GetImgField(mx,my: integer): integer;
  var x,y,f: integer;
  begin
  GetImgField:=0;
  if (mx>=xMazes) and (my>=yMazes) then exit;
  x:=mx div (xSize+1);
  y:=my div (ySize+1);
  f:=x*ImgLines+y +1;
  if (f>=1) and (f<=nFields) then GetImgField:=f
  end;

Procedure SetImgField(mx,my: integer; Mbs: Byte);
  var x,y,f: integer;
  begin
  f:=GetImgField(mx,my);
  if f=0 then exit;
  if f<>Fld then
    begin
    FrameSmallField(Fld,GridColor);
    Fld:=f;
    FrameSmallField(Fld,ActiveColor);
    DrawMaze(Fld);
    end
  end;

Procedure YankField(Fld: integer);
  begin
  PasteFld:=Maze[Fld]^;
  end;

Procedure PasteField(Fld: integer);
  begin
  Maze[Fld]^:=PasteFld;
  DrawMaze(Fld);
  end;

Procedure CopyField(Fld,mx,my: integer);
  var x,y,f: integer;
  begin
  f:=GetImgField(mx,my);
  if f=0 then exit;
  for x:=1 to xSize do
    for y:=1 to ySize do
      Maze[Fld]^[x,y]:=Maze[f]^[x,y];
  DrawMaze(Fld);
  end;

Procedure SetPixel(mx,my: integer; Mbs: Byte);
  var c: Byte;
    x,y: integer;
  begin
  if (Mbs<>1) and (Mbs<>2) and (Mbs<>4) then exit;
  if (mx<=xMaze) and (my>=yMaze) then exit;
  case Mbs of
    1: c:=Mouse1Color;
    4: c:=Mouse2Color;
    2: c:=Mouse3Color;
    end;
  x:=(mx-xMaze-1) div BigXsize +1;
  y:=my div BigYsize +1;
  if (x>=1) and (x<=xSize) and (y>=1) and (y<=ySize) and (Maze[Fld]^[x,y]<>c) then
    begin
    Maze[Fld]^[x,y]:=c;
    DrawSmallPixel(Fld,x,y);
    DrawBigPixel(Fld,x,y);
    end
  end;

Procedure SetMouseColor(mx,my: integer; Mbs: Byte);
  var c: Byte;
      p: ^Byte;
  begin
  if (Mbs<>1) and (Mbs<>2) and (Mbs<>4) then exit;
  if (mx<=xPal) or (my<=yPal) then exit;
  c:=(mx-(xPal+1)) div PalxTab;
  if my>yPal+PalyTab then Inc(c,(GetMaxColor+1) div 2);
  c:=ConvColor(c);
  case Mbs of
    1: p:=@Mouse1Color;
    4: p:=@Mouse2Color;
    2: p:=@Mouse3Color;
    end;
  if c<>p^ then
    begin
    p^:=c;
    DrawMouseColor;
    end;
  end;

Procedure FillField(Fld,c: integer);
  var i,j: integer;
  begin
  for i:=1 to xSize do
    for j:=1 to ySize do
      Maze[Fld]^[i,j]:=c;
  DrawMaze(Fld);
  end;

Procedure RotateField(Fld: integer);
  var a: FieldType;
    x,y: integer;
  begin
  a:=Maze[Fld]^;
  for x:=1 to xSize do
    for y:=1 to ySize do
      Maze[Fld]^[x,y]:=a[y,xSize+1-x];
  DrawMaze(Fld);
  end;

Procedure HMirrorField(Fld: integer);
  var a: Byte;
    x,y: integer;
  begin
  for x:=1 to xSize div 2 do
    for y:=1 to ySize do
      begin
      a:=Maze[Fld]^[x,y];
      Maze[Fld]^[x,y]:=Maze[Fld]^[xSize+1-x,y];
      Maze[Fld]^[xSize+1-x,y]:=a;
      end;
  DrawMaze(Fld);
  end;

Procedure VMirrorField(Fld: integer);
  var a: Byte;
    x,y: integer;
  begin
  for x:=1 to xSize do
    for y:=1 to ySize div 2 do
      begin
      a:=Maze[Fld]^[x,y];
      Maze[Fld]^[x,y]:=Maze[Fld]^[x,ySize+1-y];
      Maze[Fld]^[x,ySize+1-y]:=a;
      end;
  DrawMaze(Fld);
  end;

Procedure Scroll(Fld,dx,dy: integer);
  var   a: FieldType;
      x,y: integer;
    x1,y1: integer;
  begin
  a:=Maze[Fld]^;
  for x:=1 to xSize do
    for y:=1 to ySize do
      begin
      x1:=x+dx; if x1<1 then x1:=xSize; if x1>xSize then x1:=1;
      y1:=y+dy; if y1<1 then y1:=ySize; if y1>ySize then y1:=1;
      Maze[Fld]^[x1,y1]:=a[x,y];
      end;
  DrawMaze(Fld)
  end;

Procedure DelFldLine(Fld,mx,my: integer);
  var x,y,i,j: integer;
  begin
  x:=(mx-xMaze-1) div BigXsize +1;
  y:=my div BigYsize +1;
  for i:=1 to xSize do
    for j:=y to ySize do
      begin
      if j=ySize then Maze[Fld]^[i,j]:=0
                 else Maze[Fld]^[i,j]:=Maze[Fld]^[i,j+1]
      end;
  DrawMaze(Fld)
  end;

Procedure DelFldColumn(Fld,mx,my: integer);
  var x,y,i,j: integer;
  begin
  x:=(mx-xMaze-1) div BigXsize +1;
  y:=my div BigYsize +1;
  for i:=x to xSize do
    for j:=1 to ySize do
      begin
      if i=xSize then Maze[Fld]^[i,j]:=0
                 else Maze[Fld]^[i,j]:=Maze[Fld]^[i+1,j]
      end;
  DrawMaze(Fld)
  end;

const DelayTime: LongInt = 60;
Procedure Animate;
  var a: Array[1..100] of Pointer;
    Mbs: integer;
    mx,my: word;
     i,n: integer;
     s: Word;
   x1,y1,x2,y2: integer;
  begin
  n:=0;
  s:=ImageSize(1,1,xSize,ySize);
  repeat
    while MouseButton>0 do;
    repeat Mbs:=MouseButton until Mbs>0;
    MousePos(mx,my);
    if (Mbs=1) and (n<100) and (MaxAvail>s) then
      begin
      i:=GetImgField(mx,my);
      if i>0 then
        begin
        x1:=((i-1) div ImgLines)*(xSize+1)+1;
        y1:=((i-1) mod ImgLines)*(ySize+1)+1;
        x2:=((i-1) div ImgLines)*(xSize+1)+xSize;
        y2:=((i-1) mod ImgLines)*(ySize+1)+ySize;
        Inc(n);
        GetMem(a[n],s);
        IncMouseHide;
        GetImage(x1,y1,x2,y2,a[n]^);
        DecMouseHide
        end;
      end;
  until Mbs>1;
  repeat Mbs:=MouseButton until Mbs=0;
  if (n>1) and (Mbs<4) and IntegerInput(10050,10050,'|DelayTime: ',4,DelayTime,False) then
    begin
    x1:=mx; y1:=my;
    i:=1;
    while Mbs<=1 do
      begin
      PutImage(x1,y1,a[i]^,CopyPut);
       Dec(x1); if x1<-10 then x1:=620; {}
   {    Inc(x1); if x1>639 then x1:=0; {}
      inc(i); if i>n then i:=1;
      Mbs:=MouseButton;
      Delay(DelayTime);
      end;
    for i:=1 to n do FreeMem(a[i],s);
    end;
  end;

Procedure ReplaceColor(Fld,NewColor,OldColor: integer);
  var x,y: integer;
  begin
  for x:=1 to xSize do
    for y:=1 to ySize do
      if Maze[Fld]^[x,y]=OldColor then Maze[Fld]^[x,y]:=NewColor;
  DrawMaze(Fld)
  end;

Procedure ImageToField(var b: ImgType; Fld: integer);
  var   a: Array[1..$7FFF] of Byte absolute b;
    p,i,j: integer;
      x,y: integer;
      Bit: Byte;
    x0,y0: integer;
  begin
  (*x:=1; y:=1;
  j:=5; Bit:=$80;
  for y:=1 to ySize do
    begin
    for x:=1 to xSize do Maze[Fld]^[x,y]:=0;
    if y<=b.ys then
      begin
      for p:=1 to 4 do
        begin
        if Bit<>$80 then begin Inc(j); Bit:=$80 end;
        for x:=1 to b.xs do
          begin
          Inc(Maze[Fld]^[x,y],(16 shr p)*ord((a[j] and Bit)>0));
          {DrawBigPixel(Fld,x,y);}
          Bit:=Bit shr 1;
          if Bit=0 then begin Inc(j); Bit:=$80 end;
          end;
        end { for p:=1 to 4 }
      end { if y<=b.ys }
    end { for y:=1 to ySize }*)
  x0:=((Fld-1) div ImgLines)*(xSize+1);
  y0:=((Fld-1) mod ImgLines)*(ySize+1);
  for y:=1 to ySize do
    for x:=1 to xSize do
      begin
      if (y>b.ys) or (x>b.xs) then Maze[Fld]^[x,y]:=0 else
        begin
        Maze[Fld]^[x,y]:=GetPixel(x0+x,y0+y);
        if MonoChrome and (Maze[Fld]^[x,y]>0) then Maze[Fld]^[x,y]:=15;
        end;
      end;
  end;

Procedure GetField(var F: File; Fld: integer);
  var x1,y1,
      x2,y2,
      xs,ys: integer;
      ss,is: integer;
          p: ref_Img;
  begin
  IncMouseHide;
  x1:=((Fld-1) div ImgLines)*(xSize+1)+1;
  y1:=((Fld-1) mod ImgLines)*(ySize+1)+1;
  x2:=((Fld-1) div ImgLines)*(xSize+1)+xSize;
  y2:=((Fld-1) mod ImgLines)*(ySize+1)+ySize;
  ss:=ImageSize(x1,y1,x2,y2);
  BlockRead(F,xs,2); Inc(xs);
  BlockRead(F,ys,2); Inc(ys);
  is:=ImageSize(1,1,xs,ys);
  GetMem(p,is);
  BlockRead(F,p^.Buf,is-4); p^.xs:=xs-1; p^.ys:=ys-1;
  SetFillStyle(SolidFill,Black); Bar(x1,y1,x2,y2);
  PutImage(x1,y1,p^,NormalPut);
  p^.xs:=xs; p^.ys:=ys;
  ImageToField(p^,Fld);
  FreeMem(p,is);
  DecMouseHide;
  end;

Procedure LoadImages(FN: PathStr; SetSize: Boolean);
  var F: File;
      i: integer;
    x,y: word;
  begin
  IncMouseHide;
  if not SetSize then FrameSmallField(Fld,GridColor);
  InOutRes:=0;
  Assign(F,FN); Reset(F,1);
  if InOutRes=0 then
    begin
    BlockRead(F,x,2); Inc(x);
    BlockRead(F,y,2); Inc(y);
    if SetSize then begin xSize:=x; ySize:=y; end;
    Reset(F,1);
    i:=1;
    while not Eof(F) and (InOutRes=0) and (i<=MaxFields) do
      begin
      FrameSmallField(i,ActiveColor);
      GetField(F,i);
      {DrawSmallField(i);}
      FrameSmallField(i,GridColor);
      Inc(i)
      end;
    Dec(i);
    Close(F);
    if SetSize
      then begin
        nFields:=i;
        end
      else begin
        if i>nFields then nFields:=i;
        FrameSmallField(Fld,ActiveColor);
        DrawMaze(Fld);
        end;
    end;
  DecMouseHide;
  end;

Procedure PutField(var F: File; Fld: integer);
  var x1,y1,
      x2,y2,
          s: integer;
          p: Pointer;
  begin
  IncMouseHide;
  x1:=((Fld-1) div ImgLines)*(xSize+1)+1;
  y1:=((Fld-1) mod ImgLines)*(ySize+1)+1;
  x2:=((Fld-1) div ImgLines)*(xSize+1)+xSize;
  y2:=((Fld-1) mod ImgLines)*(ySize+1)+ySize;
  s:=ImageSize(x1,y1,x2,y2);
  GetMem(p,s);
  GetImage(x1,y1,x2,y2,p^);
  BlockWrite(F,p^,s);
  FreeMem(p,s);
  DecMouseHide;
  end;

Procedure SaveImages(FN: PathStr);
  var F: File;
      i: integer;
  begin
  IncMouseHide;
  FrameSmallField(Fld,GridColor);
  InOutRes:=0;
  Assign(F,FN); Rewrite(F,1);
  i:=1;
  while (InOutRes=0) and (i<=nFields) do
    begin
    FrameSmallField(i,ActiveColor);
    PutField(F,i);
    FrameSmallField(i,GridColor);
    Inc(i)
    end;
  Close(F);
  FrameSmallField(Fld,ActiveColor);
  DecMouseHide;
  end;

Procedure SaveFields(FN: PathStr);
  var F: File of FieldType;
      i: integer;
  begin
  if Pos('.',FN)>0 then FN:=Copy(FN,1,Pos('.',FN)-1);
  FN:=FN+'.Fld';
  IncMouseHide;
  FrameSmallField(Fld,GridColor);
  InOutRes:=0;
  Assign(F,FN); Rewrite(F);
  i:=1;
  while (InOutRes=0) and (i<=nFields) do
    begin
    FrameSmallField(i,ActiveColor);
    Write(F,Maze[i]^);
    FrameSmallField(i,GridColor);
    Inc(i)
    end;
  Close(F);
  FrameSmallField(Fld,ActiveColor);
  DecMouseHide;
  end;

Procedure LoadFields(FN: PathStr);
  var F: File of FieldType;
      i: integer;
  begin
  if Pos('.',FN)>0 then FN:=Copy(FN,1,Pos('.',FN)-1);
  FN:=FN+'.Fld';
  IncMouseHide;
  FrameSmallField(Fld,GridColor);
  InOutRes:=0;
  Assign(F,FN); Reset(F);
  i:=1;
  while (InOutRes=0) and (i<=nFields) do
    begin
    FrameSmallField(i,ActiveColor);
    Read(F,Maze[i]^);
    DrawSmallField(i);
    FrameSmallField(i,GridColor);
    Inc(i)
    end;
  Close(F);
  FrameSmallField(Fld,ActiveColor);
  DecMouseHide;
  end;

Procedure ChangeGraphicMode;
  var s: String;
      i: integer;
  begin
  s:='GraphicMode'+
     '|Hercules 768x348, Mono'+
     '|CGA 320x200, 4 Colors, C0'+
     '|CGA 320x200, 4 Colors, C1'+
     '|CGA 320x200, 4 Colors, C2'+
     '|CGA 320x200, 4 Colors, C3'+
     '|CGA 640x200, Mono'+
     '|MCGA 640x480, Mono'+
     '|EGA 640x200, 16 Colors'+
     '|EGA 640x350, 16 Colors'+
     '|VGA 640x480, 16 Colors';
  i:=10;
  SPopUpMenue(s,10050,10050,i,True,True,False,True,False,False);
  i:=Abs(i);
  if i>0 then
    begin
    case i of
      1: begin sConfig.Screen1:=HercMono; sConfig.Res1:=HercMonoHi end;
      2: begin sConfig.Screen1:=Cga;      sConfig.Res1:=CgaC0      end;
      3: begin sConfig.Screen1:=Cga;      sConfig.Res1:=CgaC1      end;
      4: begin sConfig.Screen1:=Cga;      sConfig.Res1:=CgaC2      end;
      5: begin sConfig.Screen1:=Cga;      sConfig.Res1:=CgaC3      end;
      6: begin sConfig.Screen1:=Cga;      sConfig.Res1:=CgaHi      end;
      7: begin sConfig.Screen1:=MCga;     sConfig.Res1:=MCgaHi     end;
      8: begin sConfig.Screen1:=Ega;      sConfig.Res1:=EgaLo      end;
      9: begin sConfig.Screen1:=Ega;      sConfig.Res1:=EgaHi      end;
      10:begin sConfig.Screen1:=Vga;      sConfig.Res1:=VgaHi      end;
      end;
    HideMouse;
    ExitGem;
    ScrInit;
    MouseShape(CrossHair);
    DrawPalette;
    DrawMouseColor;
    for i:=1 to nFields do
      begin
      FrameSmallField(i,GridColor);
      DrawSmallField(i)
      end;
    FrameSmallField(Fld,ActiveColor);
    DrawMaze(Fld);
    if ResetMouse then ;
    ShowMouse;
    end;
  end;

Procedure DrawAllImages;
  var i: Integer;
  begin
  IncMouseHide;
  for i:=1 to nFields do
    DrawSmallField(i);
  DecMouseHide;
  end;

Procedure RedrawScreen(Clear: Boolean);
  var i: Integer;
  begin
  IncMouseHide;
  if Clear then ClearDevice;
  DrawPalette;
  DrawMouseColor;
  for i:=1 to nFields do FrameSmallField(i,GridColor);
  FrameSmallField(Fld,ActiveColor);
  DrawMaze(Fld);
  DecMouseHide;
  end;

Procedure ChangeFldSize;
  var xs1,ys1: LongInt;
            i: integer;
  begin
  IncMouseHide;
  xs1:=xSize; ys1:=ySize;
  if IntegerInput(10050,10045,'|x-Size:',3,xs1,False) then
    if IntegerInput(10050,10055,'|y-Size:',3,ys1,False) then
      begin
      xSize:=xs1; ySize:=ys1;
      SetScrObjVars;
      RedrawScreen(True);
      DrawAllImages;
      DrawMaze(Fld);
      end;
  DecMouseHide;
  end;

Procedure ChangeFileSize;
  var n1: LongInt;
       i: integer;
  begin
  IncMouseHide;
  n1:=nFields;
  if IntegerInput(10050,10045,'|Filesize:',3,n1,False) then
    begin
    nFields:=n1;
    SetScrObjVars;
    RedrawScreen(True);
    DrawAllImages;
    DrawMaze(Fld);
    end;
  DecMouseHide;
  end;

Procedure ShowHelp;
  var c: Char;
    x,y: Integer;

  Procedure WrLine(s: String);
    begin
    OutTextXY(x,y,s); Inc(y,10);
    end;

  begin
  IncMouseHide;
  ClearDevice;
  SetColor(White);
  x:=20; y:=10;
  WrLine('BGI - Image Painter  1991 by Joe M.');
  WrLine('');
  WrLine('F1 - Display this helpscreen');
  WrLine('F2 - Save file to disk');
  WrLine('F3 - Cancel program without saving');
  WrLine('F4 - Save file and quit program');
  WrLine('F8 - Load a file from disk');
  WrLine('');
  WrLine('F  - Fill image with actual color');
  WrLine('C  - Copy from mouse-pointed image');
  WrLine('Y  - Yank to unnamed buffer');
  WrLine('Ins- Paste from unnamed buffer');
  WrLine('R  - Rotate image');
  WrLine('H  - H-mirror');
  WrLine('V  - V-Mirror');
  WrLine('U  - Undo to last image-change-state');
  WrLine('R  - Rotate image');
  WrLine('X  - Exchange color 3 with color 1');
  WrLine('S  - Change image size');
  WrLine('N  - Change file size');
  WrLine('G  - Change graphicmode');
  WrLine('P  - Set MinWin palette');
  WrLine('Use the cursorkeys to scroll the image');
  WrLine('^Backspace deletes a line');
  WrLine('The Delete-key deletes a column');
  WrLine('');
  WrLine('- Press any Key to continue -');
  c:=ReadKey;
  RedrawScreen(True);
  DrawAllImages;
  DecMouseHide;
  end;

Procedure Paint(ClearScreen: Boolean);
  var  Mbs: Byte;
     mx,my: word;
    mx0,my0: word;
         c: integer;
         z: Char;
         i: integer;
    uField: FieldType;
       Ext: PathStr;
  begin
  PushMouse;
  HideMouse;
  MouseShape(CrossHair);
  if ClearScreen then RedrawScreen(True);
  FrameSmallField(Fld,ActiveColor);
  uField:=Maze[Fld]^;
  mx:=0; my:=0;
  if ResetMouse then ;
  ShowMouse;
  repeat
    mx0:=mx; my0:=my;
    repeat
      Mbs:=MouseButton;
      MousePos(mx,my);
    until (Mbs>0) or KeyPressed or ((mx<>mx0) or (my<>my0));
    c:=GetKey; if c=0 then z:=#0 else z:=UpCase(LastChar);
    if Mbs>0 then
      begin
      if (mx>xPal) and (my>yPal) then SetMouseColor(mx,my,Mbs);
      if (mx>xMaze) and (my<yMaze) then SetPixel(mx,my,Mbs);
      if (mx<xMazes) and (my<yMazes) then begin SetImgField(mx,my,Mbs); uField:=Maze[Fld]^ end;
      end;
    if c=iF1 then ShowHelp;
    if (c=iF2) or (c=iF4) then SaveImages(ImgFn);
    if (c=iF3) and (Alert(2,2,' Cancel without saving ? ','#1  Yes  |#2 Oh, no ')=2) then c:=0;
    if c=isF2 then SaveFields(ImgFn);
    if c=iF8 then begin
                  if Pos('.',ImgFn)>0 then ImgFn:=Copy(ImgFn,1,Pos('.',ImgFn)-1);
                  if GetFilename(ImgPath,'*.Img',ImgFn,Ext,False) then
                    begin
                    ImgFn:=ImgFn+'.Img';
                    LoadImages(ImgPath+ImgFn,False);
                    uField:=Maze[Fld]^
                    end;
                  end;
    if c=isF8 then begin
                  if Pos('.',ImgFn)>0 then ImgFn:=Copy(ImgFn,1,Pos('.',ImgFn)-1);
                  if GetFilename(ImgPath,'*.Fld',ImgFn,Ext,False) then
                    begin
                    ImgFn:=ImgFn+'.Img';
                    LoadFields(ImgPath+ImgFn);
                    uField:=Maze[Fld]^
                    end;
                  end;
    if c=iIns then PasteField(Fld);
    if z='Y' then YankField(Fld);
    if z='F' then FillField(Fld,Mouse1Color);                   { Fill }
    if z='C' then CopyField(Fld,mx,my);                         { Copy }
    if z='R' then RotateField(Fld);                             { Rotate }
    if z='H' then HMirrorField(Fld);                            { HMirror }
    if z='V' then VMirrorField(Fld);                            { VMirror }
    if z='U' then begin Maze[Fld]^:=uField; DrawMaze(Fld) end;  { Undo }
    if z='X' then ReplaceColor(Fld,Mouse1Color,Mouse3Color);    { ReplaceColor }
    if z='A' then Animate;                                      { Animate }
    if z='S' then ChangeFldSize;                                { ChangeFldSize }
    if z='N' then ChangeFileSize;                               { ChangeFileSize }
    if z='G' then ChangeGraphicMode;                            { ChangeGraphicMode }
    if c=iCBckSp then DelFldLine(Fld,mx,my);                    { DelLine }
    if c=iDel then DelFldColumn(Fld,mx,my);                     { DelColumn }
    if c=iCUp then Scroll(Fld,0,-1);
    if c=iCDn then Scroll(Fld,0,1);
    if c=iCLft then Scroll(Fld,-1,0);
    if c=iCRgt then Scroll(Fld,1,0);
    if Z='P' then begin MinWinColors:=not MinWinColors; SetMinWinColorPalette; RedrawScreen(False) end;
    { C F G H P R S U V X }
  until (c=iF3) or ((c=iF4) and (InOutRes=0));
  PopMouse
  end;

Procedure WriteOptions;
  Function Bool2OnOff(a: Boolean): String;
    begin if a then Bool2OnOff:='On' else Bool2OnOff:='Off' end;

  begin
  writeln;
  writeln('BGI - ImagePainter   (C) 1991 JME Engineering   written by Joe M. 1991');
  writeln;
  writeln('usage:   ImgPaint [<FileName>] {/<Option>}');
{  writeln;
  writeln('<FileName>: Name of a Maze-File, e.g. GoingUp1, Heading1, ...');
}  writeln;
  writeln('available Options:');
  writeln('  VGA         :      VGA-Mode 640x480, 16 Colors');
  writeln('  EGA         :      EGA-Mode 640x350, 16 Colors');
  writeln('  EGALo       :      EGA-Mode 640x200, 16 Colors');
  writeln('  MCGA        :     MCGA-Mode 640x480, Monochrome');
  writeln('  CGAC0,CGAC1,');
  writeln('  CGAC2,CGAC3 :      CGA-Mode 320x200,  4 Colors');
  writeln('  CGAHi       :      CGA-Mode 640x200, Monochrome');
  writeln('  Herc        : Hercules-Mode 768x348, Monochrome');
  writeln('  X<n>        : ImgXsize');
  writeln('  Y<n>        : ImgYsize');
  writeln('  N<n>        : nFields');
  writeln('  MWC         : Set MinWin Color Palette');
  writeln;
  writeln('ImageFile is [',ImgFn,']');
  writeln('For questions call:  Germany  030 - 73 49 21');
  Halt;
  end;


Const LoadFile: Boolean = False;
Procedure GetParameters;
  var i: integer;
      s: String;
  begin
  i:=1;
  while i<=ParamCount do
    begin
    s:=ParamStr(i);
    if s='?' then WriteOptions;
    if s[1] in ['-','/']
      then begin
        s:=UpCaseStr(Copy(s,2,255));
        if s='?' then WriteOptions else
        if s='VGA'   then begin sConfig.Screen1:=Vga;      sConfig.Res1:=VgaHi      end else
        if s='EGA'   then begin sConfig.Screen1:=Ega;      sConfig.Res1:=EgaHi      end else
        if s='EGALO' then begin sConfig.Screen1:=Ega;      sConfig.Res1:=EgaLo      end else
        if s='MCGA'  then begin sConfig.Screen1:=MCga;     sConfig.Res1:=MCgaHi     end else
        if s='HERC'  then begin sConfig.Screen1:=HercMono; sConfig.Res1:=HercMonoHi end else
        if s='CGA'   then begin sConfig.Screen1:=Cga;      sConfig.Res1:=CgaC0      end else
        if s='CGAC0' then begin sConfig.Screen1:=Cga;      sConfig.Res1:=CgaC0      end else
        if s='CGAC1' then begin sConfig.Screen1:=Cga;      sConfig.Res1:=CgaC1      end else
        if s='CGAC2' then begin sConfig.Screen1:=Cga;      sConfig.Res1:=CgaC2      end else
        if s='CGAC3' then begin sConfig.Screen1:=Cga;      sConfig.Res1:=CgaC3      end else
        if s='CGAHI' then begin sConfig.Screen1:=Cga;      sConfig.Res1:=CgaHi      end else
        if copy(s,1,1)='X' then xSize:=Str2Int(Copy(s,2,255)) else
        if copy(s,1,1)='Y' then ySize:=Str2Int(Copy(s,2,255)) else
        if copy(s,1,1)='N' then nImages:=Str2Int(Copy(s,2,255)) else
        if s='MWC' then MinWinColors:=not MinWinColors {True} else
          begin
          writeln('BGI - ImagePainter   (C) 1991 JME Engineering   written by Joe M. 1991');
          writeln;
          Writeln('Invalid Option: ',s);
          writeln;
          writeln('Enter  ImgPaint ?  for help');
          Halt;
          end;
        end
      else begin
        ImgFn:=s+'.Img';
        LoadFile:=True;
        end;
    inc(i)
    end;
  end;

begin
GetParameters;
Init;
if LoadFile then
  begin
  LoadImages(ImgFn,True);
  SetScrObjVars;
  RedrawScreen(False);
  end;
Paint(not LoadFile);
{CloseGraph;}
ExitGem;
TextMode(Co80);
end.
