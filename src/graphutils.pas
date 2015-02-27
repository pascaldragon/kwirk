(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

unit GraphUtils;

{$I kwirkdefs.inc}

interface

Procedure ClrOutTextXY(x,y: LongInt; s: String);
Procedure OutTextXYs(x,y: LongInt; s: String; c2,c1: Int16);
Procedure OutTextXY(x,y: LongInt; s: String);
Procedure XPum(var a; Size: Word; Lines,OneTime:Int16; var y,Offset: Int16);
Procedure SetTextStyle(Font,Direction,CharSize: Word);

implementation

uses
  GraphUnit, Compat, DefBase;

Function VgaX(x: LongInt): LongInt; begin VgaX:=(x*(GetMaxX+1)) div 640 end;
Function VgaY(y: LongInt): LongInt; begin VgaY:=(y*(GetMaxY+1)) div 480 end;
Procedure Bar(x1,y1,x2,y2: Int16);
  begin GraphUnit.Bar(VgaX(x1),VgaY(y1),VgaX(x2),VgaY(y2)) end;


Procedure SetTextStyle(Font, Direction, CharSize: Word);
  var m,d: Int16;
  begin
  SetUserCharSize(CharSize,1,CharSize,1);
  SetUserCharSize(1,2,1,4);
  if (GetMaxY<200) and (CharSize<=1) then begin GraphUnit.SetTextStyle(DefaultFont,Direction,1); exit end;
  Case CharSize of
    1: begin m:=3; d:=5 end;
    2: begin m:=2; d:=3 end;
    3: begin m:=3; d:=4 end;
    4: begin m:=1; d:=1 end;
    end;
  SetUserCharSize(m*((GetMaxX+1) div 20),d*32,m*((GetMaxY+1) div 20),d*24);
  GraphUnit.SetTextStyle(Font,Direction,0);
  end;

Procedure OutTextXYs(x, y: LongInt; s: String; c2, c1: Int16);
  begin
  if x>500 then
    begin
    x:=GetMaxX-(((639-x)*(GetMaxX+1)) div 640);
    if (GetMaxX<320) and (x<315) then Dec(x,20);
    if (iConfig.Screen1=HercMono) and (x<765) then Dec(x,40);
    end;
  y:=VgaY(y);
  SetColor(CalcColor(c1)); GraphUnit.OutTextXY(x+1,y+1,s);
  SetColor(CalcColor(c2)); GraphUnit.OutTextXY(x,y,s);
  end;

Procedure ClrOutTextXY(x, y: LongInt; s: String);
  var  ti: TextSettingsType;
    tw,th: Int16;
        i: Int16;
  begin
  if x>500 then
    begin
    x:=GetMaxX-(((639-x)*(GetMaxX+1)) div 640);
    if (GetMaxX<320) and (x<315) then Dec(x,20);
    if (iConfig.Screen1=HercMono) and (x<766) then Dec(x,40);
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
  GraphUnit.Bar(x,y+1*ord(ti.Font<>DefaultFont),
            x+tw+4*ord(ti.Font<>DefaultFont),y+th+5*ord(ti.Font<>DefaultFont));
  end;

Procedure OutTextXY(x, y: LongInt; s: String);
  begin
  if x>500 then
    begin
    x:=GetMaxX-(((639-x)*(GetMaxX+1)) div 640);
    if (GetMaxX<320) and (x<315) then Dec(x,20);
    if (iConfig.Screen1=HercMono) and (x<765) then Dec(x,40);
    end;
  GraphUnit.OutTextXY(x,VgaY(y),s);
  end;

Procedure XPum(var a; Size: Word; Lines, OneTime: Int16; var y,
  Offset: Int16);
  Type refStr = ^String;
  var    ti: TextSettingsType;
          i: Int16;
         sp: refStr;
    w,w1,l1: Int16;
  begin
  if Lines=0 then exit;
  SetTextJustify(LeftText,TopText);
  if DefaultSpeedFont then SetTextDefault else SetTextStyle(TriplexFont,HorizDir,1);
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

end.

