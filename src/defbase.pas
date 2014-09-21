(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

(*VarStr, NamStr, ExtStr, PathStr, ... raus
FExpand, FSplit raus, ...
...*)

Unit DefBase; { for " The Quest of Kwirk's Castle " }

{$I kwirkdefs.inc}

interface

uses Dos,Config;

const       nImages = 112;
      MaxImgMemSize = {$ifdef fpc}1500{$else}500{$endif};
       MaxMazeXsize = 20; { 40; {}
       MaxMazeYsize = 18; { 18; {}
           MaxMazes = 50; { 50; {}
           MaxLines = 5;
           MaxMasks = 5;
   MaxKwirksPerMaze = 10;
  MaxKwirkMoveSteps = 9;
      MaxKwirkSpeed = 200;
     MaxMazeNameLen = 36;
              DMStr = 'DM 50.-'; (*{}
              DMStr = '$ 30.-';  (**)


           ImgFn: PathStr = ''; {'KwirkVGA.Img';}
           MazFn: PathStr = ''; {'GoingUp1.Maz';}
       QuestName: String  = '';
      KwirkSpeed: Real    = 0.2; { von Feld zu Feld in Sekunden }
     KwirkXSpeed: integer = 10;
     KwirkYSpeed: integer = 10;
       JumpSpeed: integer = 60;
      WaterSpeed: integer = 300;
       JoeMSpeed: integer = 600;
  KwirkBumpSteps: integer = 6;
     KwirkXsteps: integer = 9;
     KwirkYsteps: integer = 9;
        ImgXsize: integer = 27;
        ImgYsize: integer = 27;
          nMazes: integer = 0;
{DefaultSpeedFont: Boolean = True;  (*{}
DefaultSpeedFont: Boolean = False; (**)
     WaterToWall: Boolean = True;  (*{}
     WaterToWall: Boolean = False; (**)
     EckenRadius: Boolean = True;  (*{}
     EckenRadius: Boolean = False; (**)
{      RandRadius: Boolean = True;  (*{}
      RandRadius: Boolean = False; (**)
     QuickMoving: Boolean = False; (*{}
     QuickMoving: Boolean = True;  (**)
  QuestMakerFlag: Boolean = False; (*{}
  QuestMakerFlag: Boolean = True;  (**)
  ShowMovingTime: Boolean = False;
       MazeXoffs: integer = 0;
       MazeYoffs: integer = 0;
        MenXoffs: integer = 0;
        MenYoffs: integer = 0;
       TextKwirk: Boolean = False;
         ComPort: Integer = 0;
        UserName: String  = '';
         TimeOut: Word    = 0;
         MaxTime: Word    = 0;

var          Cfg: TConfig;

Const ParamHelp: Boolean = False;
Const TextModeAtProgrammStart: integer = -1;

Type   CharSet = Set of Char;
{       ref_Img = ^ImgType;                                                }
{       ImgType = record xs,ys: integer; Buf: Array[1..65531] of Byte end; }
  KwirkPosType = Array[1..MaxKwirksPerMaze] of integer;
   MazeNameStr = String[MaxMazeNameLen];
      MazeType = Record Name: MazeNameStr;
                       xs,ys: integer;
                     nKwirks: integer;
                      KwirkX,
                      KwirkY: KwirkPosType;
                        Jump: Array[1..MaxKwirksPerMaze] of Boolean;
                           M: Array[1..MaxMazeYsize] of String[MaxMazeXsize];
                           P: Array[1..MaxMazeYsize,1..MaxMazeXsize] of Boolean;
                   end;
     MazesType = Array[1..MaxMazes] of MazeType;

      CellType = Record Source1: Byte;
                          Mask1: Array[1..MaxMasks] of Byte;
                          Line1: Array[1..MaxLines] of Byte;
                        Source2: Byte;
                          Mask2: Array[1..MaxMasks] of Byte;
                          Line2: Array[1..MaxLines] of Byte;
                      {Member fuer TextKwirk:}
                      TextKwStr: String[3];
                      TextKwAtr: Byte;
                     TextKwStr2: String[3];
                     TextKwAtr2: Byte;
                  end;
   ImgMazeType = Array[1..MaxMazeYsize,1..MaxMazeXsize] of CellType;

   KwirkMoveImgType = record nSteps: integer;
                                Img: Array[0..MaxKwirkMoveSteps] of integer;
                        end;

{ I Level123.Pas}
{ I Heading.Pas}
{$I ImgConst.Pas}

Type  ImgType = Array[1..MaxImgMemSize] of Byte;
      ref_Img = ^ImgType;

const Room: integer = 1;
var    Img: Array[1..nImages] of ref_Img;
   ImgMaze: ImgMazeType;
     Mazes: MazesType;
  LevelStartTime: LongInt;

implementation

end.