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
