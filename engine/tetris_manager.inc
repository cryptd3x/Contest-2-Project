; tetris_manager.inc
IFNDEF TETRIS_MANAGER_INC
TETRIS_MANAGER_INC EQU 1

INCLUDE game_object.inc

TetrisManager STRUCT
    baseGameObject      GameObject<>
    activeTetromino     DWORD  ?    ; pointer to live Tetromino, or 0 if none
    spawnTimer          REAL4  ?    ; delay before spawning first piece (seconds)
    score               DWORD  ?    ; lines cleared * 100
    level               DWORD  ?    ; increases every 10 lines
    linesCleared        DWORD  ?    ; total lines cleared
TetrisManager ENDS

init_tetris_manager     PROTO
new_tetris_manager      PROTO
tetris_manager_update   PROTO stdcall deltaTime:REAL4

ENDIF
