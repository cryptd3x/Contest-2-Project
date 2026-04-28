; main.asm
; Win32 entry point for the Tetris clone.
;
; Responsibilities:
;   1. Initialise the process heap.
;   2. Register and create a window sized to the screen buffer.
;   3. Create the Scene, TetrisBoard, and TetrisManager.
;   4. Run the game loop: pump Win32 messages, then call scene_update.
;   5. Clean up on WM_DESTROY.

INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE scene.inc
INCLUDE tetris_board.inc
INCLUDE tetris_manager.inc
INCLUDE game_object.inc
INCLUDE engine_types.inc

; Win32 window prototypes
GetModuleHandleA    PROTO   lpModuleName:DWORD
LoadCursorA         PROTO   hInstance:DWORD, lpCursorName:DWORD
RegisterClassExA    PROTO   lpwcx:DWORD
CreateWindowExA     PROTO   dwExStyle:DWORD, lpClassName:DWORD, \
                            lpWindowName:DWORD, dwStyle:DWORD, \
                            X:DWORD, Y:DWORD, nWidth:DWORD, nHeight:DWORD, \
                            hWndParent:DWORD, hMenu:DWORD, hInstance:DWORD, \
                            lpParam:DWORD
ShowWindow          PROTO   hWnd:DWORD, nCmdShow:DWORD
UpdateWindow        PROTO   hWnd:DWORD
PeekMessageA        PROTO   lpMsg:DWORD, hWnd:DWORD, wMsgFilterMin:DWORD, \
                            wMsgFilterMax:DWORD, wRemoveMsg:DWORD
TranslateMessage    PROTO   lpMsg:DWORD
DispatchMessageA    PROTO   lpMsg:DWORD
PostQuitMessage     PROTO   nExitCode:DWORD
DefWindowProcA      PROTO   hWnd:DWORD, Msg:DWORD, wParam:DWORD, lParam:DWORD
GetTickCount        PROTO
ExitProcess         PROTO   uExitCode:DWORD
AdjustWindowRect    PROTO   lpRect:DWORD, dwStyle:DWORD, bMenu:DWORD

; Renderer prototype
set_render_window   PROTO   hWnd:DWORD

; Win32 constants
WS_OVERLAPPEDWINDOW EQU 0CF0000h
WS_VISIBLE          EQU 10000000h
SW_SHOW             EQU 5
PM_REMOVE           EQU 1
IDC_ARROW           EQU 32512
WM_DESTROY          EQU 2
WM_QUIT             EQU 12h
CS_HREDRAW          EQU 2
CS_VREDRAW          EQU 1

; RECT struct
RECT_ STRUCT
    left_   DWORD ?
    top_    DWORD ?
    right_  DWORD ?
    bottom_ DWORD ?
RECT_ ENDS

; MSG struct
MSG_ STRUCT
    hwnd_       DWORD ?
    message_    DWORD ?
    wParam_     DWORD ?
    lParam_     DWORD ?
    time_       DWORD ?
    pt_x        DWORD ?
    pt_y        DWORD ?
MSG_ ENDS

; WNDCLASSEXA struct
WNDCLASSEXA STRUCT
    cbSize          DWORD ?
    style_          DWORD ?
    lpfnWndProc     DWORD ?
    cbClsExtra      DWORD ?
    cbWndExtra      DWORD ?
    hInstance_      DWORD ?
    hIcon           DWORD ?
    hCursor_        DWORD ?
    hbrBackground   DWORD ?
    lpszMenuName    DWORD ?
    lpszClassName   DWORD ?
    hIconSm         DWORD ?
WNDCLASSEXA ENDS

WINDOW_STYLE EQU (WS_OVERLAPPEDWINDOW AND (NOT 40000h))

FRAME_MS EQU 16

.data
szClassName     BYTE "TetrisWindow", 0
szWindowTitle   BYTE "Tetris", 0
hMainWindow     DWORD 0
pMainScene      DWORD 0
lastTick        DWORD 0
wndClass        WNDCLASSEXA <>
msg             MSG_ <>
windowRect      RECT_ <>

; Delta time variables
divisor1000     DWORD 1000
deltaSeconds    REAL4 0.0          ; <-- Variable to store FPU popped result

.code

