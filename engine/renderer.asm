INCLUDE default_header.inc
INCLUDE renderer.inc
INCLUDE engine_types.inc
INCLUDE render_command.inc
INCLUDE camera.inc
.data
screenBuffer Pixel SCREEN_WIDTH * SCREEN_HEIGHT DUP(<0,0,0,255>)

.code
renderCommands PROC PUBLIC USES esi edi ebx, pRenderCommands:DWORD, numCommands:DWORD, pCamera:DWORD
	; TODO: full implementation later. For now just clear buffer
	mov edi, OFFSET screenBuffer
	mov ecx, SCREEN_WIDTH * SCREEN_HEIGHT
	mov eax, 0FF000000h
	rep stosd
	; TODO: draw rects from commands
	ret
renderCommands ENDP

END
