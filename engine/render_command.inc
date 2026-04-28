; render_command.inc
; A RenderCommand describes one rectangular draw call.
; scene_update pushes one RenderCommand per visible block into
; Scene.renderCommands, then passes the list to renderCommands PROC.
IFNDEF RENDER_COMMAND_INC
RENDER_COMMAND_INC EQU 1

INCLUDE engine_types.inc

; Each entry in the render-command list is a pointer to a RenderCommand.
RenderCommand STRUCT
    x           SDWORD ?    ; world-space column  (board cells, not pixels)
    y           SDWORD ?    ; world-space row
    colorBGRA   DWORD  ?    ; packed BGRA colour (matches Pixel layout)
    ignoreCamera DWORD ?    ; non-zero => camera offset is NOT applied
RenderCommand ENDS

ENDIF
