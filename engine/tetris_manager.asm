init_tetris_manager PROC PUBLIC USES ecx
	INVOKE init_game_object, 1
	mov (GameObject PTR [ecx]).gameObjectType, TETRIS_MANAGER_GAME_OBJECT_ID
	mov (GameObject PTR [ecx]).pVt, OFFSET TETRIS_MANAGER_VTABLE
	ret
init_tetris_manager ENDP

new_tetris_manager PROC PUBLIC USES ecx
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF TetrisManager
	mov ecx, eax
	INVOKE init_tetris_manager
	ret
new_tetris_manager ENDP

tetris_manager_update PROC stdcall PUBLIC USES ecx, deltaTime:REAL4
	; TODO: spawn tetromino, handle input, etc.
	ret
tetris_manager_update ENDP

END
