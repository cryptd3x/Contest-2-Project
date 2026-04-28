; tetris_board.asm
INCLUDE default_header.inc
INCLUDE tetris_board.inc
INCLUDE heap_functions.inc
INCLUDE tetromino.inc
INCLUDE transform_component.inc
INCLUDE component_ids.inc
INCLUDE game_object.inc

can_place PROTO pBoard:DWORD, pTetromino:DWORD, dx_:SDWORD, dy_:SDWORD
game_object_start   PROTO
game_object_exit    PROTO

.data
TETRIS_BOARD_VTABLE GameObject_vtable < \
    OFFSET game_object_start, \
    OFFSET tetris_board_update, \
    OFFSET game_object_exit, \
    OFFSET free_game_object >

.code

init_tetris_board PROC PUBLIC USES ecx esi edi
    ; ---> CRITICAL FIX: Secure ecx in esi immediately! <---
    mov esi, ecx
    mov ecx, esi
    INVOKE init_game_object, 1
    
    mov (GameObject PTR [esi]).gameObjectType, TETRIS_BOARD_GAME_OBJECT_ID
    mov (GameObject PTR [esi]).pVt, OFFSET TETRIS_BOARD_VTABLE

    lea edi, (TetrisBoard PTR [esi]).grid
    mov ecx, TETRIS_BOARD_WIDTH * TETRIS_BOARD_HEIGHT
    xor eax, eax
    rep stosb
    mov ecx, esi
    ret
init_tetris_board ENDP

new_tetris_board PROC PUBLIC USES ecx
    INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF TetrisBoard
    mov ecx, eax
    INVOKE init_tetris_board
    mov eax, ecx
    ret
new_tetris_board ENDP

tetris_board_update PROC stdcall PUBLIC, deltaTime:REAL4
    ret
tetris_board_update ENDP

board_can_place PROC PUBLIC, pBoard:DWORD, pTetromino:DWORD, dx_:SDWORD, dy_:SDWORD
    INVOKE can_place, pBoard, pTetromino, dx_, dy_
    ret
board_can_place ENDP

board_lock_tetromino PROC PUBLIC USES esi edi ebx ecx edx, pBoard:DWORD, pTetromino:DWORD
    local tx : SDWORD
    local ty : SDWORD

    mov ecx, pTetromino
    INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID
    cmp eax, 0
    je lock_done

    mov esi, eax
    mov eax, (TransformComponent PTR [esi]).x
    mov tx, eax
    mov eax, (TransformComponent PTR [esi]).y
    mov ty, eax

    mov esi, pTetromino
    lea edi, (Tetromino PTR [esi]).shape
    mov ecx, 0

lock_loop:
    cmp ecx, 16
    jge lock_done

    movzx eax, BYTE PTR [edi + ecx]
    cmp eax, 0
    je lock_next

    mov eax, ecx
    xor edx, edx
    mov ebx, 4
    div ebx

    mov ebx, eax        
    add ebx, ty         
    mov eax, edx        
    add eax, tx         

    cmp ebx, 0
    jl lock_next
    cmp ebx, TETRIS_BOARD_HEIGHT
    jge lock_next
    cmp eax, 0
    jl lock_next
    cmp eax, TETRIS_BOARD_WIDTH
    jge lock_next

    push eax
    mov eax, ebx
    mov edx, TETRIS_BOARD_WIDTH
    mul edx
    pop edx
    add eax, edx

    mov edx, pTetromino
    movzx edx, BYTE PTR [(Tetromino PTR [edx]).typeId]
    inc edx

    mov esi, pBoard
    lea esi, (TetrisBoard PTR [esi]).grid
    mov BYTE PTR [esi + eax], dl

lock_next:
    inc ecx
    jmp lock_loop

lock_done:
    ret
board_lock_tetromino ENDP

board_clear_lines PROC PUBLIC USES esi edi ebx ecx edx, pBoard : DWORD
    local gridBase  : DWORD
    local readRow   : DWORD
    local writeRow  : DWORD
    local rowFull   : DWORD
    local col       : DWORD

    mov esi, pBoard
    lea esi, (TetrisBoard PTR [esi]).grid
    mov gridBase, esi

    mov readRow,  (TETRIS_BOARD_HEIGHT - 1)
    mov writeRow, (TETRIS_BOARD_HEIGHT - 1)

compact_loop_start:
    cmp readRow, -1
    je compact_loop_end

    mov eax, readRow
    mov ebx, TETRIS_BOARD_WIDTH
    mul ebx
    mov esi, gridBase
    add esi, eax                

    mov rowFull, 1
    mov col, 0
col_check_loop:
    cmp col, TETRIS_BOARD_WIDTH
    jge col_check_end

    mov eax, col
    movzx ecx, BYTE PTR [esi + eax]
    cmp ecx, 0
    jne col_check_next

    mov rowFull, 0
    jmp col_check_end

col_check_next:
    inc col
    jmp col_check_loop

col_check_end:
    cmp rowFull, 0
    jne skip_copy

    mov eax, readRow
    cmp eax, writeRow
    je do_dec_writeRow

    mov eax, writeRow
    mov ebx, TETRIS_BOARD_WIDTH
    mul ebx
    mov edi, gridBase
    add edi, eax            

    mov ecx, TETRIS_BOARD_WIDTH
    rep movsb

do_dec_writeRow:
    dec writeRow

skip_copy:
    dec readRow
    jmp compact_loop_start

compact_loop_end:

zero_loop_start:
    cmp writeRow, -1
    je zero_loop_end

    mov eax, writeRow
    mov ebx, TETRIS_BOARD_WIDTH
    mul ebx
    mov edi, gridBase
    add edi, eax
    mov ecx, TETRIS_BOARD_WIDTH
    xor eax, eax
    rep stosb
    
    dec writeRow
    jmp zero_loop_start

zero_loop_end:
    ret
board_clear_lines ENDP

END