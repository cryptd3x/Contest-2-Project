INCLUDE default_header.inc
INCLUDE tetris_manager.inc
INCLUDE heap_functions.inc
INCLUDE tetromino.inc
INCLUDE tetris_board.inc

.data
TETRIS_MANAGER_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET tetris_manager_update, OFFSET game_object_exit, OFFSET free_game_object>

.code

init_tetris_manager PROC PUBLIC USES ecx
    INVOKE init_game_object, 2
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

tetris_manager_update PROC stdcall PUBLIC USES esi, deltaTime:REAL4
    mov esi, ecx
    ; Manages active tetromino, spawning, input routing, and game-over conditions
    mov ebx, (TetrisManager PTR [esi]).activeTetromino
	.IF ebx == 0
		fld (TetrisManager PTR [esi]).spawnTimer
		fadd deltaTime
		fstp (TetrisManager PTR [esi]).spawnTimer
		
		.IF (TetrisManager PTR [esi]).spawnTimer > 0.1
			INVOKE new_tetromino
			mov ebx, eax
			mov ecx, esi
			mov ecx, (GameObject PTR [ecx]).pParentScene
			mov ecx, eax
			INVOKE instantiate_game_object, ebx
			
			mov esi, (GameObject PTR [esi]).pParentScene
			mov (TetrisManager PTR [esi]).activeTetromino, ebx
			mov (TetrisManager PTR [esi]).spawnTimer, 0.0
		.ENDIF
	.ENDIF
    ret
tetris_manager_update ENDP

END
