;;==============================
;;Seirei Gari Translation Project
;;By NijigenBoukensha
;;2021
;;==============================

;;Constants
EngineStart = $80
JumpByte 	= $FE
EndByte  	= $FF

;;Variables
#org $80
#var	FontAddressLB,		1
#var	FontAddressHB,		1
#var	VramAddressLB,		1
#var	VramAddressHB,		1
#var 	Width,				1
#var	Shift,				1
#var 	ShiftLeft,			1
#var	ShiftRight,			1
#var	BufferSize,			1
#var 	VromPosition,		1
#var 	OperatorLB,			1
#var	OperatorHB,			1
#var	ABackup,			1
#var	NextLetter,			1
#org $90
#var	RawTile,			10
#var	OldTile,			10
#var	NewTile,			10

#org $F05E, $3F06E
JSR VWF

#org $9000, $35010
VWF:
;;------------------------------;
;;Update Vrom position
;;------------------------------;
INC VromPosition

;;------------------------------;
;;Save values
;;------------------------------;
LDY #$00
LDA ($37),Y
STA ABackup
INY
LDA ($37),Y
STA NextLetter
LDY #$00

;;------------------------------;
;;Use letter as index
;;------------------------------;
JSR MultiplyBy10
LDA OperatorLB
STA FontAddressLB
LDA OperatorHB
STA FontAddressHB

;;------------------------------;
;;Copy first letter from memory
;;to new tile buffer and raw
;;buffer
;;------------------------------;
LDY #$00
Loop1:
LDA (FontAddressLB),Y
STA NewTile,y
STA RawTile,y
INY
CPY #$10
BNE Loop1

;;------------------------------;
;;Skip shift operations if
;;width is zero
;;------------------------------;
LDA Width
BNE ShiftOperations
JMP WriteNewTile

;;------------------------------;
;;Shift operations
;;------------------------------;
ShiftOperations:
LDX #$00
LDY #$00
;;Shifting right
LoopShiftRight:
LSR NewTile,x
INY
CPY ShiftRight
BNE LoopShiftRight
LDY #$00
;;Oring
LDA OldTile,x
ORA NewTile,x
STA OldTile,x
;;Shifting left
LDA RawTile,x
LoopShiftLeft:
ASL
INY
CPY ShiftLeft
BNE LoopShiftLeft
STA NewTile,x
LDY #$00
;;Loop base
INX
CPX #$10
BNE LoopShiftRight

;;------------------------------;
;;Write VRAM address
;;------------------------------;
LDA VromPosition
JSR MultiplyBy10
LDA OperatorHB
STA $2006
LDA OperatorLB
STA $2006
;;------------------------------;
;;Write old tile to VRAM
;;------------------------------;
LDY #$00
LoopZ:
LDA OldTile,y
STA $2007
INY
CPY #$10
BNE LoopZ
;;------------------------------;
;;Write new tile to VRAM
;;------------------------------;
WriteNewTile:
LDY #$00
LoopX:
LDA NewTile,y
STA $2007
INY
CPY #$10
BNE LoopX

;;------------------------------;
;;Check width
;;------------------------------;
LDX ABackup     	;;Load A backup as index
LDA ShiftData,x  	;;Load tile width
SEC              	;;Substract shift
SBC Shift
STA Width        	;;Store as old width
BEQ Reset00       	;;If zero, reset shift and buffer position
BMI Reset08       	;;If less, reset everything 
BPL GetWidth      	;;If greater, continue normally

;;------------------------------;
;;Zero path
;;------------------------------;
Reset00:
JSR ResetShift     	;;Redundancy save
JMP GetWidth

;;------------------------------;
;;Negative path
;;------------------------------;
Reset08:              
JSR ResetShift     	;;Redundancy save
LDA #$00
SEC
SBC Width
STA Width
STA ShiftLeft    	;;Old width and shift left = 0 - Negative width     
LDA #$08
SEC
SBC Width
STA ShiftRight   	;;Shift right = 8 - Width
JMP LoadBackups

;;------------------------------;
;;Get width
;;------------------------------;
GetWidth:
LDA Width
STA ShiftRight   	;;Shift right = Width
LDA #$08            
SEC
SBC Width
STA ShiftLeft    	;;Shift left = 8 - Width

;;------------------------------;
;;Save old tile
;;------------------------------;
LDX #$00
LoopSaveOldTile:
LDA NewTile,x
STA OldTile,x
INX
CPX #$10
BNE LoopSaveOldTile

;;------------------------------;
;;Load backups
;;------------------------------;
LoadBackups:
LDY #$00
LDA NextLetter
CMP JumpByte
BEQ ResetJump
CMP EndByte
BNE UniversalExit
;;Reset engine at end byte
LDA #$00
ResetEnd:
STA EngineStart,y
CPY #$40
BNE ResetEnd
LDY #$00
RTS
;;Reset variables at jump byte
ResetJump:
LDA #$00
STA Shift
STA Width
UniversalExit:
RTS

;;------------------------------;
;;Help routines
;;------------------------------;
;;------------------------------;
;;Multiply number by 10
;;------------------------------;
MultiplyBy10:
PHA
AND #$F0
LSR
LSR
LSR
LSR
STA OperatorHB
PLA
AND #$0F
ASL
ASL
ASL
ASL
STA OperatorLB
RTS
;;------------------------------;
;;Redundancy save
;;------------------------------;
ResetShift:
DEC VromPosition
LDA #$00
STA Shift
RTS
ShiftData:
;;    a			b		  c		    d	      e
#byte $DE, $E9, $DF, $E8, $E0, $E9, $E1, $D1, $E2, $E9
;;    f		    g		  h			i		  j
#byte $E3, $D3, $E4, $F5, $F6, $E8, $ED, $CE, $E6, $D6