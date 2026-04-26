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

.code
; // ----------------------------------
; // updateInput
; // This should be called every frame by Scene. Updates the 
; // current and previous buffers.
; // ----------------------------------
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

; // ----------------------------------
; // isKeyPressed
; // Returns 1 if a key is currently pressed and 0 if a key
; // is not currently pressed this frame.
; // ----------------------------------
isKeyPressed PROC PUBLIC USES ebx, vkCode: VK_CODE
	movzx ebx, vkCode
	mov al, curInputBuffer[ebx]
	test al, 80h ; // Test the high bit
	jz keyNotPressed

	; // Key is pressed, return 1
	mov eax, 1
	jmp exitIsKeyPressed

keyNotPressed:
	mov eax, 0

exitIsKeyPressed:
	ret
isKeyPressed ENDP

; // ----------------------------------
; // isKeyJustPressed
; // Returns 1 if a key is just pressed this frame and 0 if the key
; // was not just pressed this frame.
; // ----------------------------------
isKeyJustPressed PROC PUBLIC USES ebx, vkCode: VK_CODE
	; // BUG FIXED: was "mov al, curInputBuffer[vkCode]" / "mov bl, prevInputBuffer[vkCode]"
	; //   MASM resolves a stack-parameter name as a constant EBP-relative displacement,
	; //   so the expression evaluated to curInputBuffer + <fixed offset>, not the key index.
	; //   Fix: load the value into a register first, exactly as isKeyPressed does.
	movzx ebx, vkCode
	mov al, curInputBuffer[ebx]
	mov bl, prevInputBuffer[ebx]
	test al, 80h ; // Test the high bit
	jz keyNotJustPressed
	
	; // Test if the key was also pressed last frame
	test bl, 80h
	jnz keyNotJustPressed

	; // Key was just pressed, return 1
	mov eax, 1
	jmp exitIsKeyJustPressed
		
keyNotJustPressed:
	mov eax, 0
exitIsKeyJustPressed:
	ret
isKeyJustPressed ENDP

end
