(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

unit JME_Demo;

{$I kwirkdefs.inc}
{$D+,L+} { $D-,L-}

interface

uses Crt, Misc, DefBase;

Procedure ShowJME;

implementation

Procedure SetColor(tc,bc: integer);
  begin
  if LastMode<>7 then begin TextColor(tc); TextBackground(bc); exit end;
  if tc>=Yellow then HighVideo else LowVideo;
  end;

Procedure WriteDienst(x,y,tc,bc: integer);
  begin
  SetColor(tc,bc);
  GotoXY(x,y+00); write(' - EDV-Service und -Beratung        ');
  GotoXY(x,y+01); write(' - Entwicklung und Vertrieb von     ');
  GotoXY(x,y+02); write('   Individual- und Standardsoftware ');
  GotoXY(x,y+03); write('   sowie von PC-Hardware            ');
  GotoXY(x,y+04); write('                                    ');
  GotoXY(x,y+05); write(' - technische Software              ');
  GotoXY(x,y+06); write('                                    ');
  GotoXY(x,y+07); write(' - kaufm„nnische Software           ');
  GotoXY(x,y+08); write('   Finanzbuchhaltung                ');
  GotoXY(x,y+09); write('   Kassenbuchfhrung                ');
  GotoXY(x,y+10); write('   Adreáverwaltung                  ');
  GotoXY(x,y+11); write('   Auftragsverwaltung               ');
  GotoXY(x,y+12); write('   ...                              ');
  end;

Procedure WriteAdresse(x,y,tc,bc: integer);
  begin
  SetColor(tc,bc);
  GotoXY(x,y+00); write(' JME Engineering              ');
  GotoXY(x,y+01); write(' Dipl. Inf. Joachim A. Merten ');
  GotoXY(x,y+02); write(' Mariendorfer Damm 373        ');
  GotoXY(x,y+03); write(' 12107 Berlin                 ');
  GotoXY(x,y+04); write(' Tel.: (030) 762 03 22 -1     ');
  GotoXY(x,y+05); write('');
  end;

Procedure WriteKnowHow(x,y,tc,bc: integer);
  begin
  SetColor(tc,bc);
  GotoXY(x,y+00); write(' Wenden Sie sich auch ');
  GotoXY(x,y+01); write(' in aussichtslosen    ');
  GotoXY(x,y+02); write(' F„llen an uns.       ');
  GotoXY(x,y+03); write(' Wo andere aufh”ren,  ');
  GotoXY(x,y+04); write(' fangen wir oftmals   ');
  GotoXY(x,y+05); write(' erst an.             ');
  end;

Procedure WriteJMELogo(x,y,tc,bc: integer);
  begin
  SetColor(tc,bc);
  GotoXY(x,y+00); write('  ÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄ  ');
  GotoXY(x,y+01); write('  ÄÄÄÄÄÄÄÙ         ÀÄÄÄÄÄÄÄ  ');
  end;

Procedure WriteNote(x,y,tc,bc: integer);
  begin
  SetColor(tc,bc);
  GotoXY(x,y+00); write(' Dieses Programm wurde von JME Engineering geschrieben und ');
  GotoXY(x,y+01); write(' darf beliebig kopiert und weitergegeben werden. Verkauf   ');
  GotoXY(x,y+02); write(' oder sonstige gewerbliche Nutzung ist jedoch untersagt.   ');
  GotoXY(x,y+03); write(' Lauff„hig mit CGA-, Hercules-, EGA- und VGA-Grafikkarten. ');
  end;

Procedure WritePressKey(x,y,tc1,bc1,tc2,bc2: integer);
  begin
  GotoXY(x,y);
  SetColor(tc1,bc1);
  write(' Drcken Sie eine Taste, um ');
  SetColor(tc2,bc2);
  write('The Quest of Kwirk''s Castle');
  SetColor(tc1,bc1);
  write(' zu starten. ');
  end;

Procedure WriteLoading(x,y,tc,bc: integer);
  begin
  GotoXY(x,y);
  SetColor(tc,bc);
  write('         Daten werden geladen  -  bitte einen Moment Geduld          ');
  end;

Procedure ShowJME;
  begin
  TextModeAtProgrammStart:=LastMode;
  {$ifdef enable}
  if VWdt<80 then TextMode(Co80);
  {$endif}
  TextColor(LightGray); TextBackground(Black); ClrScr;
  {HideTextCursor;}
  WriteJMELogo(25,2,Yellow,Black);
  WriteAdresse(6,5,Cyan,Black);
  WriteKnowHow(6,12,LightBlue,Black);
  WriteDienst(38,5,Green,Black);
  WriteNote(6,19,Red,Black);
  WritePressKey(6,24,LightMagenta,Black,Yellow,Black);
  GotoXY(1,25);
  if KwirkReadKey=0 then;
  WriteLoading(6,24,LightMagenta,Black);
  GotoXY(1,25); NormVideo;
  end;

end.