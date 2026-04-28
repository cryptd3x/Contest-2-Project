; tetromino.asm
; Implements per-frame tetromino movement, rotation, soft-drop,
; automatic gravity, locking onto the board, and line clearing.
INCLUDE default_header.inc
INCLUDE tetromino.inc
INCLUDE heap_functions.inc
INCLUDE rect_component.inc
INCLUDE transform_component.inc
INCLUDE tetris_board.inc
INCLUDE component_ids.inc
INCLUDE game_object.inc
INCLUDE input_manager.inc
INCLUDE scene.inc
INCLUDE tetris_manager.inc

; --- FIX: Add missing function prototypes ---
GetTickCount        PROTO
game_object_start   PROTO
game_object_exit    PROTO

.data
TETROMINO_VTABLE GameObject_vtable < \
    OFFSET game_object_start, \
    OFFSET tetromino_update, \
    OFFSET game_object_exit, \
    OFFSET free_game_object >

; 4 rotations x 7 pieces x 16 bytes = 448 bytes
; Each rotation is stored as a 4x4 byte grid (1 = filled cell)
SHAPES LABEL BYTE
    ; --- I ---
    BYTE 0,0,0,0, 1,1,1,1, 0,0,0,0, 0,0,0,0
    BYTE 0,1,0,0, 0,1,0,0, 0,1,0,0, 0,1,0,0
    BYTE 0,0,0,0, 1,1,1,1, 0,0,0,0, 0,0,0,0
    BYTE 0,1,0,0, 0,1,0,0, 0,1,0,0, 0,1,0,0
    ; --- O ---
    BYTE 0,0,0,0, 0,1,1,0, 0,1,1,0, 0,0,0,0
    BYTE 0,0,0,0, 0,1,1,0, 0,1,1,0, 0,0,0,0
    BYTE 0,0,0,0, 0,1,1,0, 0,1,1,0, 0,0,0,0
    BYTE 0,0,0,0, 0,1,1,0, 0,1,1,0, 0,0,0,0
    ; --- T ---
    BYTE 0,1,0,0, 1,1,1,0, 0,0,0,0, 0,0,0,0
    BYTE 0,1,0,0, 0,1,1,0, 0,1,0,0, 0,0,0,0
    BYTE 0,0,0,0, 1,1,1,0, 0,1,0,0, 0,0,0,0
    BYTE 0,1,0,0, 1,1,0,0, 0,1,0,0, 0,0,0,0
    ; --- S ---
    BYTE 0,1,1,0, 1,1,0,0, 0,0,0,0, 0,0,0,0
    BYTE 0,1,0,0, 0,1,1,0, 0,0,1,0, 0,0,0,0
    BYTE 0,1,1,0, 1,1,0,0, 0,0,0,0, 0,0,0,0
    BYTE 0,1,0,0, 0,1,1,0, 0,0,1,0, 0,0,0,0
    ; --- Z ---
    BYTE 1,1,0,0, 0,1,1,0, 0,0,0,0, 0,0,0,0
    BYTE 0,0,1,0, 0,1,1,0, 0,1,0,0, 0,0,0,0
    BYTE 1,1,0,0, 0,1,1,0, 0,0,0,0, 0,0,0,0
    BYTE 0,0,1,0, 0,1,1,0, 0,1,0,0, 0,0,0,0
    ; --- J ---
    BYTE 1,0,0,0, 1,1,1,0, 0,0,0,0, 0,0,0,0
    BYTE 0,1,1,0, 0,1,0,0, 0,1,0,0, 0,0,0,0
    BYTE 0,0,0,0, 1,1,1,0, 0,0,1,0, 0,0,0,0
    BYTE 0,1,0,0, 0,1,0,0, 1,1,0,0, 0,0,0,0
    ; --- L ---
    BYTE 0,0,1,0, 1,1,1,0, 0,0,0,0, 0,0,0,0
    BYTE 0,1,0,0, 0,1,0,0, 0,1,1,0, 0,0,0,0
    BYTE 0,0,0,0, 1,1,1,0, 1,0,0,0, 0,0,0,0
    BYTE 1,1,0,0, 0,1,0,0, 0,1,0,0, 0,0,0,0

