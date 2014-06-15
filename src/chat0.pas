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
       Procedure Draw;
       Procedure ShowCursor;
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
  Buffer:='aabbaabbaabbaa ccddccddccdd';
  Color:=$70;
  WordBreak:=True; {not implemented}
  end;

Procedure TChatWin.Done;
  begin
  end;

Procedure TChatWin.Draw;
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
    if y+nOfs>nAnz then TextAttr:=Color-$10;
    GetLineIndex(y+nOfs,i,n);
    if n>Wdt then n:=Wdt;
    if (n>0) and (Buffer[i+n-1]=#13) then Dec(n);
    GotoXY(PosX,PosY+y-1);
    if n>0 then Write(Copy(Buffer,i,n));
    if n<Wdt then Write('':Wdt-n);
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
    if (Len=Wdt) or (Buffer[Length(Buffer)]=#13) then
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
    if (Len=Wdt) or (Buffer[Length(Buffer)]=#13) then
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

Procedure TChatWin.GetWordPos(var Idx,Len: Word);
  var l: Byte absolute Buffer;
      i: Word;
  begin
  i:=Idx;
  if i=1 then i:=1;
  while (i<=l) and (Buffer[i] in [' ',#13]) do Inc(i);
  Idx:=i;
  while (i<=l) and not (Buffer[i] in [' ',#13]) do Inc(i);
  Len:=i-Idx;
  end;

Function TChatWin.GetLineCount: Word;
  var i: Integer;
      n: Integer;
      a: Integer;
     i0: Word; {Index des letzten Wortbeginns}
  begin
  GetLineCount:=0;
  if (Wdt=0) then Exit;
  n:=0;
  a:=0;
  i0:=0;
  for i:=1 to Length(Buffer) do
    begin
    if Buffer[i]=#13 then
      begin
      a:=0;
      Inc(n);
      i0:=0;
      end
    else begin
      if (a>0) and (Buffer[i-1]=' ') and (Buffer[i]<>' ') then i0:=i;
      Inc(a);
      if (a>Wdt+1) or ((a>Wdt) and not (Buffer[i] in [' ',#13])) then
        begin
        if WordBreak and (i0>1) then
          begin
          a:=i-i0+1;
          end
        else begin
          Dec(a,Wdt);
          end;
        Inc(n);
        i0:=0;
        end;
      end;
    end;
  if a>1 then Inc(n);
  GetLineCount:=n;
  end;

Procedure TChatWin.GetLineIndex(Num: Word; var Pos,Len: Word);
  var i: Integer;
      n: Integer;
      a: Integer;
     i0: Word; {Index des letzten Wortbeginns}
  begin
  Pos:=1; Len:=0;
  if (Wdt=0) then Exit;
  n:=0;
  a:=0;
  i:=1;
  i0:=0;
  while (i<=Length(Buffer)) and (n+1<Num) do
    begin
    if Buffer[i]=#13 then
      begin
      a:=0;
      Inc(n);
      i0:=0;
      end
    else begin
      if (a>0) and (Buffer[i-1]=' ') and (Buffer[i]<>' ') then i0:=i;
      Inc(a);
      if a>Wdt then
        begin
        if WordBreak and (i0>1) then
          begin
          a:=i-i0+1;
          end
        else begin
          Dec(a,Wdt);
          end;
        Inc(n);
        i0:=0;
        end;
      end;
    Inc(i);
    end;
  if n+1=Num then Dec(i,a);
  if i<=Length(Buffer) then
    begin
    Pos:=i;
    a:=0;
    i0:=0;
    while (i<=Length(Buffer)) and ((a<1) or (Buffer[i-1]<>#13)) and (a<=Wdt) do
      begin
      if (a>0) and (Buffer[i-1]=' ') and (Buffer[i]<>' ') then i0:=i;
      Inc(i);
      Inc(a);
      end;
    if (a>Wdt+1) or ((a>Wdt) and not (Buffer[Pos+a-1] in [' ',#13])) then
      begin
      if WordBreak and (i0>1) then
        begin
        Dec(a,i-i0+1);
        end
      else begin
        Dec(a,1);
        end;
      end;
    {if (i<=Length(Buffer)) and (Buffer[i]=#13) then Inc(a);}
    Len:=a;
    end;
  end;

Procedure TChatWin.KeyInput(Key: Word);
  var Idx,Len: Word;
  begin
  if (Key=21) or (Key=13) or ((Key>=32) and (Key<=255)) then
    begin
    if Length(Buffer)>=255 then
      begin
      GetLineIndex(1,Idx,Len);
      if Buffer[Idx+Len]=#13 then Inc(Len);
      Delete(Buffer,Idx,Len);
      end;
    Insert(Char(Key),Buffer,255);
    Draw;
    ShowCursor;
    end;
  if (Key=8) and (Length(Buffer)>0) then
    begin
    Dec(Buffer[0]);
    Draw;
    ShowCursor;
    end;
  end;

Const pLocal: PChatWin=Nil;
      pRemot: PChatWin=Nil;

Procedure DoChat(Key: Word);
  begin
  if pLocal=Nil then
    begin
    pLocal:=New(PChatWin);
    if pLocal<>Nil then
      begin
      pLocal^.Init;
      pLocal^.PosX:=2;
      pLocal^.PosY:=21;
      pLocal^.Wdt:=28;
      pLocal^.Hgt:=4;
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
      pRemot^.Wdt:=28;
      pRemot^.Hgt:=4;
      end;
    end;
  if LastInputDos then
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
