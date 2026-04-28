; renderer.inc
IFNDEF RENDERER_INC
RENDERER_INC EQU 1

renderCommands    PROTO pRenderCommands:DWORD, numCommands:DWORD, pCamera:DWORD
set_render_window PROTO hWnd:DWORD

ENDIF
