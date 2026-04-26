IFNDEF TETROMINO_INC
TETROMINO_INC EQU 1

INCLUDE game_object.inc

Tetromino STRUCT
    baseGameObject GameObject<>
    shape          BYTE 16 DUP(0)     ; 4x4 grid (1 = block)
    rotation       DWORD ?            ; 0-3
    typeId         DWORD ?            ; 0=I, 1=O, 2=T, 3=S, 4=Z, 5=J, 6=L
    dropTimer      REAL4 ?            ; accumulated time for automatic drop
Tetromino ENDS

init_tetromino     PROTO
new_tetromino      PROTO
tetromino_update   PROTO stdcall deltaTime:REAL4

ENDIF
