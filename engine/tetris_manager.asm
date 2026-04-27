INCLUDE default_header.inc
INCLUDE tetris_manager.inc
INCLUDE heap_functions.inc
INCLUDE tetromino.inc
INCLUDE tetris_board.inc
INCLUDE game_object.inc

.data
TETRIS_MANAGER_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET tetris_manager_update, OFFSET game_object_exit, OFFSET free_game_object>

.code

init_tetris_manager PROC PUBLIC USES ecx
	INVOKE init_game_object, 2
	mov (GameObject PTR [ecx]).gameObjectType, TETRIS_MANAGER_GAME_OBJECT_ID
	mov (GameObject PTR [ecx]).pVt, OFFSET TETRIS_MANAGER_VTABLE
	mov (TetrisManager PTR [ecx]).activeTetromino, 0
	mov (TetrisManager PTR [ecx]).spawnTimer, 0.0
	ret
init_tetris_manager ENDP

new_tetris_manager PROC PUBLIC USES ecx
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF TetrisManager
	mov ecx, eax
	INVOKE init_tetris_manager
	ret
new_tetris_manager ENDP

get_first_game_object_which_is_a PROC PUBLIC USES ebx ecx edx esi, objectType:DWORD
	local pScene:DWORD
	mov ecx, (GameObject PTR [ecx]).pParentScene
	mov pScene, ecx
	lea ecx, (Scene PTR [ecx]).gameObjects
	mov ebx, (UnorderedVector PTR [ecx]).count
	mov eax, (UnorderedVector PTR [ecx]).pData
	mov edx, 0
	.WHILE edx < ebx
		mov esi, [eax + edx*4]
		mov ecx, (GameObject PTR [esi]).gameObjectType
		.IF ecx == objectType
			mov eax, esi
			ret
		.ENDIF
		inc edx
	.ENDW
	mov eax, 0
	ret
get_first_game_object_which_is_a ENDP

tetris_manager_update PROC stdcall PUBLIC USES esi ebx edx, deltaTime:REAL4
	mov esi, ecx
	
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
