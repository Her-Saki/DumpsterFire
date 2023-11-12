;;###############################################
;;Idea No Hi (partial) disassembly - By Her-Saki#
;;###############################################

arch snes.cpu

;;######################
;; Common registers    #
;;######################

	;;Vram
	!VramPortReg			= $2115
	!VramAddressReg			= $2116
	
	;;Main DMA register
	!DMAMainReg				= $420B
	
	;;DMAC7 registers
	!DMAC7WordIncrementReg	= $4370
	!DMAC7VramGateReg		= $4371
	!DMAC7RamAddressReg		= $4372
	!DMAC7BankReg			= $4374
	!DMAC7SizeReg			= $4375
	!DMAC7UnkReg			= $4377
	
;;###############
;; Variables    #
;;###############

	;;DMA queue index
	!DMAQueue				= $2D		;;DMA queue

	;;DMAC7 variables
	!DMAC7VramAddress		= $2E		;;Vram address (Word) 
	!DMAC7RamAddress		= $30		;;Ram address (Word)
	!DMAC7Bank				= $32		;;Bank number (Byte)
	!DMAC7Size				= $33		;;Size (Word)
	!DMAC7VramAddress2		= $35		;;Vram address (Word) 
	!DMAC7RamAddress2		= $37		;;Ram address (Word)
	!DMAC7Bank2				= $39		;;Bank number (Byte)
	!DMAC7Size2				= $3A		;;Size (Word)

	;;Tilemap data
	!TextBoxTilemapData		= $1871
	
;;###############
;; Constants    #
;;###############

	;;Opcodes
	!SPEED_NORMAL			= "db $03"

	;;Namecards
	!HAKASE					= "dl $D3E8FD"

	
;;#######################
;;Update textbox 	    #
;;#######################
;;The textbox is first written in RAM ($7F2620)
;;and then updated every frame (so the entire
;;textbox is written to VROM, and then the
;;tilemap is written using its characters
;;every frame).

;;Write textbox in VROM
org $818BF7
REP #$20
LDA !TextBoxTilemapData ;;#$04C6
AND #$FFE0
PHA
ASL
ASL
STA !DMAC7VramAddress ;;#$1300
ASL
STA !DMAC7RamAddress ;;#$2600
LDA #$0400
STA !DMAC7Size
;;Write tilemap
PLA
CLC
ADC #$3800
STA !DMAC7RamAddress2
LSR
STA !DMAC7VramAddress2
LDA #$0080
STA !DMAC7Size2
SEP #$20
LDA #$7F
STA !DMAC7Bank
STA !DMAC7Bank2
;;Add to queue
LDA #$03
STA !DMAQueue
;;Wait for V-Blank (?!)
WaitForVBlank1:
LDA !DMAQueue
BNE WaitForVBlank1

;;####################
;;Write letters to   #
;;textbox			 #
;;####################

;;$8B8000,X > $A21905 XOR #$FF > $7FXXXX,X

;;This gets the index for the index
org $818C5F
LDA ($06)
REP #$20
INC $06
AND #$00FF
ASL
CLC
ADC $1901
TAX
;;This writes the index for each letter
;;org $818C6E
LDA $8B8000,X
STA $1901

;;This writes to $A21905
org $818CDA
LDX $1901
REP #$20
LDA $8B8000,X
TAY
org $818D00
STY $1905

org $818D1C
;;Load letter byte
;;Y is always $A21905/$A21906
LDA   $0000,Y
;;XOR (?!)
EOR.B #$FF
;;Push byte
PHA

org $818D4A
;;Pull byte
PLA
;;Write
STA $7F0000,X


;;####################
;;DMAC 7 transfer    #
;;disassembly		 #
;;####################

org $85C008
LDX   !DMAC7VramAddress
STX   !VramAddressReg
LDA.B #$80
STA   !VramPortReg
LDA.B #$01
STA   !DMAC7WordIncrementReg
LDA.B #$18
STA   !DMAC7VramGateReg
LDX   !DMAC7RamAddress
STX   !DMAC7RamAddressReg
LDA   !DMAC7Bank
STA   !DMAC7BankReg
LDX   !DMAC7Size
STX   !DMAC7SizeReg
STZ	  !DMAC7UnkReg
LDA.B #$80
STA   !DMAMainReg

;;Hakase
org $8B8F26
dw $5C56

;;Script
;;All opcodes should be defined in Japanese.tbl
org $0C8000
table "Text.tbl",rtl
!SPEED_NORMAL
!HAKASE
db "THIS IS A TEST"
cleartable