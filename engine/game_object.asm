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

free_game_object PROC PUBLIC
	lea ecx, (GameObject PTR [ecx]).components
	INVOKE free_unordered_vector
	INVOKE HeapFree, hHeap, 0, ecx
	ret
free_game_object ENDP

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

get_first_component_which_is_a PROC PUBLIC USES ecx edx esi, componentType:ENUM_COMPONENT_ID
	lea ecx, (GameObject PTR [ecx]).components
	mov ebx, (UnorderedVector PTR [ecx]).count
	mov eax, (UnorderedVector PTR [ecx]).pData
	mov edx, 0
	.WHILE edx < ebx
		mov esi, [eax + edx*4]
		.IF (Component PTR [esi]).componentType == componentType
			mov eax, esi
			ret
		.ENDIF
		inc edx
	.ENDW
	mov eax, 0
	ret
get_first_component_which_is_a ENDP

add_component PROC PUBLIC USES ecx, pGameObject:DWORD, pComponent:DWORD
	lea ecx, (GameObject PTR [pGameObject]).components
	INVOKE push_back, pComponent
	ret
add_component ENDP

game_object_start_virtual PROC PUBLIC USES ebx
	mov ebx, (GameObject PTR [ecx]).pVt
	mov ebx, (GameObject_vtable PTR [ebx]).pStart
	call ebx
	ret
game_object_start_virtual ENDP

game_object_update_virtual PROC stdcall PUBLIC USES ebx, deltaTime:REAL4
	mov ebx, (GameObject PTR [ecx]).pVt
	mov ebx, (GameObject_vtable PTR [ebx]).pUpdate
	push deltaTime
	call ebx
	ret
game_object_update_virtual ENDP
