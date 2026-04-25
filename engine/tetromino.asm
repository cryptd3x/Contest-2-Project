INCLUDE default_header.inc
INCLUDE tetromino.inc
INCLUDE heap_functions.inc
INCLUDE rect_component.inc
INCLUDE transform_component.inc
.data
TETROMINO_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET tetromino_update, OFFSET game_object_exit, OFFSET free_game_object>
.code

init_tetromino PROC PUBLIC USES esi, ecx
	INVOKE init_game_object, 2
	mov (GameObject PTR [ecx]).gameObjectType, TETROMINO_GAME_OBJECT_ID
	mov (GameObject PTR [ecx]).pVt, OFFSET TETROMINO_VTABLE
	INVOKE new_transform_component, 40, 5, 0
	INVOKE add_component, ecx, eax
	INVOKE new_rect_component, 4, 4, 0, 255, 0, 255
	INVOKE add_component, ecx, eax
	ret
init_tetromino ENDP
