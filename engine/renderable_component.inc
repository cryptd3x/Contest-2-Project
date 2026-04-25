; renderable_component.inc
IFNDEF RENDERABLE_COMPONENT_INC
RENDERABLE_COMPONENT_INC EQU 1

INCLUDE component.inc

RenderableComponent STRUCT
	baseComponent Component <>
	visible DWORD ?
	layer DWORD ?
RenderableComponent ENDS

init_renderable_component PROTO visible: DWORD, layer: DWORD

ENDIF
