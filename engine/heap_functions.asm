INCLUDE default_header.inc
INCLUDE heap_functions.inc

.data
hHeap HANDLE ?

.code
initialize_heap PROC
	INVOKE GetProcessHeap
	mov hHeap, eax
	ret
initialize_heap ENDP

END
