(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

{$A-,B-,E+,F-,I-,N+,O-,R-,S+,V-}
{.$M 65520,0,655360}
{M 8000,0,655360}
Program Kwirk; { " The Quest of Kwirk's Castle " }
{ $D-,L-}

uses Crt, ptcgraph, {GemBase,} {Str2Num,} {GemInit,}
     {StdSubs,} {vStrSubs,} {Num2Str,} DefBase, QMake, Misc, PlayKwrk, JME_Demo, {Timer, }KW_Snd, Compat;

Procedure WriteSyntax(Const Fehler: String);
  Function Bool2OnOff(a: Boolean): String;
    begin if a then Bool2OnOff:='On' else Bool2OnOff:='Off' end;

  begin
  if not DosVideo then ForceVideo:=True;
  TextColor(LightCyan);
  writeln('The Quest of Kwirk''s Castle             PC-Version by Joe M.  1991');
  if Fehler<>'' then
    begin
    TextColor(Red);
    Writeln('Fehler: ',Fehler);
    end;
  TextColor(Cyan);
  writeln('usage:   Kwirk [<FileName>] {/<Option>}');
{  writeln;
  writeln('<FileName>: Name of a Maze-File, e.g. GoingUp1, Heading1, ...');
}{  writeln;}
  writeln('available Options:');
  writeln('  WtWOn/WtWOff: Connect water to walls                (Default ',Bool2OnOff(WaterToWall),')');
  writeln('   ErOn/ErOff : Draw a radius to the corners          (Default ',Bool2OnOff(EckenRadius),')');
  writeln('   RrOn/RrOff : Draw a radius to the outside margins  (Default ',Bool2OnOff(RandRadius),')');
  writeln('        S<n>  : Set the Kwirk-Speed (0=fastest..9)    (Default ',round(10*KwirkSpeed):2,')');
  writeln('        B<n>  : Set the bumping-distance (0=none)     (Default ',KwirkBumpSteps:2,')');
  writeln('        M     : Enter the Kwirk QuestMaker (to design your own quests)');
(*writeln;*)
  writeln('  VGA         :      VGA-Mode 640x480, 16 Colors');
  writeln('  EGA         :      EGA-Mode 640x350, 16 Colors');
  writeln('  EGALo       :      EGA-Mode 640x200, 16 Colors');
  writeln('  MCGA        :     MCGA-Mode 640x480, Monochrome');
  writeln('  CGAC0,CGAC1,CGAC2,CGAC3: CGA-Mode 320x200,  4 Colors');
  writeln('  CGAHi       :      CGA-Mode 640x200, Monochrome');
  writeln('  Herc        : Hercules-Mode 768x348, Monochrome');
{  writeln('  Text        : TextMode');}
  writeln('  Ansi        : Ansi-Output (force TextMode)');
  writeln('  MergeIO     : (if TextMode) Merge Dos and BIOS IO (Mailbox!)');
  writeln('  User<Name>  : UserName for Auto-Savegame (max. 8 chars)');
  writeln('  Timeout<sec>: Timeout for Mailbox-Game in sec');
  writeln('  MaxTime<sec>: Max GameTime for Mailbox-Game in sec');
{  writeln;}
(*  writeln('If you think this game is ok, please send '+DMStr+' to');
  writeln;
  writeln('                        J. A. Merten      ');
  writeln('                        Feldspatweg 91    ');
  writeln('                        W-1000 Berlin 47 ');
  writeln('                        Germany           ');
  writeln;                                              *)
  if ImgFN=''
    then write('Graphics-card or -mode not supported!  ')
    else write('Reqired ImageFile is [',ImgFn,']  ');
  writeln('For qu call:  Germany  030 - 762 03 22-1');
  Halt;
  end;

Procedure GetParameters;
  var i: integer;
      s: String;
  begin
  i:=1;
  while i<=ParamCount do
    begin
    s:=ParamStr(i);
    if s='?' then ParamHelp:=True;
    if s[1] in ['-','/']
      then begin
        Delete(s,1,1);
        vUpcaseStr(s);
        if s='?' then ParamHelp:=True else
        if s='WTWON' then WaterToWall:=True else
        if s='WTWOFF' then WaterToWall:=False else
        if s='ERON' then EckenRadius:=True else
        if s='EROFF' then EckenRadius:=False else
        if s='RRON' then RandRadius:=True else
        if s='RROFF' then RandRadius:=False else
        if s='TIME' then ShowMovingTime:=True else
        if s='M' then QuestMakerFlag:=True else
        {$ifdef enable}
        if s='VGA'   then begin sConfig.Screen1:=Vga;      sConfig.Res1:=VgaHi      end else
        if s='EGA'   then begin sConfig.Screen1:=Ega;      sConfig.Res1:=EgaHi      end else
        if s='EGALO' then begin sConfig.Screen1:=Ega;      sConfig.Res1:=EgaLo      end else
        if s='MCGA'  then begin sConfig.Screen1:=MCga;     sConfig.Res1:=MCgaHi     end else
        if s='HERC'  then begin sConfig.Screen1:=HercMono; sConfig.Res1:=HercMonoHi end else
        if s='CGA'   then begin sConfig.Screen1:=Cga;      sConfig.Res1:=CgaC1      end else
        if s='CGAC0' then begin sConfig.Screen1:=Cga;      sConfig.Res1:=CgaC0      end else
        if s='CGAC1' then begin sConfig.Screen1:=Cga;      sConfig.Res1:=CgaC1      end else
        if s='CGAC2' then begin sConfig.Screen1:=Cga;      sConfig.Res1:=CgaC2      end else
        if s='CGAC3' then begin sConfig.Screen1:=Cga;      sConfig.Res1:=CgaC3      end else
        if s='CGAHI' then begin sConfig.Screen1:=Cga;      sConfig.Res1:=CgaHi      end else
        {$endif}
        { if copy(s,1,1)='I' then ImgFN:=Copy(s,2,255)+'.Img' else }
        if copy(s,1,1)='S' then begin KwirkSpeed:=Str2Int(Copy(s,2,255))/10 end else
        if copy(s,1,1)='B' then KwirkBumpSteps:=Str2Int(Copy(s,2,255)) else
        if copy(s,1,1)='R' then Room:=Str2Int(Copy(s,2,255)) else
        if s='TEXT' then begin TextKwirk:=True end else
        if s='ANSI' then begin TextKwirk:=True; DosVideo:=True; AnsiVideo:=True end else
        if s='MERGEIO' then begin CopyVideo:=True; CopyInput:=True; end else
        if copy(s,1,3)='COM' then ComPort:=Str2Int(Copy(s,4,255)) else
        if copy(s,1,7)='TIMEOUT' then TimeOut:=Str2Int(Copy(s,8,255)) else
        if copy(s,1,7)='MAXTIME' then MaxTime:=Str2Int(Copy(s,8,255)) else
        if copy(s,1,4)='USER' then
          begin
          UserName:=Copy(s,5,8);
          if (Length(UserName)>0) and (UserName[1] in [':','=']) then Delete(UserName,1,1);
          end else
          { InitError('Invalid Option: '+s,True,True);{}
        end
      else begin
        MazFN:=s;
        if Pos('.',MazFN)=0 then MazFN:=s+'.Maz';
        end;
    inc(i)
    end;
  if ComPort<>0 then
    begin
    TextKwirk:=True;
    DosVideo:=True;
    AnsiVideo:=True;
    end;
  if AnsiVideo then
    begin
    DosInput:=True;
    {$ifdef enable}
    EndeAttr:=7;
    {$endif}
    end;
{  if DosVideo then DirectVideo:=False;}
  if TextKwirk then
    begin
    KwirkSpeed:=0;
    MazeYOffs:=1;
    end;
  end;

Procedure PlayMazeFile;
  var bMadeIt: Boolean;
      bSkipIt: Boolean;
      bSkipBack: Boolean;

  begin
  if UserName<>'' then Cfg.WriteKeyName('LastQuest',MazFN);
  if not LoadMazes(MazFN) then
    begin
    ExitGem;
    InitError('IO-error while reading the maze file ['+MazFn+']',False,False);
    end;
  WriteLevel(QuestName);
  repeat
    Room:=1;
    if UserName<>'' then Room:=GetNextRoom;
    if not TextKwirk then Room:=RoomMenue(Room);
    if Room>nMazes then Room:=1;
    if Room>0 then
      begin
      LevelStartTime:=round(rTime);
      WriteHelpKey;
      repeat
        WriteMazeNr(Room);
        bMadeIt:=PlayKwirk(Mazes[Room]);
        bSkipIt:=(LastKey=KeyTb) or (LastKey=Ord('+'));
        bSkipBack:=(LastKey=ShfTb) or (LastKey=Ord('-'));
        if bMadeIt and (UserName<>'') then
          begin
          AddRoomMade(Room);
          Room:=GetNextRoom;
          end
        else begin
          if bMadeIt then Inc(Room);
          if bSkipIt and (Room<nMazes) then Inc(Room);
          if bSkipBack and (Room>1) then Dec(Room);
          end;
      until (Room>nMazes) or (not bMadeIt and not bSkipIt and not bSkipBack);
      ClearHelpKey;
      end;
  until TextKwirk or (Room=0) or (Room>nMazes) or (LastKey=KeyF3) or (LastKey=Alt_X);
  end;

var T: LongInt;
  bGivenMaze: Boolean;
begin
FileMode:=0;
Randomize;
GetParameters;
Init1;
if ParamHelp then begin WriteSyntax(''); exit end;
{if Random(2)=0
  then PlayFile('Sonata.CMF')
  else PlayFile('WillTell.CMF');{}
{PlayFile('*.CMF');{}
ShowJME;
if (LastKey=-45) or (LastKey=Escap) then Halt;
Init2; { Speicher fÅr Images allokieren }
if not TextKwirk then
  begin
  if not LoadImages(ImgFn) then
    begin
    ExitGem;
    InitError('IO-error while reading image file ['+ImgFn+']',False,False);
    end;
  end;
ClrScr;
Init3; { Grafik und Speed initiallisieren }
Cfg.Init;
if (UserName<>'') and (Pos('.',UserName)=0) then Insert('.Sav',UserName,255);
Cfg.SetFilename(UserName);
if UserName<>'' then Cfg.SetAktGroupName('Kwirk''s Castle SavedGame');
if QuestMakerFlag and not TextKwirk then QuestMaker;
if not TextKwirk then SetTextStyle(GothicFont,HorizDir,2);

StartTimer(T);
WriteTitle;
DefaultSpeedFont:=ReadTimerMS(T)>400; { wenn WriteTitle lÑnger als 0.4s dauerte }
if ShowMovingTime then begin GotoXY(1,8); write('Texttime: ', ReadTimerMS(T):8) end;
WriteLevel('1991 by Joe M.   ');

bGivenMaze:=MazFN<>'';
if not bGivenMaze then
  begin
  if UserName<>'' then
    begin
    Cfg.ReadKeyName('LastQuest',MazFN);
    end;
  if MazFN='' then
    if TextKwirk then MazFN:='GoingUp1.Maz';
  end;
repeat
  if not bGivenMaze and not TextKwirk then
    MazFN:=MazeMenue(MazFN);
  //vUpcaseStr(MazFN);
  if MazFN<>'' then
    begin
    PlayMazeFile;
    if not TextKwirk then
      if Room>nMazes then begin Room:=1; Inc(MazeNr); MazFN:='.' end;
    end;
until (MazFN='') or (LastKey=KeyF3) or (LastKey=ALT_X) or bGivenMaze or TextKwirk;
{if not TextKwirk then{} ExitGem;
Cfg.Done;
if not TextKwirk then
  begin
  if (TextModeAtProgrammStart>=0) then TextMode(TextModeAtProgrammStart);
  end
else begin
  NormVideo;
  Write(' ');
  ClrScr;
  end;
GotoXY(1,1); TextColor(White);
writeln('The Quest of Kwirk''s Castle             PC-Version by Joe M.  1991');
NormVideo;
writeln;
end.