IFNDEF TETRIS_MANAGER_INC
TETRIS_MANAGER_INC EQU 1

INCLUDE game_object.inc

TetrisManager STRUCT
	baseGameObject GameObject<>
	; score, level, etc. later
TetrisManager ENDS

init_tetris_manager PROTO
new_tetris_manager PROTO

ENDIF
