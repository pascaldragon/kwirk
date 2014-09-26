{$ifdef use_objfpc}
  {$mode objfpc}
{$else}
  {$mode tp}
{$endif}

{$macro on}

{.$ifdef windows}
  {.$define GraphUnit:=Graph}
  {.$define CrtUnit:=Crt}
{.$else}
  {$define GraphUnit:=PtcGraph}
  {$define CrtUnit:=PtcCrt}
  {$define DefineColors}
{.$endif}

