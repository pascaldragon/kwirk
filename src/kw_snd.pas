(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

Unit KW_Snd;

interface

{uses MTyp,Dos,SB_Main,SB_Play,vStrSubs;}

Type VarStr=String[79];

Procedure PlayFile(FN: VarStr; Stop: Boolean);

implementation


Procedure PlayFile(FN: VarStr; Stop: Boolean);
  begin end; end.

  var SndDir: VarStr;
         Anz: Integer;
         Num: Integer;
         Typ: BlastArt;

  Function Count: Integer;
    var SR: SearchRec;
         i: Integer;
    begin
    i:=0;
    FindFirst(SndDir+FN,Archive,SR);
    while DosError=0 do
      begin
      Inc(i);
      FindNext(SR);
      end;
    Count:=i;
    end;

  Procedure GetOne(Num: Integer);
    var SR: SearchRec;
         i: Integer;
    begin
    i:=0;
    FindFirst(SndDir+FN,Archive,SR);
    while DosError=0 do
      begin
      Inc(i);
      if i=Num then
        begin
        FN:=SndDir+SR.Name;
        DosError:=18; {No More Files}
        end;
      FindNext(SR);
      end;
    end;

  Procedure PlayFile(FN: VarStr);
    var Typ: BlastArt;
    begin
    Typ:=GetSoundArt(FN);
    if (Typ<>saUkn) and Stop or ChanQuiet(Typ) then
      begin
      if PlayRecSoundFile(Typ,FN,False,True,False) then;
      end;
    end;

  begin
  SndDir:=ParamStr(0);
  while (SndDir<>'') and (SndDir[Length(SndDir)]<>'\') do Dec(SndDir[0]);
  Insert('Sound\',SndDir,255);
  Anz:=Count;
  if Anz>0 then
    begin
    Num:=Random(Count)+1;
    GetOne(Num);
    PlayFile(FN);
    end;
  end;

end.
