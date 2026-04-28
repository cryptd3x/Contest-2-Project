; engine_types.inc
; Core types and constants shared across the engine.
IFNDEF ENGINE_TYPES_INC
ENGINE_TYPES_INC EQU 1

; Screen resolution for the software renderer
SCREEN_WIDTH  EQU 320
SCREEN_HEIGHT EQU 640

; Size of one Tetris cell in pixels
BLOCK_SIZE EQU 32

; A single BGRA pixel (4 bytes, matches DIB 32-bit layout)
Pixel STRUCT
    b BYTE ?
    g BYTE ?
    r BYTE ?
    a BYTE ?
Pixel ENDS

ENDIF
