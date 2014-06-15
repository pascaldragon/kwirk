(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

uses Config;

var Cfg   : TConfig;
    GrpAnz: Word;
    GrpNum: Word;
    KeyAnz: Word;
    KeyNum: Word;
    Nam   : String;
    Val   : String;

begin
Cfg.Init;
Cfg.SetFilename('Bla.Ini');
GrpAnz:=Cfg.GetGroupCount;
for GrpNum:=1 to GrpAnz do
  begin
  Cfg.SetAktGroupNum(GrpNum);
  Cfg.GetAktGroupName(Nam);
  Writeln('[',Nam,']');
  KeyAnz:=Cfg.GetKeyCount;
  for KeyNum:=1 to KeyAnz do
    begin
    Cfg.ReadKeyNum(KeyNum,Nam,Val);
    Writeln('  ',Nam,'=',Val);
    end;
  end;
Cfg.Dirty:=True;
Cfg.Done;
end.
