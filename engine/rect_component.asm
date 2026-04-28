; rect_component.asm
; Implements the RectComponent constructors.
INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE rect_component.inc

.code

init_rect_component PROC PUBLIC USES esi ecx, width_:DWORD, height_:DWORD, b:BYTE, g:BYTE, r:BYTE, a:BYTE
INVOKE init_component
mov (Component PTR [ecx]).componentType, RECT_COMPONENT_ID
mov esi, width_
mov (RectComponent PTR [ecx]).width_, esi
mov esi, height_
mov (RectComponent PTR [ecx]).height_, esi
xor eax, eax
mov al, b
mov ah, g
shl eax, 16
mov al, r
mov ah, a
mov (RectComponent PTR [ecx]).colorBGRA, eax
ret
init_rect_component ENDP

new_rect_component PROC PUBLIC USES ecx, width_:DWORD, height_:DWORD, b:BYTE, g:BYTE, r:BYTE, a:BYTE
INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF RectComponent
mov ecx, eax
INVOKE init_rect_component, width_, height_, b, g, r, a
mov eax, ecx
ret
new_rect_component ENDP

END