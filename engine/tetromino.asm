INCLUDE default_header.inc
INCLUDE tetromino.inc
INCLUDE heap_functions.inc
INCLUDE transform_component.inc
INCLUDE tetris_board.inc
INCLUDE component_ids.inc

.data
TETROMINO_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET tetromino_update, OFFSET game_object_exit, OFFSET free_game_object>

; 4x4 shapes for each piece type across 4 rotations (flat layout)
SHAPES LABEL BYTE
    ; I
    BYTE 0,0,0,0, 1,1,1,1, 0,0,0,0, 0,0,0,0
    BYTE 0,1,0,0, 0,1,0,0, 0,1,0,0, 0,1,0,0
    BYTE 0,0,0,0, 1,1,1,1, 0,0,0,0, 0,0,0,0
    BYTE 0,1,0,0, 0,1,0,0, 0,1,0,0, 0,1,0,0
    ; O
    BYTE 0,0,0,0, 0,1,1,0, 0,1,1,0, 0,0,0,0
    BYTE 0,0,0,0, 0,1,1,0, 0,1,1,0, 0,0,0,0
    BYTE 0,0,0,0, 0,1,1,0, 0,1,1,0, 0,0,0,0
    BYTE 0,0,0,0, 0,1,1,0, 0,1,1,0, 0,0,0,0
    ; T
    BYTE 0,1,0,0, 1,1,1,0, 0,0,0,0, 0,0,0,0
    BYTE 0,1,0,0, 0,1,1,0, 0,1,0,0, 0,0,0,0
    BYTE 0,0,0,0, 1,1,1,0, 0,1,0,0, 0,0,0,0
    BYTE 0,1,0,0, 1,1,0,0, 0,1,0,0, 0,0,0,0
    ; S
    BYTE 0,1,1,0, 1,1,0,0, 0,0,0,0, 0,0,0,0
    BYTE 0,1,0,0, 0,1,1,0, 0,0,1,0, 0,0,0,0
    BYTE 0,1,1,0, 1,1,0,0, 0,0,0,0, 0,0,0,0
    BYTE 0,1,0,0, 0,1,1,0, 0,0,1,0, 0,0,0,0
    ; Z
    BYTE 1,1,0,0, 0,1,1,0, 0,0,0,0, 0,0,0,0
    BYTE 0,0,1,0, 0,1,1,0, 0,1,0,0, 0,0,0,0
    BYTE 1,1,0,0, 0,1,1,0, 0,0,0,0, 0,0,0,0
    BYTE 0,0,1,0, 0,1,1,0, 0,1,0,0, 0,0,0,0
    ; J
    BYTE 1,0,0,0, 1,1,1,0, 0,0,0,0, 0,0,0,0
    BYTE 0,1,1,0, 0,1,0,0, 0,1,0,0, 0,0,0,0
    BYTE 0,0,0,0, 1,1,1,0, 0,0,1,0, 0,0,0,0
    BYTE 0,1,0,0, 0,1,0,0, 1,1,0,0, 0,0,0,0
    ; L
    BYTE 0,0,1,0, 1,1,1,0, 0,0,0,0, 0,0,0,0
    BYTE 0,1,0,0, 0,1,0,0, 0,1,1,0, 0,0,0,0
    BYTE 0,0,0,0, 1,1,1,0, 1,0,0,0, 0,0,0,0
    BYTE 1,1,0,0, 0,1,0,0, 0,1,0,0, 0,0,0,0

PIECE_COLORS DWORD \
    0FF00FFFFh,  ; I
    0FFFFFF00h,  ; O
    0FF800080h,  ; T
    0FF00FF00h,  ; S
    0FFFF0000h,  ; Z
    0FF0000FFh,  ; J
    0FFFFA500h   ; L
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

can_place PROC PRIVATE USES esi edi ebx edx, pBoard:DWORD, pTetromino:DWORD, dx_:SDWORD, dy_:SDWORD
    local tx:SDWORD, ty:SDWORD, bx:SDWORD, by:SDWORD, cell:BYTE

    mov esi, pTetromino
    lea edi, (Tetromino PTR [esi]).shape

    INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID
    mov esi, eax
    mov ebx, (TransformComponent PTR [esi]).x
    add ebx, dx_
    mov tx, ebx
    mov ebx, (TransformComponent PTR [esi]).y
    add ebx, dy_
    mov ty, ebx

    mov esi, pTetromino
    mov ecx, 0
	.WHILE ecx < 16
        mov al, [edi + ecx]
        mov cell, al
        .IF cell != 0
            mov eax, ecx
            mov edx, 0
            mov ebx, 4
            div ebx
            mov by, eax
            mov bx, dx
            mov bx, word ptr dx   ; column
            movsx eax, bx
            add eax, tx
            mov bx, word ptr ax   ; board x
            mov eax, by
            add eax, ty
            mov by, eax

			; bounds check
            .IF bx < 0 || bx >= TETRIS_BOARD_WIDTH || by >= TETRIS_BOARD_HEIGHT
                mov eax, 0
                ret
            .ENDIF
            .IF by < 0
                inc ecx
                .CONTINUE
            .ENDIF

            ; check board grid
            mov esi, pBoard
            lea esi, (TetrisBoard PTR [esi]).grid
            mov eax, by
            mov ebx, TETRIS_BOARD_WIDTH
            mul ebx
            add eax, bx
            mov al, [esi + eax]
			.IF al != 0
                mov eax, 0
                ret
            .ENDIF
        .ENDIF
        inc ecx
    .ENDW
    mov eax, 1
    ret
can_place ENDP

tetromino_update PROC stdcall PUBLIC USES esi ebx edx, deltaTime:REAL4
    mov esi, ecx

    ; Left
    INVOKE isKeyJustPressed, VK_LEFT
    .IF eax
        INVOKE get_first_game_object_which_is_a, TETRIS_BOARD_GAME_OBJECT_ID
        INVOKE can_place, eax, esi, -1, 0
        .IF eax
            INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID
            dec (TransformComponent PTR [eax]).x
        .ENDIF
    .ENDIF

    ; Right
    INVOKE isKeyJustPressed, VK_RIGHT
    .IF eax
        INVOKE get_first_game_object_which_is_a, TETRIS_BOARD_GAME_OBJECT_ID
        INVOKE can_place, eax, esi, 1, 0
        .IF eax
            INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID
            inc (TransformComponent PTR [eax]).x
        .ENDIF
    .ENDIF

    ; Down (soft drop)
    INVOKE isKeyPressed, VK_DOWN
    .IF eax
        mov (Tetromino PTR [esi]).dropTimer, 0.05   ; faster drop
    .ENDIF

    ; Rotate
    INVOKE isKeyJustPressed, VK_UP
    .IF eax
        ; simple rotation logic (full implementation would validate after rotate)
        mov ebx, (Tetromino PTR [esi]).rotation
        inc ebx
        and ebx, 3
        mov (Tetromino PTR [esi]).rotation, ebx
        INVOKE get_first_game_object_which_is_a, TETRIS_BOARD_GAME_OBJECT_ID
        INVOKE can_place, eax, esi, 0, 0
        .IF eax == 0
            ; revert rotation if invalid
            dec (Tetromino PTR [esi]).rotation
            and (Tetromino PTR [esi]).rotation, 3
        .ELSE
            INVOKE copy_shape, esi, (Tetromino PTR [esi]).typeId, ebx
        .ENDIF
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
