{$ifdef use_objfpc}
  {$mode objfpc}
{$else}
  {$mode tp}
{$endif}

{$macro on}

{$ifdef windows}
  {$define GraphUnit:=Graph}
{$else}
  {$define GraphUnit:=PtcGraph}
{$endif}

