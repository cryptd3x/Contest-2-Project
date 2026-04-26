INCLUDE default_header.inc
INCLUDE tetris_board.inc
INCLUDE heap_functions.inc
INCLUDE tetromino.inc
INCLUDE transform_component.inc

.data
TETRIS_BOARD_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET tetris_board_update, OFFSET game_object_exit, OFFSET free_game_object>

.code

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

board_can_place PROC PUBLIC USES esi edi, pBoard:DWORD, pTetromino:DWORD, dx:SDWORD, dy:SDWORD
    INVOKE can_place, pBoard, pTetromino, dx, dy
    ret
board_can_place ENDP

board_lock_tetromino PROC PUBLIC USES esi edi ebx edx, pBoard:DWORD, pTetromino:DWORD
    local tx:SDWORD, ty:SDWORD

    mov esi, pTetromino
    lea edi, (Tetromino PTR [esi]).shape

    INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID
    mov esi, eax
    mov ebx, (TransformComponent PTR [esi]).x
    mov tx, ebx
    mov ebx, (TransformComponent PTR [esi]).y
    mov ty, ebx

    mov esi, pTetromino
    mov ecx, 0
    .WHILE ecx < 16
        .IF BYTE PTR [edi + ecx] != 0
            mov eax, ecx
            mov edx, 0
            mov ebx, 4
            div ebx
            mov ebx, eax          ; row
            add ebx, ty
            mov eax, edx          ; col
            add eax, tx

END
