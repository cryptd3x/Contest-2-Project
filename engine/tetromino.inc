IFNDEF TETROMINO_INC
TETROMINO_INC EQU 1

INCLUDE game_object.inc

Tetromino STRUCT
	baseGameObject GameObject<>
	; Add shape/rotation data later
Tetromino ENDS

init_tetromino PROTO
new_tetromino PROTO

ENDIF
