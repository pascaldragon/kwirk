(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

unit CrtUtils;

{$I kwirkdefs.inc}

interface

Procedure GotoFldXY(x,y: Int16);

{.$I KbdCodes.Pas}
Function KwirkReadKey: Word;
Function KwirkGetKey: Word;
Function KwirkKeyPressed: Boolean;
const LastKey: Word = 0;
Function LastChar: Char;
Procedure WaitKey;
Procedure ClearKbdBuffer;
Procedure ClearKbdRepeat;

implementation

uses
  CrtUnit, DefBase, Compat, Utils;

Procedure GotoFldXY(x, y: Int16);
  begin
  GotoXY((x-1)*3+1+MazeXoffs,y+MazeYoffs);
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

