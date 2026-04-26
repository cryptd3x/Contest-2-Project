INCLUDE default_header.inc
INCLUDE tetromino.inc
INCLUDE heap_functions.inc
INCLUDE rect_component.inc
INCLUDE transform_component.inc
.data
TETROMINO_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET tetromino_update, OFFSET game_object_exit, OFFSET free_game_object>
.code

; // BUG FIX: was "USES esi, ecx" — comma terminated USES list early,
; //   making ecx a phantom parameter instead of a saved register.
; //   Correct MASM syntax is space-separated: USES esi ecx
; // BUG FIX: entire proc body was duplicated outside any PROC (lines 21-29),
; //   causing a second unmatched ENDP and assembler errors. Duplicate removed.
; // BUG FIX: missing "mov eax, ecx" before ret — new_tetromino was returning
; //   whatever add_component left in eax (the component ptr), not the Tetromino ptr.
init_tetromino PROC PUBLIC USES esi ecx
	INVOKE init_game_object, 2
	mov (GameObject PTR [ecx]).gameObjectType, TETROMINO_GAME_OBJECT_ID
	mov (GameObject PTR [ecx]).pVt, OFFSET TETROMINO_VTABLE
	INVOKE new_transform_component, 40, 5, 0
	INVOKE add_component, ecx, eax
	INVOKE new_rect_component, 4, 4, 0, 255, 0, 255
	INVOKE add_component, ecx, eax
	mov eax, ecx                           ; // Return the Tetromino pointer
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
