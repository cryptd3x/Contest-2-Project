init_tetris_board PROC PUBLIC USES ecx
	INVOKE init_game_object, 1
	mov (GameObject PTR [ecx]).gameObjectType, TETRIS_BOARD_GAME_OBJECT_ID
	mov (GameObject PTR [ecx]).pVt, OFFSET TETRIS_BOARD_VTABLE
	ret
init_tetris_board ENDP

new_tetris_board PROC PUBLIC USES ecx
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF TetrisBoard
	mov ecx, eax
	INVOKE init_tetris_board
	ret
new_tetris_board ENDP

tetris_board_update PROC stdcall PUBLIC USES ecx, deltaTime:REAL4
	ret
tetris_board_update ENDP

END
