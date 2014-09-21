(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

unit Config;

{$define use_objfpc}
{$I kwirkdefs.inc}

interface

type
  TConfig = object
    constructor Init;
    destructor Done;
    procedure SetFilename(aFilename: String);
    procedure WriteKeyName(aKey, aValue: String);
    function ReadkeyName(aKey: String; var aValue: String): Boolean;
    procedure SetAktGroupName(aGroup: String);
  end;

  TGraphConfig = record
    Screen1: SmallInt;
    Res1: SmallInt;
  end;

implementation

{ TConfig }

constructor TConfig.Init;
begin

end;

destructor TConfig.Done;
begin

end;

procedure TConfig.SetFilename(aFilename: String);
begin

end;

procedure TConfig.WriteKeyName(aKey, aValue: String);
begin

end;

function TConfig.ReadkeyName(aKey: String; var aValue: String): Boolean;
begin

end;

procedure TConfig.SetAktGroupName(aGroup: String);
begin

end;

end.

