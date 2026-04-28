; rect_component.inc
; A RectComponent stores the colour of a renderable block.
; Width and height are measured in board cells, not pixels.
IFNDEF RECT_COMPONENT_INC
RECT_COMPONENT_INC EQU 1

INCLUDE component.inc

RectComponent STRUCT
    baseComponent   Component <>
    width_          DWORD ?     ; width  in board cells
    height_         DWORD ?     ; height in board cells
    colorBGRA       DWORD ?     ; packed BGRA (B, G, R, A)
RectComponent ENDS

init_rect_component PROTO width_:DWORD, height_:DWORD, b:BYTE, g:BYTE, r:BYTE, a:BYTE
new_rect_component  PROTO width_:DWORD, height_:DWORD, b:BYTE, g:BYTE, r:BYTE, a:BYTE

ENDIF