(* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. *)

const

MoveRightImg: KwirkMoveImgType = (nSteps:9; Img:(11+4*14,12+3*14,12+2*14,12+1*14,
                                                         13+3*14,13+2*14,13+1*14,
                                                         14+3*14,14+2*14,14+1*14));
   MoveUpImg: KwirkMoveImgType = (nSteps:9; Img:(13+4*14, 9+5*14,10+5*14,11+5*14,
                                                          9+6*14,10+6*14,11+6*14,
                                                          9+7*14,10+7*14,11+7*14));
 MoveLeftImg: KwirkMoveImgType = (nSteps:9; Img:(12+4*14,12+5*14,12+6*14,12+7*14,
                                                         13+5*14,13+6*14,13+7*14,
                                                         14+5*14,14+6*14,14+7*14));
 MoveDownImg: KwirkMoveImgType = (nSteps:9; Img:(14+4*14, 8+5*14, 7+5*14, 6+5*14,
                                                          8+6*14, 7+6*14, 6+6*14,
                                                          8+7*14, 7+7*14, 6+7*14));
KwirkChar = ['>','^','<','V'];

AimFld    = 11 + 1 *14;   { Ziel                           }
WallFld   =  5 + 7 *14;   { Mauerwerk                      }
WatrFld   =  5 + 6 *14;   { Wasser                         }
JMEFld    = 10 + 4 *14;   { JME                            }
JoeMFld   = 11 + 2 *14;   { Joe M.                         }
WatrWeg1  = 10 + 3 *14;   { Kiste versenken                }
WatrWeg2  = 11 + 3 *14;   { Kiste versenken                }

Box0      = 11 + 0 *14;   { einzelne Kiste                 }
BoxWl     = 10 + 0 *14;   { waagerechte Kiste linker Teil  }
BoxWm     = 10 + 1 *14;   { waagerechte Kiste mittlerer Teil }
BoxWr     = 10 + 2 *14;   { waagerechte Kiste rechter Teil }
BoxSo     = 12 + 0 *14;   { senkrechte Kiste oberer Teil   }
BoxSm     = 13 + 0 *14;   { senkrechte Kiste mittlerer Teil }
BoxSu     = 14 + 0 *14;   { senkrechte Kiste unterer Teil  }
BoxRe     =  9 + 2 *14;   { Gro�e Kiste rechte Seite       }
BoxOb     =  6 + 4 *14;   { Gro�e Kiste obere Seite        }
BoxLi     =  9 + 0 *14;   { Gro�e Kiste linke Seite        }
BoxUn     =  7 + 4 *14;   { Gro�e Kiste untere Seite       }
BoxRO     =  8 + 4 *14;   { Gro�e Kiste Ecke rechts oben   }
BoxLO     =  8 + 3 *14;   { Gro�e Kiste Ecke links oben    }
BoxLU     =  9 + 3 *14;   { Gro�e Kiste Ecke links unten   }
BoxRU     =  9 + 4 *14;   { Gro�e Kiste Ecke rechts unten  }
BoxMi     =  9 + 1 *14;   { Gro�e Kiste Innenteil          }
BoxChar   = ['�','�','�','�','�','�','�','�','�','�','�','�','�','�','�','�'];

