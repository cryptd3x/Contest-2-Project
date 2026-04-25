; // ==================================
; // camera.asm
; // ----------------------------------
; // A camera defines where spatially a scene should
; // render its GameObjects.
; // ==================================

INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE camera.inc

.code
init_camera PROC PUBLIC USES ecx esi, x: DWORD, y: DWORD
	mov esi, x
	mov (Camera PTR [ecx]).x, esi
	mov esi, y
	mov (Camera PTR [ecx]).y, esi

	mov eax, ecx
	ret
init_camera ENDP

new_camera PROC PUBLIC USES ecx, x: DWORD, y: DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF Camera
	mov ecx, eax ; // Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_camera, x, y

	ret ; // Return with the address of the memory block in HeapAlloc
new_camera ENDP

free_camera PROC PUBLIC 
	INVOKE HeapFree, hHeap, 0, ecx
	ret
free_camera ENDP

END
