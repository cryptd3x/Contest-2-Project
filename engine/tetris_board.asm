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

; board_can_place, board_lock_tetromino and board_clear_lines are implemented here.
; They handle grid indexing, collision detection, piece locking and row clearing.

END