; BGRA colours per piece type (index 0-6 matching typeId)
PIECE_COLORS DWORD \
    0FFFFFF00h, \   ; I  cyan   (B=255,G=255,R=0,A=255)
    0FF00FFFFh, \   ; O  yellow
    0FF800080h, \   ; T  purple
    0FF00FF00h, \   ; S  green
    0FFFF0000h, \   ; Z  red    (B=0,G=0,R=255 in BGR order — swap as needed)
    0FF0000FFh, \   ; J  blue
    0FF00A5FFh      ; L  orange

; Normal gravity: one row per this many seconds
GRAVITY_INTERVAL REAL4 0.5

.code

; ------------------------------------------------------------------
; get_shape_offset  (private)
; Returns byte offset into SHAPES for (typeId, rotation).
; Each piece has 4 rotations x 16 bytes = 64 bytes.
; ------------------------------------------------------------------
get_shape_offset PROC PRIVATE, typeId:DWORD, rotation:DWORD
    mov eax, typeId
    imul eax, 64            ; 4 rotations * 16 bytes
    mov ecx, rotation
    imul ecx, 16
    add eax, ecx
    ret
get_shape_offset ENDP

; ------------------------------------------------------------------
; copy_shape  (private)
; Copies 16 shape bytes for (typeId, rotation) into Tetromino.shape.
; esi = Tetromino THIS pointer
; ------------------------------------------------------------------
copy_shape PROC PRIVATE USES esi edi ecx, pTetromino:DWORD, typeId:DWORD, rot:DWORD
    INVOKE get_shape_offset, typeId, rot
    mov esi, pTetromino
    lea edi, (Tetromino PTR [esi]).shape
    lea esi, SHAPES[eax]
    mov ecx, 16
    rep movsb
    ret
copy_shape ENDP

; ------------------------------------------------------------------
; can_place  (PUBLIC)
; Tests whether pTetromino can move by (dx, dy) without colliding.
; Returns 1 if the move is valid, 0 if not.
; ecx = Tetromino THIS pointer when called internally; pTetromino
; parameter carries the value so callers can pass it explicitly.
; ------------------------------------------------------------------
can_place PROC PUBLIC USES esi edi ebx edx,
        pBoard      : DWORD,
        pTetromino  : DWORD,
        dx_         : SDWORD,
        dy_         : SDWORD

    local tx : SDWORD
    local ty : SDWORD

    ; Get current transform position
    mov ecx, pTetromino
    INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID
    cmp eax, 0
    jne got_transform
    
    ; Transform component not found
    mov eax, 0
    ret

got_transform:
    mov esi, eax
    mov eax, (TransformComponent PTR [esi]).x
    add eax, dx_
    mov tx, eax
    mov eax, (TransformComponent PTR [esi]).y
    add eax, dy_
    mov ty, eax

    ; Walk the 4x4 shape
    mov esi, pTetromino
    lea esi, (Tetromino PTR [esi]).shape
    mov ecx, 0

shape_loop:
    cmp ecx, 16
    jge shape_done

    movzx eax, BYTE PTR [esi + ecx]
    cmp eax, 0
    je next_cell

    ; row = ecx / 4,  col = ecx % 4
    mov eax, ecx
    xor edx, edx
    mov ebx, 4
    div ebx             ; eax = row (quotient), edx = col (remainder)

    mov edi, eax        ; edi = row in piece
    add edi, ty         ; board row

    mov ebx, edx        ; ebx = col in piece
    add ebx, tx         ; board col

    ; Bounds: column must be [0, BOARD_WIDTH), row must be < BOARD_HEIGHT
    ; Check ebx < 0
    cmp ebx, 0
    jl out_of_bounds
    
    ; Check ebx >= TETRIS_BOARD_WIDTH
    cmp ebx, TETRIS_BOARD_WIDTH
    jge out_of_bounds
    
    ; Check edi >= TETRIS_BOARD_HEIGHT
    cmp edi, TETRIS_BOARD_HEIGHT
    jge out_of_bounds

    ; Rows above the top of the board are fine (piece spawning)
    cmp edi, 0
    jl next_cell

    ; Check the locked grid for collisions
    mov eax, edi
    mov edx, TETRIS_BOARD_WIDTH
    mul edx
    add eax, ebx
    mov edi, pBoard
    lea edi, (TetrisBoard PTR [edi]).grid
    movzx edx, BYTE PTR [edi + eax]
    cmp edx, 0
    jne out_of_bounds
    jmp next_cell

