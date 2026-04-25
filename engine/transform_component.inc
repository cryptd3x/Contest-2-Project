; transform_component.inc
IFNDEF TRANSFORM_COMPONENT_INC
TRANSFORM_COMPONENT_INC EQU 1

INCLUDE component.inc

TransformComponent STRUCT
	baseComponent Component <>
	x SDWORD ?
	y SDWORD ?
	ignoreCamera DWORD ?
TransformComponent ENDS

init_transform_component PROTO x: DWORD, y: DWORD, ignoreCamera: DWORD
new_transform_component PROTO x: DWORD, y: DWORD, ignoreCamera: DWORD

ENDIF