; ------------------------------------------------------------------
; WndProc
; ------------------------------------------------------------------
WndProc PROC USES ebx esi edi, hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    .IF uMsg == WM_DESTROY
        INVOKE PostQuitMessage, 0
        xor eax, eax
        ret
    .ENDIF
    INVOKE DefWindowProcA, hWnd, uMsg, wParam, lParam
    ret
WndProc ENDP

; ------------------------------------------------------------------
; main
; ------------------------------------------------------------------
main PROC PUBLIC
    ; ---- Heap -------------------------------------------------------
    INVOKE initialize_heap

    ; ---- Register window class -------------------------------------
    INVOKE GetModuleHandleA, 0
    mov ebx, eax                        ; ebx = hInstance

    mov wndClass.cbSize,       SIZEOF WNDCLASSEXA
    mov wndClass.style_,       CS_HREDRAW OR CS_VREDRAW
    mov wndClass.lpfnWndProc,  OFFSET WndProc
    mov wndClass.cbClsExtra,   0
    mov wndClass.cbWndExtra,   0
    mov wndClass.hInstance_,   ebx
    mov wndClass.hIcon,        0
    mov wndClass.hbrBackground,1
    mov wndClass.lpszMenuName, 0
    mov wndClass.lpszClassName,OFFSET szClassName
    mov wndClass.hIconSm,      0

    INVOKE LoadCursorA, 0, IDC_ARROW
    mov wndClass.hCursor_, eax

    INVOKE RegisterClassExA, ADDR wndClass

    ; ---- Compute window size ---------------------------------------
    mov windowRect.left_,   0
    mov windowRect.top_,    0
    mov windowRect.right_,  SCREEN_WIDTH
    mov windowRect.bottom_, SCREEN_HEIGHT
    INVOKE AdjustWindowRect, ADDR windowRect, WINDOW_STYLE, 0

    mov eax, windowRect.right_
    sub eax, windowRect.left_
    mov esi, eax                        ; esi = adjusted width

    mov eax, windowRect.bottom_
    sub eax, windowRect.top_
    mov edi, eax                        ; edi = adjusted height

    ; ---- Create window ----------------------------------------------
    INVOKE CreateWindowExA, \
        0, \
        OFFSET szClassName, \
        OFFSET szWindowTitle, \
        WINDOW_STYLE OR WS_VISIBLE, \
        100, 100, \
        esi, edi, \
        0, 0, \
        ebx, \
        0

    .IF eax == 0
        INVOKE ExitProcess, 1
    .ENDIF

    mov hMainWindow, eax
    INVOKE ShowWindow, eax, SW_SHOW
    INVOKE UpdateWindow, hMainWindow

    ; Give the renderer the window handle
    INVOKE set_render_window, hMainWindow

    ; ---- Build the scene -------------------------------------------
    INVOKE new_scene, 64
    mov pMainScene, eax

    ; Instantiate TetrisBoard
    INVOKE new_tetris_board
    mov ebx, eax
    mov ecx, pMainScene
    INVOKE instantiate_game_object, ebx

    ; Instantiate TetrisManager
    INVOKE new_tetris_manager
    mov ebx, eax
    mov ecx, pMainScene
    INVOKE instantiate_game_object, ebx

    ; Seed lastTick
    INVOKE GetTickCount
    mov lastTick, eax

    ; ---- Game loop --------------------------------------------------
gameLoop:
pumpMessages:
    INVOKE PeekMessageA, ADDR msg, 0, 0, 0, PM_REMOVE
    .IF eax
        .IF msg.message_ == WM_QUIT
            jmp exitGame
        .ENDIF
        INVOKE TranslateMessage, ADDR msg
        INVOKE DispatchMessageA, ADDR msg
        jmp pumpMessages
    .ENDIF

    ; ---- Delta time calculation -------------------------------------
    INVOKE GetTickCount
    mov ecx, eax
    sub ecx, lastTick
    mov lastTick, eax

    .IF ecx > 100
        mov ecx, 100
    .ENDIF

    ; Move ecx to stack memory so the FPU can read it
    push ecx
    fild DWORD PTR [esp]
    add esp, 4         ; clean up the stack

    fidiv divisor1000
    
    ; Clear the FPU stack
    fstp deltaSeconds

    ; Update the scene
    mov ecx, pMainScene
    ; ---> THE FIX: Cast the FLOAT as a DWORD so MASM INVOKE doesn't crash <---
    INVOKE scene_update, DWORD PTR [deltaSeconds]

    jmp gameLoop

exitGame:
    INVOKE ExitProcess, 0
main ENDP

END main