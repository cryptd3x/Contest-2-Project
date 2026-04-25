INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE unordered_vector.inc

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

free_unordered_vector PROC PUBLIC USES esi
	mov esi, (UnorderedVector PTR [ecx]).pData
	INVOKE HeapFree, hHeap, 0, esi
	ret
free_unordered_vector ENDP

push_back PROC PUBLIC USES eax ebx edx edi, element: DWORD
	mov ebx, (UnorderedVector PTR [ecx]).count
	mov edx, (UnorderedVector PTR [ecx]).capacity

	.IF ebx == edx
		.IF edx == 0
			mov edx, 1
		.ENDIF
		shl edx, 1
		mov (UnorderedVector PTR [ecx]).capacity, edx
		shl edx, 2
		INVOKE HeapReAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, (UnorderedVector PTR [ecx]).pData, edx
		mov (UnorderedVector PTR [ecx]).pData, eax
	.ENDIF

	mov edi, (UnorderedVector PTR [ecx]).pData
	mov eax, (UnorderedVector PTR [ecx]).count
	mov [edi + eax*4], element
	inc (UnorderedVector PTR [ecx]).count
	ret
push_back ENDP

remove_element PROC PUBLIC USES edi ebx ecx edx, element: DWORD
	mov edi, ecx
	mov eax, (UnorderedVector PTR [edi]).pData
	mov ebx, (UnorderedVector PTR [edi]).count
	mov ecx, 0
	.WHILE ecx < ebx
		mov edx, [eax + ecx*4]
		.IF edx == element
			dec (UnorderedVector PTR [edi]).count
			mov ebx, (UnorderedVector PTR [edi]).count
			mov edx, [eax + ebx*4]
			mov [eax + ecx*4], edx
			mov eax, 0
			ret
		.ENDIF
		inc ecx
	.ENDW
	mov eax, 1
	ret
remove_element ENDP

end
