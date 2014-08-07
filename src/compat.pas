(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

unit Compat;

{$mode objfpc}

interface

function Int2StrL(aValue, aLength: Integer): String; inline;
function Int2Str(aValue: Integer): String; inline;
function Str2Int(aStr: String): Integer; inline;

procedure vUpcaseStr(var aStr: String); inline;

procedure IncMouseHide;
procedure DecMouseHide;

procedure StartTimer(aTime: Integer);
function ReadTimerMS(aTime: Integer): Integer;
procedure WaitTimerTick(aTime: Integer; aJump: Integer);
function ReadTimerTick(aTime: Integer): Integer;

procedure SetTextDefault;

function StringInput(aArg1, aArg2: Integer; aLablel: String;
  var aValue: String; aMaxLength: Integer; aArg3: Integer): Boolean;

procedure MousePos(aX, aY: Integer);
function MouseButton: Byte;
procedure PushMouse;
procedure PopMouse;
procedure MouseShape(aShape: Integer);

function ReadKey2: Word;

const
  HoleCrossHair = 1;

  KeyF1 = 1;
  KeyF2 = 2;
  KeyF3 = 3;
  KeyF4 = 4;
  KeyF5 = 5;
  KeyF6 = 6;
  KeyF7 = 7;
  KeyF8 = 8;
  KeyF9 = 9;
  KeyTb = 20;
  ShfTb = 21;
  Alt_X = 22;

var
  AnsiVideo: Boolean = False;
  CopyVideo: Boolean = False;
  CopyInput: Boolean = False;
  DosInput: Boolean = False;
  DosVideo: Boolean = False;
  ForceVideo: Boolean = False;
  Escap: Word = 0;
  KbdRepeated: Boolean = False;
  LastInputDos: Boolean = False;
  rTime: Single = 0;

implementation

uses
  sysutils, crt;

function Int2StrL(aValue, aLength: Integer): String;
begin
  Result := Copy(IntToStr(aValue), 1, aLength);
end;

function Int2Str(aValue: Integer): String;
begin
  Result := IntToStr(aValue);
end;

function Str2Int(aStr: String): Integer;
begin
  Result := StrToInt(aStr);
end;

procedure vUpcaseStr(var aStr: String);
begin
  aStr := UpperCase(aStr);
end;

procedure IncMouseHide;
begin

end;

procedure DecMouseHide;
begin

end;

procedure StartTimer(aTime: Integer);
begin

end;

function ReadTimerMS(aTime: Integer): Integer;
begin

end;

procedure WaitTimerTick(aTime: Integer; aJump: Integer);
begin

end;

function ReadTimerTick(aTime: Integer): Integer;
begin

end;

procedure SetTextDefault;
begin

end;

function StringInput(aArg1, aArg2: Integer; aLablel: String;
  var aValue: String; aMaxLength: Integer; aArg3: Integer): Boolean;
begin

end;

procedure MousePos(aX, aY: Integer);
begin

end;

function MouseButton: Byte;
begin

end;

procedure PushMouse;
begin

end;

procedure PopMouse;
begin

end;

procedure MouseShape(aShape: Integer);
begin

end;

function ReadKey2: Word;
begin
  Result := Word(ReadKey);
end;

end.