out_of_bounds:
    ; Collision or out of bounds detected
    mov eax, 0
    ret

next_cell:
    inc ecx
    jmp shape_loop

shape_done:
    ; Successfully checked all cells without collision
    mov eax, 1
    ret
can_place ENDP

; ------------------------------------------------------------------
; init_tetromino
; ------------------------------------------------------------------
init_tetromino PROC PUBLIC USES esi ecx
    ; --- FIX: Use LOCAL stack variables to bypass INVOKE register clobbering ---
    LOCAL b_val:BYTE
    LOCAL g_val:BYTE
    LOCAL r_val:BYTE
    LOCAL a_val:BYTE

    INVOKE init_game_object, 2
    mov (GameObject PTR [ecx]).gameObjectType, TETROMINO_GAME_OBJECT_ID
    mov (GameObject PTR [ecx]).pVt, OFFSET TETROMINO_VTABLE
    mov esi, ecx

    ; Zero the shape and set initial state
    mov (Tetromino PTR [esi]).rotation, 0
    ; --- FIX: 0.0 is exactly 0 in 32-bit float. Use an integer assignment ---
    mov DWORD PTR (Tetromino PTR [esi]).dropTimer, 0

    ; Random piece type: GetTickCount % 7
    INVOKE GetTickCount
    xor edx, edx
    mov ecx, 7
    div ecx
    mov (Tetromino PTR [esi]).typeId, edx   ; edx = remainder 0-6
    INVOKE copy_shape, esi, edx, 0

    ; TransformComponent: start at column 3, row -1 (just above board)
    INVOKE new_transform_component, 3, -1, 0
    INVOKE add_component, esi, eax

    ; RectComponent: 1x1 cell, colour from PIECE_COLORS
    mov eax, (Tetromino PTR [esi]).typeId
    shl eax, 2                              ; multiply by 4
    mov ecx, PIECE_COLORS[eax]              ; packed BGRA

    ; Extract colors cleanly into local variables
    mov b_val, cl
    shr ecx, 8
    mov g_val, cl
    shr ecx, 8
    mov r_val, cl
    shr ecx, 8
    mov a_val, cl

    ; Safely invoke the function with local variables
    INVOKE new_rect_component, 1, 1, b_val, g_val, r_val, a_val
    
    INVOKE add_component, esi, eax
    mov eax, esi
    ret
init_tetromino ENDP

; ------------------------------------------------------------------
; new_tetromino
; Allocates heap memory and calls init_tetromino.
; Returns pointer in eax.
; ------------------------------------------------------------------
new_tetromino PROC PUBLIC USES ecx
    INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF Tetromino
    mov ecx, eax
    INVOKE init_tetromino
    ret
new_tetromino ENDP

