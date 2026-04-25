INCLUDE default_header.inc
INCLUDE tetris_manager.inc
INCLUDE heap_functions.inc
INCLUDE tetromino.inc

.data
TETRIS_MANAGER_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET tetris_manager_update, OFFSET game_object_exit, OFFSET free_game_object>

.code

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
