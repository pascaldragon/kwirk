(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

unit Compat;

{$define use_objfpc}
{$I kwirkdefs.inc}

interface

uses
  GraphUnit, CrtUnit,
  Config;

{$if not declared(ColorType)}
type
  ColorType = Word;
{$endif}

function Int2StrL(aValue, aLength: Integer): String; inline;
function Int2Str(aValue: Integer): String; inline;
function Str2Int(aStr: String): Integer; inline;

procedure vUpcaseStr(var aStr: String); inline;

procedure IncMouseHide;
procedure DecMouseHide;

procedure StartTimer(var aTime: Integer);
function ReadTimerMS(var aTime: Integer): Integer;
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

function CalcColor(aColor: ColorType): ColorType;

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

{$ifdef DefineColors}
const
{ Foreground and background color constants }
  Black         = 0;
  Blue          = 1;
  Green         = 2;
  Cyan          = 3;
  Red           = 4;
  Magenta       = 5;
  Brown         = 6;
  LightGray     = 7;

{ Foreground color constants }
  DarkGray      = 8;
  LightBlue     = 9;
  LightGreen    = 10;
  LightCyan     = 11;
  LightRed      = 12;
  LightMagenta  = 13;
  Yellow        = 14;
  White         = 15;
{$endif}

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
  iConfig: TGraphConfig absolute sConfig;

implementation

uses
  sysutils;

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

function ReadTimerMS(var aTime: Integer): Integer;
var
  newtime: Integer;
begin
  newtime := Trunc((Now - Date) * 24 * 60 * 60 * 1000);
  Result := newtime - aTime;
  aTime := newtime;
end;

procedure WaitTimerTick(aTime: Integer; aJump: Integer);
begin
  Sleep(aJump);
end;

function ReadTimerTick(aTime: Integer): Integer;
begin
  Result := Trunc((Now - Date) * 24 * 60 * 60 * 1000) - aTime;
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
  InitGraph(sConfig.Screen1, sConfig.Res1, '.');
  Result := GraphResult = grOk;
end;

procedure ExitGem;
begin
  Closegraph;
end;

function CalcColor(aColor: ColorType): ColorType;
type
  TRGBColor = record
    Red: Byte;
    Green: Byte;
    Blue: Byte;
  end;

const
  EightBitColors: array[0..255] of TRGBColor = (
   (Red:   0;Green:   0;Blue:   0),
   (Red:   0;Green:   0;Blue: 168),
   (Red:   0;Green: 168;Blue:   0),
   (Red:   0;Green: 168;Blue: 168),
   (Red: 168;Green:   0;Blue:   0),
   (Red: 168;Green:   0;Blue: 168),
   (Red: 168;Green:  84;Blue:   0),
   (Red: 168;Green: 168;Blue: 168),
   (Red:  84;Green:  84;Blue:  84),
   (Red:  84;Green:  84;Blue: 252),
   (Red:  84;Green: 252;Blue:  84),
   (Red:  84;Green: 252;Blue: 252),
   (Red: 252;Green:  84;Blue:  84),
   (Red: 252;Green:  84;Blue: 252),
   (Red: 252;Green: 252;Blue:  84),
   (Red: 252;Green: 252;Blue: 252),
   (Red:   0;Green:   0;Blue:   0),
   (Red:  20;Green:  20;Blue:  20),
   (Red:  32;Green:  32;Blue:  32),
   (Red:  44;Green:  44;Blue:  44),
   (Red:  56;Green:  56;Blue:  56),
   (Red:  68;Green:  68;Blue:  68),
   (Red:  80;Green:  80;Blue:  80),
   (Red:  96;Green:  96;Blue:  96),
   (Red: 112;Green: 112;Blue: 112),
   (Red: 128;Green: 128;Blue: 128),
   (Red: 144;Green: 144;Blue: 144),
   (Red: 160;Green: 160;Blue: 160),
   (Red: 180;Green: 180;Blue: 180),
   (Red: 200;Green: 200;Blue: 200),
   (Red: 224;Green: 224;Blue: 224),
   (Red: 252;Green: 252;Blue: 252),
   (Red:   0;Green:   0;Blue: 252),
   (Red:  64;Green:   0;Blue: 252),
   (Red: 124;Green:   0;Blue: 252),
   (Red: 188;Green:   0;Blue: 252),
   (Red: 252;Green:   0;Blue: 252),
   (Red: 252;Green:   0;Blue: 188),
   (Red: 252;Green:   0;Blue: 124),
   (Red: 252;Green:   0;Blue:  64),
   (Red: 252;Green:   0;Blue:   0),
   (Red: 252;Green:  64;Blue:   0),
   (Red: 252;Green: 124;Blue:   0),
   (Red: 252;Green: 188;Blue:   0),
   (Red: 252;Green: 252;Blue:   0),
   (Red: 188;Green: 252;Blue:   0),
   (Red: 124;Green: 252;Blue:   0),
   (Red:  64;Green: 252;Blue:   0),
   (Red:   0;Green: 252;Blue:   0),
   (Red:   0;Green: 252;Blue:  64),
   (Red:   0;Green: 252;Blue: 124),
   (Red:   0;Green: 252;Blue: 188),
   (Red:   0;Green: 252;Blue: 252),
   (Red:   0;Green: 188;Blue: 252),
   (Red:   0;Green: 124;Blue: 252),
   (Red:   0;Green:  64;Blue: 252),
   (Red: 124;Green: 124;Blue: 252),
   (Red: 156;Green: 124;Blue: 252),
   (Red: 188;Green: 124;Blue: 252),
   (Red: 220;Green: 124;Blue: 252),
   (Red: 252;Green: 124;Blue: 252),
   (Red: 252;Green: 124;Blue: 220),
   (Red: 252;Green: 124;Blue: 188),
   (Red: 252;Green: 124;Blue: 156),
   (Red: 252;Green: 124;Blue: 124),
   (Red: 252;Green: 156;Blue: 124),
   (Red: 252;Green: 188;Blue: 124),
   (Red: 252;Green: 220;Blue: 124),
   (Red: 252;Green: 252;Blue: 124),
   (Red: 220;Green: 252;Blue: 124),
   (Red: 188;Green: 252;Blue: 124),
   (Red: 156;Green: 252;Blue: 124),
   (Red: 124;Green: 252;Blue: 124),
   (Red: 124;Green: 252;Blue: 156),
   (Red: 124;Green: 252;Blue: 188),
   (Red: 124;Green: 252;Blue: 220),
   (Red: 124;Green: 252;Blue: 252),
   (Red: 124;Green: 220;Blue: 252),
   (Red: 124;Green: 188;Blue: 252),
   (Red: 124;Green: 156;Blue: 252),
   (Red: 180;Green: 180;Blue: 252),
   (Red: 196;Green: 180;Blue: 252),
   (Red: 216;Green: 180;Blue: 252),
   (Red: 232;Green: 180;Blue: 252),
   (Red: 252;Green: 180;Blue: 252),
   (Red: 252;Green: 180;Blue: 232),
   (Red: 252;Green: 180;Blue: 216),
   (Red: 252;Green: 180;Blue: 196),
   (Red: 252;Green: 180;Blue: 180),
   (Red: 252;Green: 196;Blue: 180),
   (Red: 252;Green: 216;Blue: 180),
   (Red: 252;Green: 232;Blue: 180),
   (Red: 252;Green: 252;Blue: 180),
   (Red: 232;Green: 252;Blue: 180),
   (Red: 216;Green: 252;Blue: 180),
   (Red: 196;Green: 252;Blue: 180),
   (Red: 180;Green: 252;Blue: 180),
   (Red: 180;Green: 252;Blue: 196),
   (Red: 180;Green: 252;Blue: 216),
   (Red: 180;Green: 252;Blue: 232),
   (Red: 180;Green: 252;Blue: 252),
   (Red: 180;Green: 232;Blue: 252),
   (Red: 180;Green: 216;Blue: 252),
   (Red: 180;Green: 196;Blue: 252),
   (Red:   0;Green:   0;Blue: 112),
   (Red:  28;Green:   0;Blue: 112),
   (Red:  56;Green:   0;Blue: 112),
   (Red:  84;Green:   0;Blue: 112),
   (Red: 112;Green:   0;Blue: 112),
   (Red: 112;Green:   0;Blue:  84),
   (Red: 112;Green:   0;Blue:  56),
   (Red: 112;Green:   0;Blue:  28),
   (Red: 112;Green:   0;Blue:   0),
   (Red: 112;Green:  28;Blue:   0),
   (Red: 112;Green:  56;Blue:   0),
   (Red: 112;Green:  84;Blue:   0),
   (Red: 112;Green: 112;Blue:   0),
   (Red:  84;Green: 112;Blue:   0),
   (Red:  56;Green: 112;Blue:   0),
   (Red:  28;Green: 112;Blue:   0),
   (Red:   0;Green: 112;Blue:   0),
   (Red:   0;Green: 112;Blue:  28),
   (Red:   0;Green: 112;Blue:  56),
   (Red:   0;Green: 112;Blue:  84),
   (Red:   0;Green: 112;Blue: 112),
   (Red:   0;Green:  84;Blue: 112),
   (Red:   0;Green:  56;Blue: 112),
   (Red:   0;Green:  28;Blue: 112),
   (Red:  56;Green:  56;Blue: 112),
   (Red:  68;Green:  56;Blue: 112),
   (Red:  84;Green:  56;Blue: 112),
   (Red:  96;Green:  56;Blue: 112),
   (Red: 112;Green:  56;Blue: 112),
   (Red: 112;Green:  56;Blue:  96),
   (Red: 112;Green:  56;Blue:  84),
   (Red: 112;Green:  56;Blue:  68),
   (Red: 112;Green:  56;Blue:  56),
   (Red: 112;Green:  68;Blue:  56),
   (Red: 112;Green:  84;Blue:  56),
   (Red: 112;Green:  96;Blue:  56),
   (Red: 112;Green: 112;Blue:  56),
   (Red:  96;Green: 112;Blue:  56),
   (Red:  84;Green: 112;Blue:  56),
   (Red:  68;Green: 112;Blue:  56),
   (Red:  56;Green: 112;Blue:  56),
   (Red:  56;Green: 112;Blue:  68),
   (Red:  56;Green: 112;Blue:  84),
   (Red:  56;Green: 112;Blue:  96),
   (Red:  56;Green: 112;Blue: 112),
   (Red:  56;Green:  96;Blue: 112),
   (Red:  56;Green:  84;Blue: 112),
   (Red:  56;Green:  68;Blue: 112),
   (Red:  80;Green:  80;Blue: 112),
   (Red:  88;Green:  80;Blue: 112),
   (Red:  96;Green:  80;Blue: 112),
   (Red: 104;Green:  80;Blue: 112),
   (Red: 112;Green:  80;Blue: 112),
   (Red: 112;Green:  80;Blue: 104),
   (Red: 112;Green:  80;Blue:  96),
   (Red: 112;Green:  80;Blue:  88),
   (Red: 112;Green:  80;Blue:  80),
   (Red: 112;Green:  88;Blue:  80),
   (Red: 112;Green:  96;Blue:  80),
   (Red: 112;Green: 104;Blue:  80),
   (Red: 112;Green: 112;Blue:  80),
   (Red: 104;Green: 112;Blue:  80),
   (Red:  96;Green: 112;Blue:  80),
   (Red:  88;Green: 112;Blue:  80),
   (Red:  80;Green: 112;Blue:  80),
   (Red:  80;Green: 112;Blue:  88),
   (Red:  80;Green: 112;Blue:  96),
   (Red:  80;Green: 112;Blue: 104),
   (Red:  80;Green: 112;Blue: 112),
   (Red:  80;Green: 104;Blue: 112),
   (Red:  80;Green:  96;Blue: 112),
   (Red:  80;Green:  88;Blue: 112),
   (Red:   0;Green:   0;Blue:  64),
   (Red:  16;Green:   0;Blue:  64),
   (Red:  32;Green:   0;Blue:  64),
   (Red:  48;Green:   0;Blue:  64),
   (Red:  64;Green:   0;Blue:  64),
   (Red:  64;Green:   0;Blue:  48),
   (Red:  64;Green:   0;Blue:  32),
   (Red:  64;Green:   0;Blue:  16),
   (Red:  64;Green:   0;Blue:   0),
   (Red:  64;Green:  16;Blue:   0),
   (Red:  64;Green:  32;Blue:   0),
   (Red:  64;Green:  48;Blue:   0),
   (Red:  64;Green:  64;Blue:   0),
   (Red:  48;Green:  64;Blue:   0),
   (Red:  32;Green:  64;Blue:   0),
   (Red:  16;Green:  64;Blue:   0),
   (Red:   0;Green:  64;Blue:   0),
   (Red:   0;Green:  64;Blue:  16),
   (Red:   0;Green:  64;Blue:  32),
   (Red:   0;Green:  64;Blue:  48),
   (Red:   0;Green:  64;Blue:  64),
   (Red:   0;Green:  48;Blue:  64),
   (Red:   0;Green:  32;Blue:  64),
   (Red:   0;Green:  16;Blue:  64),
   (Red:  32;Green:  32;Blue:  64),
   (Red:  40;Green:  32;Blue:  64),
   (Red:  48;Green:  32;Blue:  64),
   (Red:  56;Green:  32;Blue:  64),
   (Red:  64;Green:  32;Blue:  64),
   (Red:  64;Green:  32;Blue:  56),
   (Red:  64;Green:  32;Blue:  48),
   (Red:  64;Green:  32;Blue:  40),
   (Red:  64;Green:  32;Blue:  32),
   (Red:  64;Green:  40;Blue:  32),
   (Red:  64;Green:  48;Blue:  32),
   (Red:  64;Green:  56;Blue:  32),
   (Red:  64;Green:  64;Blue:  32),
   (Red:  56;Green:  64;Blue:  32),
   (Red:  48;Green:  64;Blue:  32),
   (Red:  40;Green:  64;Blue:  32),
   (Red:  32;Green:  64;Blue:  32),
   (Red:  32;Green:  64;Blue:  40),
   (Red:  32;Green:  64;Blue:  48),
   (Red:  32;Green:  64;Blue:  56),
   (Red:  32;Green:  64;Blue:  64),
   (Red:  32;Green:  56;Blue:  64),
   (Red:  32;Green:  48;Blue:  64),
   (Red:  32;Green:  40;Blue:  64),
   (Red:  44;Green:  44;Blue:  64),
   (Red:  48;Green:  44;Blue:  64),
   (Red:  52;Green:  44;Blue:  64),
   (Red:  60;Green:  44;Blue:  64),
   (Red:  64;Green:  44;Blue:  64),
   (Red:  64;Green:  44;Blue:  60),
   (Red:  64;Green:  44;Blue:  52),
   (Red:  64;Green:  44;Blue:  48),
   (Red:  64;Green:  44;Blue:  44),
   (Red:  64;Green:  48;Blue:  44),
   (Red:  64;Green:  52;Blue:  44),
   (Red:  64;Green:  60;Blue:  44),
   (Red:  64;Green:  64;Blue:  44),
   (Red:  60;Green:  64;Blue:  44),
   (Red:  52;Green:  64;Blue:  44),
   (Red:  48;Green:  64;Blue:  44),
   (Red:  44;Green:  64;Blue:  44),
   (Red:  44;Green:  64;Blue:  48),
   (Red:  44;Green:  64;Blue:  52),
   (Red:  44;Green:  64;Blue:  60),
   (Red:  44;Green:  64;Blue:  64),
   (Red:  44;Green:  60;Blue:  64),
   (Red:  44;Green:  52;Blue:  64),
   (Red:  44;Green:  48;Blue:  64),
   (Red:   0;Green:   0;Blue:   0),
   (Red:   0;Green:   0;Blue:   0),
   (Red:   0;Green:   0;Blue:   0),
   (Red:   0;Green:   0;Blue:   0),
   (Red:   0;Green:   0;Blue:   0),
   (Red:   0;Green:   0;Blue:   0),
   (Red:   0;Green:   0;Blue:   0),
   (Red:   0;Green:   0;Blue:   0));
var
  imgcol: TRGBColor;
begin
  //if sConfig.Screen1 = _PTC then begin
    if (aColor >= Low(EightBitColors)) and (aColor <= High(EightBitColors)) then
      imgcol := EightBitColors[aColor]
    else
      imgcol := EightBitColors[0];
    if GetMaxColor <= High(Word) then
      Result := (imgcol.red and $ff shr 3) shl (5 + 6) or
                  (imgcol.green and $ff shr 2) shl 5 or
                  (imgcol.blue and $ff shr 3)
    else
      Result := (LongInt(imgcol.Red and $ff) shl 16) or
                (LongInt(imgcol.Green and $ff) shl 8) or
                (LongInt(imgcol.Blue and $ff));
  {end else begin
    Result := aColor;
  end;}
end;

function ReadKey2: Word;
begin
  Result := Word(ReadKey);
end;

end.

