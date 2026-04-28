; tetris_manager.asm
INCLUDE default_header.inc
INCLUDE tetris_manager.inc
INCLUDE heap_functions.inc
INCLUDE tetromino.inc
INCLUDE tetris_board.inc
INCLUDE game_object.inc
INCLUDE scene.inc

game_object_start   PROTO
game_object_exit    PROTO
can_place           PROTO pBoard:DWORD, pTetromino:DWORD, dx_:SDWORD, dy_:SDWORD
can_place_at_spawn  PROTO pBoard:DWORD, pTetromino:DWORD
MessageBoxA         PROTO hWnd:DWORD, lpText:DWORD, lpCaption:DWORD, uType:DWORD

.data
TETRIS_MANAGER_VTABLE GameObject_vtable < \
    OFFSET game_object_start, \
    OFFSET tetris_manager_update, \
    OFFSET game_object_exit, \
    OFFSET free_game_object >

INITIAL_SPAWN_DELAY REAL4 0.3

.code

init_tetris_manager PROC PUBLIC USES ecx esi
    ; ---> CRITICAL FIX: Secure ecx in esi immediately so it survives the function call! <---
    mov esi, ecx
    mov ecx, esi
    INVOKE init_game_object, 2
    
    mov (GameObject PTR [esi]).gameObjectType, TETRIS_MANAGER_GAME_OBJECT_ID
    mov (GameObject PTR [esi]).pVt, OFFSET TETRIS_MANAGER_VTABLE
    mov (TetrisManager PTR [esi]).activeTetromino, 0
    mov (TetrisManager PTR [esi]).score,            0
    mov (TetrisManager PTR [esi]).level,            1
    mov (TetrisManager PTR [esi]).linesCleared,     0
    
    fld INITIAL_SPAWN_DELAY
    fstp (TetrisManager PTR [esi]).spawnTimer
    ret
init_tetris_manager ENDP

new_tetris_manager PROC PUBLIC USES ecx
    INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF TetrisManager
    mov ecx, eax
    INVOKE init_tetris_manager
    mov eax, ecx
    ret
new_tetris_manager ENDP

spawn_next_tetromino PROC PRIVATE USES esi ebx, pManager : DWORD
    local pBoard : DWORD

    mov ecx, pManager
    INVOKE get_first_game_object_which_is_a, TETRIS_BOARD_GAME_OBJECT_ID
    mov pBoard, eax

    INVOKE new_tetromino
    mov esi, eax

    .IF pBoard != 0
        INVOKE can_place_at_spawn, pBoard, esi
        .IF eax == 0
            ; ---> CRITICAL FIX: Safe heap free to prevent Game Over crash <---
            INVOKE HeapFree, hHeap, 0, esi
            mov eax, 0
            ret
        .ENDIF
    .ENDIF

    mov ecx, pManager
    mov ecx, (GameObject PTR [ecx]).pParentScene
    INVOKE instantiate_game_object, esi

    mov eax, esi
    ret
spawn_next_tetromino ENDP

can_place_at_spawn PROC PRIVATE, pBoard:DWORD, pTetromino:DWORD
    mov ecx, pTetromino
    INVOKE can_place, pBoard, pTetromino, 0, 0
    ret
can_place_at_spawn ENDP

tetris_manager_update PROC stdcall PUBLIC USES esi ebx, deltaTime:REAL4
    mov esi, ecx

    mov eax, (TetrisManager PTR [esi]).activeTetromino
    .IF eax != 0
        ret
    .ENDIF

    ; ---> CRITICAL FIX: Use 'fsub memory' to prevent the FPU stack overflow! <---
    fld (TetrisManager PTR [esi]).spawnTimer
    fsub deltaTime
    fstp (TetrisManager PTR [esi]).spawnTimer

    fld (TetrisManager PTR [esi]).spawnTimer
    fldz
    fcompp
    fnstsw ax
    sahf
    
    ; ---> CRITICAL FIX: Jump if Below (Wait until spawnTimer drops below 0.0) <---
    jb spawnNotReady

    INVOKE spawn_next_tetromino, esi
    .IF eax != 0
        mov (TetrisManager PTR [esi]).activeTetromino, eax
        fld INITIAL_SPAWN_DELAY
        fstp (TetrisManager PTR [esi]).spawnTimer
    .ENDIF

spawnNotReady:
    ret
tetris_manager_update ENDP

END