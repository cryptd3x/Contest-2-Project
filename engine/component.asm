INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE component.inc

.data
COMPONENT_VTABLE Component_vtable <OFFSET free_component>

.code
init_component PROC PUBLIC USES esi
	mov (Component PTR [ecx]).componentType, DEFAULT_COMPONENT_ID
	mov (Component PTR [ecx]).pVt, OFFSET COMPONENT_VTABLE
	ret
init_component ENDP

free_component PROC PUBLIC
	INVOKE HeapFree, hHeap, 0, ecx
	ret
free_component ENDP

free_component_virtual PROC PUBLIC USES ebx
	mov ebx, (Component PTR [ecx]).pVt
	mov ebx, (Component_vtable PTR [ebx]).pFree
	call ebx
	ret
free_component_virtual ENDP

END
