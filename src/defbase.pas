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
      MaxImgMemSize = {$ifdef fpc}28 * 28 * SizeOf(LongInt){$else}500{$endif};
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
     KwirkXSpeed: Int16 = 10;
     KwirkYSpeed: Int16 = 10;
       JumpSpeed: Int16 = 60;
      WaterSpeed: Int16 = 300;
       JoeMSpeed: Int16 = 600;
  KwirkBumpSteps: Int16 = 6;
     KwirkXsteps: Int16 = 9;
     KwirkYsteps: Int16 = 9;
        ImgXsize: Int16 = 27;
        ImgYsize: Int16 = 27;
          nMazes: Int16 = 0;
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
       MazeXoffs: Int16 = 0;
       MazeYoffs: Int16 = 0;
        MenXoffs: Int16 = 0;
        MenYoffs: Int16 = 0;
       TextKwirk: Boolean = False;
         ComPort: Int16 = 0;
        UserName: String  = '';
         TimeOut: Word    = 0;
         MaxTime: Word    = 0;

var          Cfg: TConfig;

Const ParamHelp: Boolean = False;
Const TextModeAtProgrammStart: Int16 = -1;

Type   CharSet = Set of Char;
{       ref_Img = ^ImgType;                                                }
{       ImgType = record xs,ys: Int16; Buf: Array[1..65531] of Byte end; }
  KwirkPosType = Array[1..MaxKwirksPerMaze] of Int16;
   MazeNameStr = String[MaxMazeNameLen];
      MazeType = Record Name: MazeNameStr;
                       xs,ys: Int16;
                     nKwirks: Int16;
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

   KwirkMoveImgType = record nSteps: Int16;
                                Img: Array[0..MaxKwirkMoveSteps] of Int16;
                        end;

{ I Level123.Pas}
{ I Heading.Pas}
{$I ImgConst.Pas}

Type  ImgType = Array[1..MaxImgMemSize] of Byte;
      ref_Img = ^ImgType;

const Room: Int16 = 1;
var    Img: Array[1..nImages] of ref_Img;
   ImgMaze: ImgMazeType;
     Mazes: MazesType;
  LevelStartTime: LongInt;

implementation

end.