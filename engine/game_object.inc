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
