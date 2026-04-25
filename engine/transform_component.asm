.code
init_transform_component PROC PUBLIC USES esi, x: DWORD, y: DWORD, ignoreCamera: DWORD
	INVOKE init_component
	mov (Component PTR [ecx]).componentType, TRANSFORM_COMPONENT_ID
	mov esi, x
	mov (TransformComponent PTR [ecx]).x, esi
	mov esi, y
	mov (TransformComponent PTR [ecx]).y, esi
	mov esi, ignoreCamera
	mov (TransformComponent PTR [ecx]).ignoreCamera, esi
	ret
init_transform_component ENDP

new_transform_component PROC PUBLIC USES ecx, x: DWORD, y: DWORD, ignoreCamera: DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF TransformComponent
	mov ecx, eax
	INVOKE init_transform_component, x, y, ignoreCamera
	ret
new_transform_component ENDP