arLine0   =  2 + 1 *14;   { Linie f�r Au�enradius   0�-360�}
arLine1   =  1 + 2 *14;   { Linie f�r Au�enradius   0�-90� }
arLine2   =  1 + 0 *14;   { Linie f�r Au�enradius  90�-180�}
arLine3   =  3 + 0 *14;   { Linie f�r Au�enradius 180�-270�}
arLine4   =  3 + 2 *14;   { Linie f�r Au�enradius 270�-360�}
arMask0   =  2 + 4 *14;   { Maske f�r Au�enradius   0�-360�}
arMask1   =  1 + 5 *14;   { Maske f�r Au�enradius   0�-90� }
arMask2   =  1 + 3 *14;   { Maske f�r Au�enradius  90�-180�}
arMask3   =  3 + 3 *14;   { Maske f�r Au�enradius 180�-270�}
arMask4   =  3 + 5 *14;   { Maske f�r Au�enradius 270�-360�}
irLine1   =  3 + 7 *14;   { Linie f�r Innenradius   0�-90� }
irLine2   =  3 + 6 *14;   { Linie f�r Innenradius  90�-180�}
irLine3   =  4 + 6 *14;   { Linie f�r Innenradius 180�-270�}
irLine4   =  4 + 7 *14;   { Linie f�r Innenradius 270�-360�}
irMask1   =  1 + 7 *14;   { Maske f�r Innenradius   0�-90� }
irMask2   =  1 + 6 *14;   { Maske f�r Innenradius  90�-180�}
irMask3   =  2 + 6 *14;   { Maske f�r Innenradius 180�-270�}
irMask4   =  2 + 7 *14;   { Maske f�r Innenradius 270�-360�}

EndLine1  =  5 + 1 *14;   { Linie f�r rechtes Mauerende    }
EndLine2  =  5 + 0 *14;   { Linie f�r oberes  Mauerende    }
EndLine3  =  4 + 0 *14;   { Linie f�r linkes  Mauerende    }
EndLine4  =  4 + 1 *14;   { Linie f�r unteres Mauerende    }

BandLine1 =  2 + 2 *14;   { Linie f�r [��  ]               }
BandLine2 =  1 + 1 *14;   { Linie f�r       [����]         }
BandLine3 =  2 + 0 *14;   { Linie f�r [  ��]               }
BandLine4 =  3 + 1 *14;   { Linie f�r       [����]         }
BandMask1 =  2 + 5 *14;   { Maske f�r [��  ]               }
BandMask2 =  1 + 4 *14;   { Maske f�r       [����]         }
BandMask3 =  2 + 3 *14;   { Maske f�r [  ��]               }
BandMask4 =  3 + 4 *14;   { Maske f�r       [����]         }

DoorWing1 =  5 + 3 *14;   { T�rfl�gel nach rechts          }
DoorWing2 =  4 + 3 *14;   { T�rfl�gel nach oben            }
DoorWing3 =  4 + 2 *14;   { T�rfl�gel nach links           }
DoorWing4 =  5 + 2 *14;   { T�rfl�gel nach unten           }
DoorEcke1 =  6 + 2 *14;   { T�recke   0�-90�            �  }
DoorEcke2 =  6 + 0 *14;   { T�recke  90�-180�          �   }
DoorEcke3 =  8 + 0 *14;   { T�recke 180�-270�           �  }
DoorEcke4 =  8 + 2 *14;   { T�recke 270�-360�           �  }
DoorDrei1 =  7 + 2 *14;   { T�rdreieck   0�-90�          � }
DoorDrei2 =  6 + 1 *14;   { T�rdreieck  90�-180�        �  }
DoorDrei3 =  7 + 0 *14;   { T�rdreieck 180�-270�       �   }
DoorDrei4 =  8 + 1 *14;   { T�rdreieck 270�-360�        �  }
DoorZwei1 =  7 + 3 *14;   { T�rmitte waagerecht         �  }
DoorZwei2 =  6 + 3 *14;   { T�rmitte senkrecht          �  }
DoorEins1 =  5 + 5 *14;   { T�rmitte einfach               }
DoorEins2 =  4 + 5 *14;   { T�rmitte einfach               }
DoorEins3 =  4 + 4 *14;   { T�rmitte einfach               }
DoorEins4 =  5 + 4 *14;   { T�rmitte einfach               }
DoorVier  =  7 + 1 *14;   { T�rmitte                   �   }
DoorWingChar   = ['�','�','�','�'];
DoorCenterChar = ['�','�','�','�','�','�','�','�','�','�','�','�','�','�','�'];
DoorCenterArr: Array[1..15] of Char = ('�','�','�','�','�','�','�','�','�','�','�','�','�','�','�');
