(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

unit Utils;

{$I kwirkdefs.inc}

interface

Function CheckTimeout(Tol: LongInt): Boolean;
Procedure TriggerTimeout;
Procedure Init1;
Procedure Init3;
Procedure InitError(s: String; Title,Help: Boolean);

implementation

uses
  CrtUnit, GraphUnit,
  Compat, DefBase, Renderer;

Procedure InitError(s: String; Title,Help: Boolean);
  begin
  {$if declared(TextMode)}
  if TextModeAtProgrammStart>=0 then TextMode(TextModeAtProgrammStart);
  {$endif}
  if not Title then begin TextColor(LightGray); TextBackground(Black) end;
  if Title then
    begin
    writeln('The Quest of Kwirk''s Castle             PC-Version by Joe M.  1991');
    writeln;
    end;
  Writeln(s);
  if Help then
    begin
    writeln;
    writeln('Enter  Kwirk ?  for help');
    end;
  Halt;
  end;

Procedure Init1;
  begin
  if sConfig.Screen1=Detect then
    begin
    DetectGraph(sConfig.Screen1,sConfig.Res1);
    if sConfig.Screen1=Cga then sConfig.Res1:=CgaC1;
    if sConfig.Screen1=Ega64 then sConfig.Res1:=Ega64Lo;
    end;
  if (sConfig.Screen1=Vga)      and (sConfig.Res1=VgaHi)      then ImgFN:='KwirkVga.Img' else
  if (sConfig.Screen1=IBM8514)  then ImgFN:='KwirkVga.Img' else
{  if (sConfig.Screen1=VESA16)   then ImgFN:='KwirkVga.Img' else{}
  if (sConfig.Screen1=Ega)      and (sConfig.Res1=EgaHi)      then ImgFN:='KwirkEga.Img' else
  if (sConfig.Screen1=Ega)      and (sConfig.Res1=EgaLo)      then ImgFN:='KwirkELo.Img' else
  if (sConfig.Screen1=MCga)     and (sConfig.Res1=MCgaHi)     then ImgFN:='KwirkMCg.Img' else
  if (sConfig.Screen1=HercMono) and (sConfig.Res1=HercMonoHi) then ImgFN:='KwirkHrc.Img' else
  if (sConfig.Screen1=Cga)      and (sConfig.Res1=CgaHi)      then ImgFN:='KwirkCHi.Img' else
  if (sConfig.Screen1=Cga)      and (sConfig.Res1 in [CgaC0..CgaC3]) then ImgFN:='KwirkCga.Img' else
    ImgFN := '';
    //if not ParamHelp then InitError('Sorry, graphics-card or graphics-mode not supported in this version.',True,True);
  if QuestMakerFlag and (sConfig.Screen1 in [CGA,MCGA]) and (sConfig.Res1<CgaHi) then
    InitError('Need high resolution to run the QuestMaker.',True,True);
  end;

Procedure Init3;
  var xasp,yasp: word;
      MaxX,MaxY: Int16;
            i,j: LongInt;
          t0,t1: Real;
  begin
  ChgPalette:=False;
  if not TextKwirk then begin
    if not InitGem('') then Halt;

    if ImgFn = '' then
      ImgFn := 'ptcimages.img';

    if not LoadImages(ImgFn) then
      begin
      ExitGem;
      InitError('IO-error while reading image file ['+ImgFn+']',False,False);
      end;
  end;
  KwirkXSpeed:=MS2Tick(Round(100/ImgXsize));
  KwirkYSpeed:=MS2Tick(Round(100/ImgYsize));
  JumpSpeed  :=MS2Tick(40);
  WaterSpeed :=MS2Tick(150);
  JoeMSpeed  :=MS2Tick(400);

  if KwirkSpeed<0 then KwirkSpeed:=0;
  if KwirkSpeed>0.9 then KwirkSpeed:=0.9;
  if KwirkSpeed=0 then
    begin
    QuickMoving:=True;
    KwirkBumpSteps:=0
    end
  else begin
    KwirkXSpeed:=MS2Tick(Round(1000*KwirkSpeed/ImgXsize));
    KwirkYSpeed:=MS2Tick(Round(1000*KwirkSpeed/ImgYsize));
    end;
  end;

Const StartTime: LongInt =0;
    TriggerTime: LongInt =0;

Function CheckTimeout(Tol: LongInt): Boolean;
  begin
  CheckTimeout:=False;
  if (MaxTime<>0) or (Timeout<>0) then
    begin
    if StartTime=0 then
      begin
      StartTimer(StartTime);
      StartTimer(TriggerTime);
      end
    else begin
      if (MaxTime<>0) and (ReadTimerMS(StartTime) div 1000 > MaxTime+Tol) then CheckTimeout:=True;
      if (TimeOut<>0) and (ReadTimerMS(TriggerTime) div 1000 > Timeout+Tol) then CheckTimeout:=True;
      end;
    end;
  end;

Procedure TriggerTimeout;
  begin
  if Timeout<>0 then
    begin
    StartTimer(TriggerTime);
    end;
  end;

end.

