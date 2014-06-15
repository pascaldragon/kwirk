(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

{Unit KwirkCom;

interface}

Uses MyCrt,ooCom,ooModem,apPort{,apMisc};

Const bNullModem: Boolean = True;

var Port: UArtPort;
    Modm: AbstractModemPtr;

{implementation}

Procedure DoReceive;
  var  c: Char;
    Ende: Boolean;
  begin
  Ende:=False;
  repeat
    if Port.CharReady then
      begin
      Port.GetChar(c);
      Write(c);
      end;
    if KeyPressed and Port.TransReady then
      begin
      c:=ReadKey;
      Port.PutChar(c);
      Ende:=c=#27;
      end;
  until Ende;
  end;

begin
Port.InitFast(Com2,19200);
if bNullModem then
  begin
  Modm:=New(NullModemPtr,Init(@Port));
  Modm^.Timeout:=5;
  end
else begin
  Modm:=New(HayesModemPtr,Init(@Port));
  Modm^.Timeout:=20;
  Modm^.SetModemRegister(0,1);
  end;
DoReceive;
Modm^.HangUpModem(0,True);
Dispose(Modm,Done);
Port.Done;
end.
