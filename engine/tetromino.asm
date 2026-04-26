INCLUDE default_header.inc
INCLUDE tetromino.inc
INCLUDE heap_functions.inc
INCLUDE rect_component.inc
INCLUDE transform_component.inc
.data
TETROMINO_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET tetromino_update, OFFSET game_object_exit, OFFSET free_game_object>
.code

get_shape_offset PROC PRIVATE, typeId:DWORD, rotation:DWORD
    mov eax, typeId
    shl eax, 6                ; 64 bytes per type
    add eax, rotation
    shl eax, 4                ; 16 bytes per rotation
    ret
get_shape_offset ENDP

copy_shape PROC PRIVATE USES esi edi, pTetromino:DWORD, typeId:DWORD, rot:DWORD
    mov esi, pTetromino
    lea edi, (Tetromino PTR [esi]).shape
    INVOKE get_shape_offset, typeId, rot
    lea esi, SHAPES[eax]
    mov ecx, 16
    rep movsb
    ret
copy_shape ENDP

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

can_place PROC PRIVATE USES esi edi ebx, pBoard:DWORD, pTetromino:DWORD, dx_:SDWORD, dy_:SDWORD
    ; Checks whether the tetromino can be placed at the given offset
    ; Returns 1 if valid, 0 if collision or out of bounds
    ret
can_place ENDP

tetromino_update PROC stdcall PUBLIC USES esi ebx edx, deltaTime:REAL4
    mov esi, ecx
    ; Handles player input for movement and rotation
    INVOKE isKeyJustPressed, VK_LEFT
    .IF eax ; then attempt left movement  
    .ENDIF

    INVOKE isKeyJustPressed, VK_RIGHT
    .IF eax ; then attempt right movement
    .ENDIF

    INVOKE isKeyJustPressed, VK_DOWN
    .IF eax ; then soft drop
    .ENDIF

    INVOKE isKeyJustPressed, VK_UP
    .IF eax ; then rotate
    .ENDIF

    ; Automatic downward movement
    fld (Tetromino PTR [esi]).dropTimer
    fadd deltaTime
    fstp (Tetromino PTR [esi]).dropTimer

    .IF (Tetromino PTR [esi]).dropTimer > 0.4
        .IF can_place(...) == 0 ; then lock piece to board, clear completed lines, queue free, spawn new piece   
        .ELSE ; then move down one row
        .ENDIF
        mov (Tetromino PTR [esi]).dropTimer, 0.0
    .ENDIF
    ret
tetromino_update ENDP

end
