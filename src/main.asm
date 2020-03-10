INCLUDE "hardware.inc"
; INCLUDE "debug.asm"

SECTION "Header", ROM0[$100]
EntryPoint: ; This is where execution begins
    di ; Disable interrupts. That way we can avoid dealing with them, especially since we didn't talk about them yet :p
    jp Start ; Leave this tiny space

REPT $150 - $104
    db 0
ENDR

SECTION "vblankInt", ROM0[$40]
    jp VBlankHandler

SECTION "Game code", ROM0

Start:
    ; Turn off the LCD
.waitVBlank
    ld a, [rLY]
    cp 144 ; compare register a with 144. sets c if true
    jr c, .waitVBlank

    ld a, %10000001
    ldh [rKEY1], a
    stop ; set cpu double speed mode

    xor a ; ld a, 0 ; We only need to reset a value with bit 7 reset, but 0 does the job
    ld [rLCDC], a ; We will have to write to LCDC again later, so it's not a bother, really.

.setPalette
    ld a, %10000000 ; set autoinc
    ld [rBCPS], a

    ; set palette. first load is the second half of green and red.
    ; second load is the first half of green and blue

    ; example: full red
    ; ld a, %00011111
    ; ld [rBCPD], a

    ; ld a, %00000000
    ; ld [rBCPD], a

    ; example: full green
    ; ld a, %11100000
    ; ld [rBCPD], a

    ; ld a, %00000011
    ; ld [rBCPD], a

    ; example: full blue
    ld a, %00000000
    ld [rBCPD], a

    ld a, %01111100
    ld [rBCPD], a

.setupDMA
    ld a, HIGH(FontTiles)
    ldh [rHDMA1], a
    ld a, LOW(FontTiles)
    ldh [rHDMA2], a
    ld a, HIGH($9000)
    ldh [rHDMA3], a
    xor a ; ld a, LOW($9000)
    ldh [rHDMA4], a
    ld a, $80 | 127 ; Starts a (127 + 1) * 16-byte copy
    ldh [rHDMA5], a

    ; Init display registers
    ld a, %11100100
    ld [rBGP], a

    xor a ; ld a, 0
    ld [rSCY], a
    ld [rSCX], a

    ; Shut sound down
    ld [rNR52], a

    ; Turn screen on, display background
    ld a, %10000001
    ld [rLCDC], a
    ld a, %00000001
    ld [rIE], a
    ei ; enable interupts

    ; Lock up
.lockup
    jr .lockup


SECTION "vblank", ROM0
VBlankHandler:
    ld hl, $9800 ; This will print the string at the top-left corner of the screen
    ld de, HelloWorldStr
.copyString
    ld a, [de]
    ld [hli], a
    inc de
    and a ; Check if the byte we just copied is zero
    jr nz, .copyString ; Continue if it's not
    reti

SECTION "Font", ROM0

FontTiles:
INCBIN "src/res/smiley.2bpp"
INCBIN "src/res/font.chr"
FontTilesEnd:

SECTION "Hello World string", ROM0

HelloWorldStr:
    db "Hello World!", 0
