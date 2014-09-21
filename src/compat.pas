(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

unit Compat;

{$mode objfpc}

interface

uses
  ptcgraph,
  Config;

function Int2StrL(aValue, aLength: Integer): String; inline;
function Int2Str(aValue: Integer): String; inline;
function Str2Int(aStr: String): Integer; inline;

procedure vUpcaseStr(var aStr: String); inline;

procedure IncMouseHide;
procedure DecMouseHide;

procedure StartTimer(var aTime: Integer);
function ReadTimerMS(aTime: Integer): Integer;
procedure WaitTimerTick(aTime: Integer; aJump: Integer);
function ReadTimerTick(aTime: Integer): Integer;

function MS2Tick(aValue: Integer): Integer;

function rTime: Single;

procedure SetTextDefault;

function StringInput(aArg1, aArg2: Integer; aLablel: String;
  var aValue: String; aMaxLength: Integer; aArg3: Integer): Boolean;

procedure MousePos(aX, aY: Integer);
function MouseButton: Byte;
procedure PushMouse;
procedure PopMouse;
procedure MouseShape(aShape: Integer);

function InitGem(const aPath: String): Boolean;
procedure ExitGem;

function ReadKey2: Word;

const
  HoleCrossHair = 1;

  Escap = 27;
  CsrLf = 75;
  CsrUp = 72;
  CsrRg = 77;
  CsrDn = 80;
  CsrHm = 55;
  KeyTb = 9;
  KeyF1 = 59;
  KeyF2 = 60;
  KeyF3 = 61;
  KeyF4 = 62;
  KeyF5 = 63;
  KeyF6 = 64;
  KeyF7 = 65;
  KeyF8 = 66;
  KeyF9 = 67;
  ShfTb = 91;
  Alt_X = 45;

var
  AnsiVideo: Boolean = False;
  CopyVideo: Boolean = False;
  CopyInput: Boolean = False;
  DosInput: Boolean = False;
  DosVideo: Boolean = False;
  ForceVideo: Boolean = False;
  KbdRepeated: Boolean = False;
  LastInputDos: Boolean = False;
  ChgPalette: Boolean = False;

var
  sConfig: TGraphConfig = ( Screen1: Detect; Res1: Default );

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

procedure StartTimer(var aTime: Integer);
begin
  aTime := Trunc((Now - Date) * 24 * 60 * 60 * 1000);
end;

function ReadTimerMS(aTime: Integer): Integer;
begin
  Result := Trunc((Now - Date) * 24 * 60 * 60 * 1000 - aTime);
end;

procedure WaitTimerTick(aTime: Integer; aJump: Integer);
begin

end;

function ReadTimerTick(aTime: Integer): Integer;
begin
  Result := 1;
end;

function MS2Tick(aValue: Integer): Integer;
begin
  Result := aValue;
end;

function rTime: Single;
begin
  Result := Time * 24 * 3600;
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

function InitGem(const aPath: String): Boolean;
begin
  InitGraph(sConfig.Screen1, sConfig.Res1, '');
  Result := GraphResult = grOk;
end;

procedure ExitGem;
begin
  Closegraph;
end;

function ReadKey2: Word;
begin
  Result := Word(ReadKey);
end;

end.

