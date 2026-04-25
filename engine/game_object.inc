IFNDEF GAME_OBJECT_INC
GAME_OBJECT_INC EQU 1

INCLUDE game_object_ids.inc
INCLUDE unordered_vector.inc
INCLUDE component_ids.inc

GameObject_vtable STRUCT
	pStart DWORD ?
	pUpdate DWORD ?
	pExit DWORD ?
	pFree DWORD ?
GameObject_vtable ENDS

GameObject STRUCT
	gameObjectType ENUM_GAME_OBJECT_ID ?
	components UnorderedVector <>
	pVt DWORD ?
	pParentScene DWORD ?
	awaitingFree DWORD ?
GameObject ENDS

add_component PROTO pGameObject:DWORD, pComponent:DWORD
get_first_component_which_is_a PROTO componentType:ENUM_COMPONENT_ID
game_object_start_virtual PROTO
game_object_update_virtual PROTO deltaTime:REAL4
game_object_free_virtual PROTO

init_game_object PROTO maxComponents:DWORD
new_game_object PROTO maxComponents:DWORD
free_game_object PROTO

ENDIF
