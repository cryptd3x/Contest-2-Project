; renderer.asm
; Software renderer using standard assembly jumps to bypass MASM macro bugs.
INCLUDE default_header.inc
INCLUDE renderer.inc
INCLUDE engine_types.inc
INCLUDE render_command.inc
INCLUDE camera.inc
INCLUDE tetris_board.inc

; Win32 GDI prototypes
GetDC         PROTO hWnd:DWORD
ReleaseDC     PROTO hWnd:DWORD, hDC:DWORD
StretchDIBits PROTO hdc:DWORD, xDest:DWORD, yDest:DWORD, \
                    DestWidth:DWORD, DestHeight:DWORD, \
                    xSrc:DWORD, ySrc:DWORD, \
                    SrcWidth:DWORD, SrcHeight:DWORD, \
                    lpBits:DWORD, lpbmi:DWORD, \
                    iUsage:DWORD, rop:DWORD

BI_RGB          EQU 0
DIB_RGB_COLORS  EQU 0
SRCCOPY         EQU 00CC0020h

BITMAPINFOHEADER STRUCT
    biSize          DWORD ?
    biWidth         DWORD ?
    biHeight        DWORD ?
    biPlanes        WORD  ?
    biBitCount      WORD  ?
    biCompression   DWORD ?
    biSizeImage     DWORD ?
    biXPelsPerMeter DWORD ?
    biYPelsPerMeter DWORD ?
    biClrUsed       DWORD ?
    biClrImportant  DWORD ?
BITMAPINFOHEADER ENDS

.data
screenBuffer DWORD SCREEN_WIDTH * SCREEN_HEIGHT DUP(0FF000000h)
bmpInfo BITMAPINFOHEADER < \
    SIZEOF BITMAPINFOHEADER, \
    SCREEN_WIDTH, \
    -(SCREEN_HEIGHT), \
    1, \
    32, \
    BI_RGB, \
    0,0,0,0,0 >
hRenderWindow DWORD 0

.code

set_render_window PROC PUBLIC, hWnd:DWORD
    mov eax, hWnd
    mov hRenderWindow, eax
    ret
set_render_window ENDP

draw_board_border PROC PRIVATE USES eax ebx ecx edx edi
    mov edx, 0FF444444h
    mov edi, 0
    .WHILE edi < (TETRIS_BOARD_WIDTH * BLOCK_SIZE)
        mov [screenBuffer + edi*4], edx
        inc edi
    .ENDW
    mov ecx, (TETRIS_BOARD_HEIGHT * BLOCK_SIZE)
    .IF ecx < SCREEN_HEIGHT
        mov ebx, ecx
        imul ebx, SCREEN_WIDTH
        mov edi, 0
        .WHILE edi < (TETRIS_BOARD_WIDTH * BLOCK_SIZE)
            mov eax, ebx
            add eax, edi
            mov [screenBuffer + eax*4], edx
            inc edi
        .ENDW
    .ENDIF
    mov edi, 0
    .WHILE edi < (TETRIS_BOARD_HEIGHT * BLOCK_SIZE)
        mov eax, edi
        imul eax, SCREEN_WIDTH
        mov [screenBuffer + eax*4], edx
        inc edi
    .ENDW
    mov ecx, (TETRIS_BOARD_WIDTH * BLOCK_SIZE)
    .IF ecx < SCREEN_WIDTH
        mov edi, 0
        .WHILE edi < (TETRIS_BOARD_HEIGHT * BLOCK_SIZE)
            mov eax, edi
            imul eax, SCREEN_WIDTH
            add eax, ecx
            mov [screenBuffer + eax*4], edx
            inc edi
        .ENDW
    .ENDIF
    ret
draw_board_border ENDP

renderCommands PROC PUBLIC USES esi edi ebx,
        pRenderCommands : DWORD,
        numCommands     : DWORD,
        pCamera         : DWORD

    local camX : SDWORD, camY : SDWORD, i : DWORD
    local screenX : SDWORD, screenY : SDWORD, color : DWORD
    local py : DWORD, px : DWORD, rowBase : DWORD

    mov esi, pCamera
    mov eax, (Camera PTR [esi]).x
    mov camX, eax
    mov eax, (Camera PTR [esi]).y
    mov camY, eax

    mov edi, OFFSET screenBuffer
    mov ecx, SCREEN_WIDTH * SCREEN_HEIGHT
    mov eax, 0FF000000h
    rep stosd

    mov i, 0
render_loop:
    mov eax, i
    cmp eax, numCommands
    jge render_done

        ; FIX A2070: Load array base from stack into register first
        mov edx, pRenderCommands
        mov ebx, i
        mov esi, [edx + ebx*4]

        mov eax, (RenderCommand PTR [esi]).x
		mov edx, (RenderCommand PTR [esi]).ignoreCamera
		test edx, edx
		jnz x_no_camera
		sub eax, camX
		x_no_camera:
		imul eax, BLOCK_SIZE
		mov screenX, eax

		mov eax, (RenderCommand PTR [esi]).y
		mov edx, (RenderCommand PTR [esi]).ignoreCamera
		test edx, edx
		jnz y_no_camera
		sub eax, camY
		y_no_camera:
		imul eax, BLOCK_SIZE
		mov screenY, eax
        mov eax, (RenderCommand PTR [esi]).colorBGRA
        mov color, eax

        mov py, 0
    py_loop:
        cmp py, BLOCK_SIZE
        jge py_done
            mov eax, screenY
            add eax, py
            
            ; FIX A2154: Use standard jumps for signed clipping
            cmp eax, 0
            jl next_py
            cmp eax, SCREEN_HEIGHT
            jge next_py

            imul eax, SCREEN_WIDTH
            mov rowBase, eax
            mov px, 0
        px_loop:
            cmp px, BLOCK_SIZE
            jge px_done
                mov ecx, screenX
                add ecx, px
                
                ; FIX A2154: Use standard jumps for signed clipping
                cmp ecx, 0
                jl next_px
                cmp ecx, SCREEN_WIDTH
                jge next_px

                mov edx, rowBase
                add edx, ecx
                mov eax, color
                mov [screenBuffer + edx*4], eax

            next_px:
                inc px
                jmp px_loop
        px_done:
        next_py:
            inc py
            jmp py_loop
    py_done:

    inc i
    jmp render_loop
render_done:

    INVOKE draw_board_border

    ; Final check for window handle
    mov eax, hRenderWindow
    test eax, eax
    jz no_window
        INVOKE GetDC, eax
        mov esi, eax
        INVOKE StretchDIBits, esi, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, \
                0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, OFFSET screenBuffer, \
                OFFSET bmpInfo, DIB_RGB_COLORS, SRCCOPY
        INVOKE ReleaseDC, hRenderWindow, esi
    no_window:
    ret
renderCommands ENDP
END