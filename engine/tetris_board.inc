; tetris_board.inc
IFNDEF TETRIS_BOARD_INC
TETRIS_BOARD_INC EQU 1
INCLUDE game_object.inc
TETRIS_BOARD_WIDTH  EQU 10
TETRIS_BOARD_HEIGHT EQU 20

TetrisBoard STRUCT
    baseGameObject GameObject<>
    grid           BYTE (TETRIS_BOARD_WIDTH * TETRIS_BOARD_HEIGHT) DUP(0)
TetrisBoard ENDS

init_tetris_board     PROTO
new_tetris_board      PROTO
board_lock_tetromino  PROTO pBoard:DWORD, pTetromino:DWORD
board_clear_lines     PROTO pBoard:DWORD
board_can_place       PROTO pBoard:DWORD, pTetromino:DWORD, dx_:SDWORD, dy:SDWORD   ; <-- FIXED: dx_ instead of dx

ENDIF