; ------------------------------------------------------------------
; tetromino_update  (virtual update)
; Handles left/right/rotate input, soft-drop, gravity, locking, and
; signals TetrisManager that a new piece should be spawned.
;
; ecx = THIS pointer (Tetromino)
; ------------------------------------------------------------------
tetromino_update PROC stdcall PUBLIC USES esi ebx edx, deltaTime:REAL4
    mov esi, ecx

    ; ----------------------------------------------------------------
    ; Left arrow
    ; ----------------------------------------------------------------
    INVOKE isKeyJustPressed, VK_LEFT
    .IF eax
        mov ecx, esi
        INVOKE get_first_game_object_which_is_a, TETRIS_BOARD_GAME_OBJECT_ID
        mov ebx, eax
        .IF ebx != 0
            INVOKE can_place, ebx, esi, -1, 0
            .IF eax
                mov ecx, esi
                INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID
                .IF eax != 0
                    dec (TransformComponent PTR [eax]).x
                .ENDIF
            .ENDIF
        .ENDIF
    .ENDIF

    ; ----------------------------------------------------------------
    ; Right arrow
    ; ----------------------------------------------------------------
    INVOKE isKeyJustPressed, VK_RIGHT
    .IF eax
        mov ecx, esi
        INVOKE get_first_game_object_which_is_a, TETRIS_BOARD_GAME_OBJECT_ID
        mov ebx, eax
        .IF ebx != 0
            INVOKE can_place, ebx, esi, 1, 0
            .IF eax
                mov ecx, esi
                INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID
                .IF eax != 0
                    inc (TransformComponent PTR [eax]).x
                .ENDIF
            .ENDIF
        .ENDIF
    .ENDIF

    ; ----------------------------------------------------------------
    ; Rotate (up arrow) — try rotation; revert if it collides
    ; ----------------------------------------------------------------
    INVOKE isKeyJustPressed, VK_UP
    .IF eax
        mov ebx, (Tetromino PTR [esi]).rotation
        inc ebx
        and ebx, 3
        mov (Tetromino PTR [esi]).rotation, ebx
        INVOKE copy_shape, esi, (Tetromino PTR [esi]).typeId, ebx

        mov ecx, esi
        INVOKE get_first_game_object_which_is_a, TETRIS_BOARD_GAME_OBJECT_ID
        .IF eax != 0
            INVOKE can_place, eax, esi, 0, 0
            .IF eax == 0
                ; Revert rotation
                mov ebx, (Tetromino PTR [esi]).rotation
                dec ebx
                and ebx, 3
                mov (Tetromino PTR [esi]).rotation, ebx
                INVOKE copy_shape, esi, (Tetromino PTR [esi]).typeId, ebx
            .ENDIF
        .ENDIF
    .ENDIF

    ; ----------------------------------------------------------------
    ; Gravity accumulation
    ; Soft drop (down arrow) accelerates the drop timer threshold.
    ; ----------------------------------------------------------------
    fld (Tetromino PTR [esi]).dropTimer
    fadd deltaTime
    fstp (Tetromino PTR [esi]).dropTimer

    ; Threshold: 0.5 s normally, 0.05 s during soft drop
    mov edx, 0
    INVOKE isKeyPressed, VK_DOWN
    .IF eax
        mov edx, 1
    .ENDIF

    ; Compare dropTimer against threshold using FPU
    fld (Tetromino PTR [esi]).dropTimer
    .IF edx                         ; soft drop threshold
        fld REAL4 PTR [softDropThresh]
    .ELSE
        fld GRAVITY_INTERVAL
    .ENDIF
    fcompp
    fnstsw ax
    sahf
    jb gravityNotReady              ; dropTimer < threshold → nothing yet

    ; ----------------------------------------------------------------
    ; Try to move down one row
    ; ----------------------------------------------------------------
    mov ecx, esi
    INVOKE get_first_game_object_which_is_a, TETRIS_BOARD_GAME_OBJECT_ID
    mov ebx, eax
    .IF ebx != 0
        INVOKE can_place, ebx, esi, 0, 1
        .IF eax
            ; Move down
            mov ecx, esi
            INVOKE get_first_component_which_is_a, TRANSFORM_COMPONENT_ID
            .IF eax != 0
                inc (TransformComponent PTR [eax]).y
            .ENDIF
        .ELSE
            ; --------------------------------------------------------
            ; Cannot move down — lock the piece onto the board
            ; --------------------------------------------------------
            INVOKE board_lock_tetromino, ebx, esi
            INVOKE board_clear_lines, ebx

            ; Signal TetrisManager: clear its activeTetromino pointer
            ; so it knows to spawn the next piece next frame
            mov ecx, esi
            INVOKE get_first_game_object_which_is_a, TETRIS_MANAGER_GAME_OBJECT_ID
            .IF eax != 0
                mov (TetrisManager PTR [eax]).activeTetromino, 0
            .ENDIF

            ; Queue this tetromino for deletion
            mov ecx, (GameObject PTR [esi]).pParentScene
            INVOKE queue_free_game_object, esi
        .ENDIF
    .ENDIF

    ; --- FIX: 0.0 is exactly 0 in 32-bit float. Use an integer assignment ---
    mov DWORD PTR (Tetromino PTR [esi]).dropTimer, 0

gravityNotReady:
    ret
tetromino_update ENDP

.data
softDropThresh REAL4 0.05

END