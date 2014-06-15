(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

Unit Chat;

interface

Uses MyCrt;

Procedure DoChat(Key: Word);

implementation

Type PChatWin=^TChatWin;
     TChatWin=Object
       PosX,PosY: Byte;
       Wdt,Hgt  : Byte;
       Color    : Byte;
       WordBreak: Boolean;
      {CsrX,CsrY: Byte;{}
       BufPos   : Word;
       Buffer   : String;

       Procedure Init;
       Procedure Done;
       Procedure DrawAll;
       Procedure DrawDiff(Const Buf0: String);
       Procedure ShowCursor;
       Procedure HideCursor;
       Procedure GetMaxCursorPos(var x,y: Word);
       Procedure KeyInput(Key: Word);
       Function  GetMaxYOffset: Word;
       Function  GetLineCount: Word;
       Procedure GetLineIndex(Num: Word; var Pos,Len: Word);
       Procedure GetWordPos(var Idx,Len: Word);
       end;

Procedure vSetLen(var s: String; len: integer);
  var l: Byte absolute s;
  begin
  if Len<=0 then Len:=0;
  if Len>SizeOf(s)-1 then Len:=SizeOf(s)-1;
  if Len>l then FillChar(s[l+1],len-l,' ');
  l:=Len
  end;

Procedure TChatWin.Init;
  begin
  PosX:=1;
  PosY:=1;
  Wdt:=80;
  Hgt:=25;
  {CsrX:=1; CsrY:=1;{}
  BufPos:=1;
  Buffer:='';
{  Buffer:='123456 789';{}
  Color:=$70;
  WordBreak:=True; {not implemented}
  end;

Procedure TChatWin.Done;
  begin
  end;

Procedure TChatWin.DrawAll;
  var  y: Integer;
       i: Word;
       n: Word;
    nAnz: Word;
    nOfs: Word;
  begin
  if (Wdt=0) or (Hgt=0) then Exit;
  nAnz:=GetLineCount;
  nOfs:=GetMaxYOffset;

  for y:=1 to Hgt do
    begin
    TextAttr:=Color;
{    if y+nOfs>nAnz then TextAttr:=Color-$10;{}
    GetLineIndex(y+nOfs,i,n);
    if n>Wdt then n:=Wdt;
    if (n>0) and (Buffer[i+n-1]=#13) then Dec(n);
    GotoXY(PosX,PosY+y-1);
    if n>0 then Write(Copy(Buffer,i,n));
    if n<Wdt then
      begin
{      if y+nOfs<=nAnz then TextAttr:=Color-$20;{}
      Write('':Wdt-n);
      end;
    end;
  end;

Procedure TChatWin.DrawDiff(Const Buf0: String);
  var y,x: Integer;
       i: Word;
       n: Word;
    nAnz: Word;
    nOfs: Word;
    Merk: String;
    s1,s2: String;
        l: Byte absolute s1;
  begin
  if (Wdt=0) or (Hgt=0) then Exit;
  nOfs:=GetMaxYOffset;
  Merk:=Buffer;

  for y:=1 to Hgt do
    begin
    TextAttr:=Color;

    GetLineIndex(y+nOfs,i,n);
    if (n>0) and (Buffer[i+n-1]=#13) then Dec(n);
    s1:=Copy(Buffer,i,n);
    vSetLen(s1,Wdt);

    Buffer:=Buf0;
    GetLineIndex(y+nOfs,i,n);
    if (n>0) and (Buffer[i+n-1]=#13) then Dec(n);
    s2:=Copy(Buffer,i,n);
    vSetLen(s2,Wdt);
    Buffer:=Merk;

    if s1<>s2 then
      begin
      while s1[l]=s2[l] do Dec(l);
      x:=1;
      while s1[x]=s2[x] do Inc(x);
      GotoXY(PosX+x-1,PosY+y-1);
      Delete(s1,1,x-1);
      Write(s1);
      end;
    end;
  end;

Function TChatWin.GetMaxYOffset: Word;
  var nAnz: Word;
      nOfs: Word;
       Idx: Word;
       Len: Word;
  begin
  GetMaxYOffset:=0;
  if (Wdt=0) or (Hgt=0) then Exit;
  nAnz:=GetLineCount;
  if nAnz>0 then
    begin
    GetLineIndex(nAnz,Idx,Len);
    if (Len>=Wdt) or (Buffer[Length(Buffer)]=#13) then
      begin
      Inc(nAnz);
      end;
    end;
  nOfs:=0;
  if nAnz>Hgt then nOfs:=nAnz-Hgt;
  GetMaxYOffset:=nOfs;
  end;

Procedure TChatWin.GetMaxCursorPos(var x,y: Word);
  var nAnz: Word;
       Idx: Word;
       Len: Word;
  begin
  x:=1; y:=1;
  if (Wdt=0) or (Hgt=0) then Exit;
  nAnz:=GetLineCount;
  if nAnz>0 then
    begin
    GetLineIndex(nAnz,Idx,Len);
    if (Len>=Wdt) or (Buffer[Length(Buffer)]=#13) then
      begin
      y:=nAnz+1;
      end
    else begin
      y:=nAnz;
      x:=Len+1;
      end;
    end;
  end;

Procedure TChatWin.ShowCursor;
  var x,y: Word;
     nOfs: Word;
  begin
  if (Wdt=0) or (Hgt=0) then Exit;
  nOfs:=GetMaxYOffset;
  GetMaxCursorPos(x,y);
  Dec(y,nOfs);
  GotoXY(x+PosX-1,y+PosY-1);
  TextAttr:=Color or Blink;
  Write('_');
  end;

Procedure TChatWin.HideCursor;
  var x,y: Word;
     nOfs: Word;
  begin
  if (Wdt=0) or (Hgt=0) then Exit;
  nOfs:=GetMaxYOffset;
  GetMaxCursorPos(x,y);
  Dec(y,nOfs);
  GotoXY(x+PosX-1,y+PosY-1);
  TextAttr:=Color;
  Write(' ');
  end;

Procedure TChatWin.GetWordPos(var Idx,Len: Word);
  var l: Byte absolute Buffer;
      i: Word;
  begin
  i:=Idx;
  if i=1 then i:=1;
  while (i<=l) and (Buffer[i]=' ') do Inc(i);
  Idx:=i;
  if i<=l then
    begin
    if Buffer[i]=#13 then
      begin
      Inc(i);
      end
    else begin
      while (i<=l) and not (Buffer[i] in [' ',#13]) do Inc(i);
      end;
    end;
  Len:=i-Idx;
  end;

Function TChatWin.GetLineCount: Word;
  var BufLen: Byte absolute Buffer;
    nLin: Word;
   lIdx0: Word;
   lIdx1: Word;
    lIdx: Word;
    lLen: Word;
   wIdx0: Word;
    wIdx: Word;
    wLen: Word;
     bCR: Boolean;
   bBufEnd : Boolean;
   bFnd    : Boolean;
   bEmpty0 : Boolean;

  begin
  GetLineCount:=0;
  if Wdt=0 then Exit;

  wIdx:=1;
  nLin:=0;
  lIdx:=1;
  lLen:=0;
  lIdx0:=1;
  lIdx1:=1;
  bEmpty0:=True;
  repeat
    wIdx0:=wIdx;
    GetWordPos(wIdx,wLen);
    bCR:=(wLen=1) and (Buffer[wIdx]=#13);
    Inc(lLen,wIdx-wIdx0); {der Freiraum}
    if (lLen+wLen<=Wdt) or bCR then {Passt das Wort noch in die Zeile?}
      begin
      Inc(lLen,wLen);
      end
    else begin {SoftBreak}
      if lLen=0 then
        begin
        wLen:=Wdt; {das Wort muss gesplittet werden}
        lLen:=Wdt;
        end
      else begin
        wLen:=0; {das Wort in die naechste Zeile}
        bCR:=True;
        end;
      end;

    if bEmpty0 and (lLen<>0) then {Leere Zeile ist nun nicht mehr leer}
      begin
      Inc(nLin);
      lIdx0:=lIdx;
      lIdx:=lIdx1;
      end;

    if bCR then
      begin
      lIdx1:=wIdx+wLen;
      lLen:=0;
      end;

    bEmpty0:=lLen=0;

    Inc(wIdx,wLen);
    bBufEnd:=wIdx>BufLen;
  until bBufEnd;
  GetLineCount:=nLin;
  end;

Procedure TChatWin.GetLineIndex(Num: Word; var Pos,Len: Word);
  var BufLen: Byte absolute Buffer;
    nLin: Word;
   lIdx0: Word;
   lIdx1: Word;
    lIdx: Word;
    lLen: Word;
   wIdx0: Word;
    wIdx: Word;
    wLen: Word;
     bCR: Boolean;
   bBufEnd : Boolean;
   bFnd    : Boolean;
   bEmpty0 : Boolean;
   bNextLin: Boolean;

  begin
  Pos:=1; Len:=0;
  if (Wdt=0) or (Num=0) then Exit;

  wIdx:=1;
  nLin:=0;
  lIdx:=1;
  lLen:=0;
  lIdx0:=1;
  lIdx1:=1;
  bEmpty0:=True;
  repeat
    wIdx0:=wIdx;
    GetWordPos(wIdx,wLen);
    bCR:=(wLen=1) and (Buffer[wIdx]=#13);
    Inc(lLen,wIdx-wIdx0); {der Freiraum}
    if (lLen+wLen<=Wdt) or bCR then {Passt das Wort noch in die Zeile?}
      begin
      Inc(lLen,wLen);
      end
    else begin {SoftBreak}
      if lLen=0 then
        begin
        wLen:=Wdt; {das Wort muss gesplittet werden}
        lLen:=Wdt;
        end
      else begin
        wLen:=0; {das Wort in die naechste Zeile}
        bCR:=True;
        end;
      end;

    if bEmpty0 and (lLen<>0) then {Leere Zeile ist nun nicht mehr leer}
      begin
      Inc(nLin);
      lIdx0:=lIdx;
      lIdx:=lIdx1;
      end;

    if bCR then
      begin
      lIdx1:=wIdx+wLen;
      lLen:=0;
      end;

    bEmpty0:=lLen=0;

    Inc(wIdx,wLen);
    bBufEnd:=wIdx>BufLen;
    bNextLin:=nLin=Num+1;
  until bBufEnd or bNextLin;
  if bNextLin then
    begin
    Pos:=lIdx0;
    Len:=lIdx-lIdx0;
    end else
  if (nLin=Num) and bBufEnd then
    begin {Zeile gefunden}
    Pos:=lIdx;
    Len:=BufLen-lIdx+1;
    end;
  end;

Procedure TChatWin.KeyInput(Key: Word);
  var   Ofs0: Word;
     Idx,Len: Word;
        bChg: Boolean;
        Buf0: String;
  begin
  bChg:=False;
  if (Key=21) or (Key=13) or ((Key>=32) and (Key<=255)) then
    begin
    if (Key=32) or (Key=13) then HideCursor;
    Ofs0:=GetMaxYOffset;
    Buf0:=Buffer;
    if Length(Buffer)>=255 then
      begin
      GetLineIndex(1,Idx,Len);
      Delete(Buffer,Idx,Len);
      end;
    Insert(Char(Key),Buffer,255);
    bChg:=True;
    end;
  if (Key=8) and (Length(Buffer)>0) then
    begin
    HideCursor;
    Ofs0:=GetMaxYOffset;
    Buf0:=Buffer;
    Dec(Buffer[0]);
    bChg:=True;
    end;
  if bChg then
    begin;
    if Ofs0<>GetMaxYOffset then { alles neu malen }
      begin
      DrawAll;
      end
    else begin
      {Color:=Color xor $10;
      DrawAll;
      Color:=Color xor $10;}
      DrawDiff(Buf0);
      end;
    ShowCursor;
    end;
{  Delay(200);}
  end;

Const pLocal: PChatWin=Nil;
      pRemot: PChatWin=Nil;

Procedure DoChat(Key: Word);
  begin
  {if (pLocal=Nil) or (pRemot=Nil) then
    begin
    TextAttr:=$19;
    GotoXY(31,21); Write('C');
    GotoXY(31,22); Write('H');
    GotoXY(31,23); Write('A');
    GotoXY(31,24); Write('T');
    end;}
  if pLocal=Nil then
    begin
    pLocal:=New(PChatWin);
    if pLocal<>Nil then
      begin
      pLocal^.Init;
      pLocal^.PosX:=1;
      pLocal^.PosY:=21;
      pLocal^.Wdt:=30;
      pLocal^.Hgt:=4;
      pLocal^.DrawAll;
      end;
    end;
  if pRemot=Nil then
    begin
    pRemot:=New(PChatWin);
    if pRemot<>Nil then
      begin
      pRemot^.Init;
      pRemot^.PosX:=32;
      pRemot^.PosY:=21;
      pRemot^.Wdt:=29;
      pRemot^.Hgt:=4;
      pRemot^.DrawAll;
      end;
    end;
  if LastInputDos{<>Shift} then
    begin
    if pRemot<>Nil then
      begin
      pRemot^.KeyInput(Key);
      end;
    end
  else begin
    if pLocal<>Nil then
      begin
      pLocal^.KeyInput(Key);
      end;
    end;
  end;

end.
