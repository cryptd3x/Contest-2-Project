; renderable_component.asm
INCLUDE default_header.inc
INCLUDE renderable_component.inc

.code
init_renderable_component PROC PUBLIC USES esi, visible: DWORD, layer: DWORD
	INVOKE init_component
	mov (Component PTR [ecx]).componentType, RENDERABLE_COMPONENT_ID
	mov esi, visible
	mov (RenderableComponent PTR [ecx]).visible, esi
	mov esi, layer
	mov (RenderableComponent PTR [ecx]).layer, esi
	ret
init_renderable_component ENDP

END
