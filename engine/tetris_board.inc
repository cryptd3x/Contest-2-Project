IFNDEF TETRIS_BOARD_INC
TETRIS_BOARD_INC EQU 1

INCLUDE game_object.inc

TetrisBoard STRUCT
	baseGameObject GameObject<>
	; insert board data here
TetrisBoard ENDS

init_tetris_board PROTO
new_tetris_board PROTO

ENDIF
