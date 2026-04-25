; // ==================================
; // input_manager.asm
; // ----------------------------------
; // The input manager is responsible for determining
; // which keys are currently pressed and providing
; // a convenient method for other files to determine
; // the currently pressed keys. This should be
; // updated on a by-frame basis by a scene.
; // ==================================

INCLUDE default_header.inc
INCLUDE input_manager.inc

; // This is a Win32 API function that was added to the program out of need, 
; // although we did not learn about it in class. The reason this function is present
; // is because it allows for a "real-time" input system where the hardware is polled
; // at the instant the frame is updated to determine what keys are currently being
; // pressed. Because the function is asynchronous, we can call it at any time and it
; // will reliably spit out the exact keys being pressed.
; // Documentation used: learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getasynckeystate
GetAsyncKeyState PROTO vk_code : DWORD
	
.data
; // Holds the data for all 256 virtual keys and whether they are currently pressed
curInputBuffer BYTE 256 DUP(0)

; // Holds the data for the previous input buffer for determining if a key was just pressed
prevInputBuffer BYTE 256 DUP(0)

updateInput PROC PUBLIC USES ebx ecx edx esi edi
	; // Copy the current buffer to the previous
	cld
    mov esi, OFFSET curInputBuffer
    mov edi, OFFSET prevInputBuffer
    mov ecx, 256
    rep movsb

	; // Get the current input state for all 256 key codes
	mov ebx, 0
	.WHILE ebx <= 0FFh
		INVOKE GetAsyncKeyState, ebx
		test ah, 80h
		jz keyUp

	keyDown:
		mov curInputBuffer[ebx], 80h ; // Set the most significant bit
		jmp endLoop
	keyUp:
		mov curInputBuffer[ebx], 0 ; // Clear the most significant bit
	endLoop:
		inc ebx
	.ENDW

	ret
updateInput ENDP
