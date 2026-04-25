.code
init_unordered_vector PROC PUBLIC USES esi, capacity : DWORD
	mov eax, capacity
	shl eax, 2
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, eax
	mov (UnorderedVector PTR [ecx]).pData, eax
	mov (UnorderedVector PTR [ecx]).count, 0
	mov (UnorderedVector PTR [ecx]).capacity, capacity
	mov eax, ecx
	ret
init_unordered_vector ENDP

new_unordered_vector PROC PUBLIC USES ecx, capacity: DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF UnorderedVector
	mov ecx, eax
	INVOKE init_unordered_vector, capacity
	ret
new_unordered_vector ENDP
