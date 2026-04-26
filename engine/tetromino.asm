INCLUDE default_header.inc
INCLUDE tetromino.inc
INCLUDE heap_functions.inc
INCLUDE rect_component.inc
INCLUDE transform_component.inc
.data
TETROMINO_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET tetromino_update, OFFSET game_object_exit, OFFSET free_game_object>
.code

init_tetromino PROC PUBLIC USES esi ecx
    INVOKE init_game_object, 2
    mov (GameObject PTR [ecx]).gameObjectType, TETROMINO_GAME_OBJECT_ID
    mov (GameObject PTR [ecx]).pVt, OFFSET TETROMINO_VTABLE
    mov esi, ecx
    mov (Tetromino PTR [esi]).rotation, 0
    mov (Tetromino PTR [esi]).dropTimer, 0.0

    INVOKE GetTickCount
    xor edx, edx
    mov ecx, 7
    div ecx
    mov (Tetromino PTR [esi]).typeId, edx

    INVOKE copy_shape, esi, edx, 0
    INVOKE new_transform_component, 3, -1, 0
    INVOKE add_component, esi, eax
    INVOKE new_rect_component, 4, 4, 255, 255, 255, 255
    INVOKE add_component, esi, eax

    mov eax, esi
    ret
init_tetromino ENDP

new_tetromino PROC PUBLIC USES ecx
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF Tetromino
	mov ecx, eax
	INVOKE init_tetromino
	ret
new_tetromino ENDP


tetromino_update PROC stdcall PUBLIC USES ecx, deltaTime:REAL4
	ret
tetromino_update ENDP

end
