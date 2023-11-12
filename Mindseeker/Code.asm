;;Pointer jump list
#org $AD00, $AD10			;;Pointer 1
LDA #$00
TAX
JSR LoadPointers
NOP \ NOP

;;Actual pointers are at $8800
;;Pointer assignment
#org $8900, $8910
LoadPointers:
LDA $8800,x \ STA $20
INX
LDA $8800,x \ STA $21
RTS

;;Text full speed
#org $0000, $01D0
LDA #$01

;;==============================
;;Remove indent
;;==============================
;;BG letters
#org $0000, $1EDB0
LDA #$82
;;Sprite letters
#org $0000, $1EDB6
LDA #$9F
#org $0000, $1EDBA
LDA #$10
;;Sprite letters offset fix
#org $0000, $1EE20
LDA #$10

;;Stop text at $42 (4th line)
#org $0000, $1EE26
CMP #$42

;;Sprite initial Y position after 1st panel
#org $0000, $1F054
LDA #$9F

;;Text position after 1st panel
#org $0000, $1F04E
LDA #$82

;;Clean this amount of tiles after each next page
#org $0000, $1F074
LDA #$1C

;;Clean from this position after each next page
#org $0000, $1F06C
LDA #$62

;;==============================
;;Process tilde and point
;;==============================
#org $EE38, $1EE48
LDA $26
CLC \ ADC #$50 \ STA $D9
LDA $26
CMP #$3A \ BCS Point
LDA #$BE \ BMI AddOffset
Point:
LDA #$BF
AddOffset:
STA $2A
LDA $27
SEC
SBC #$20
STA $D6
BPL NoSub
DEC $D5
NOP \ NOP \ NOP
NoSub:

;;==============================
;;More letters per line
;;==============================
#org $0000, $1EDC0
LDX #$1C

;;==============================
;;Palettes
;;==============================
#org $0000, $872B
#byte $0F, $00, $1C, $30

#org $0000, $8747
#byte $0F, $00, $1C, $30

;;==============================
;;CHR
;;==============================
;;Text font
#org $0000, $20010
#incbin "Font.bin"

;;Text font 2
#org $0000, $23410
#incbin "Font2.bin"

;;==============================
;;Title screen attribute table
;;==============================
#org $0000, $303F0
#pad $08, $F0

#org $0000, $303FC
#byte $0F

#org $0000, $30400
#pad $10, $F0
