INCLUDE default_header.inc
INCLUDE game_object.inc
INCLUDE heap_functions.inc

.data
GAMEOBJECT_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET game_object_update, OFFSET game_object_exit, OFFSET free_game_object>

.code
init_game_object PROC PUBLIC USES esi, maxComponents:DWORD
	mov (GameObject PTR [ecx]).gameObjectType, DEFAULT_GAME_OBJECT_ID
	mov (GameObject PTR [ecx]).pVt, OFFSET GAMEOBJECT_VTABLE
	mov (GameObject PTR [ecx]).awaitingFree, 0
	lea ecx, (GameObject PTR [ecx]).components
	INVOKE init_unordered_vector, maxComponents
	ret
init_game_object ENDP

new_game_object PROC PUBLIC USES ecx, maxComponents:DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF GameObject
	mov ecx, eax
	INVOKE init_game_object, maxComponents
	ret
new_game_object ENDP

game_object_start PROC stdcall PUBLIC
	ret
game_object_start ENDP

game_object_update PROC stdcall PUBLIC, deltaTime:REAL4
	ret
game_object_update ENDP

game_object_exit PROC stdcall PUBLIC
	ret
game_object_exit ENDP
