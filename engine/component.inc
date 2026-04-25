; component.inc
IFNDEF COMPONENT_INC
COMPONENT_INC EQU 1

INCLUDE component_ids.inc

Component_vtable STRUCT
	pFree DWORD ?
Component_vtable ENDS

Component STRUCT
	componentType ENUM_COMPONENT_ID ?
	pVt DWORD ?
Component ENDS

init_component PROTO
new_component PROTO
free_component_virtual PROTO

ENDIF
