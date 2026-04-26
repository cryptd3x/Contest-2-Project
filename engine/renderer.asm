INCLUDE default_header.inc
INCLUDE renderer.inc
INCLUDE engine_types.inc
INCLUDE render_command.inc
INCLUDE camera.inc

.data
screenBuffer Pixel SCREEN_WIDTH * SCREEN_HEIGHT DUP(<0,0,0,255>)

.code
renderCommands PROC PUBLIC USES esi edi ebx, pRenderCommands:DWORD, numCommands:DWORD, pCamera:DWORD
    ; Clear the screen buffer
    mov edi, OFFSET screenBuffer
    mov ecx, SCREEN_WIDTH * SCREEN_HEIGHT
    mov eax, 0FF000000h
    rep stosd

    ; Draw all rect commands using associated transform and color data
    ; Camera offset is applied when ignoreCamera is not set

    ret
renderCommands ENDP

END
