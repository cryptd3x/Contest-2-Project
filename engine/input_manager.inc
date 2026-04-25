IFNDEF INPUT_MANAGER_INC
INPUT_MANAGER_INC EQU 1

VK_CODE typedef BYTE 

; // Win32 virtual key codes taken from learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
VK_LEFT		=	025h
VK_UP		=	026h
VK_RIGHT	=	027h
VK_DOWN		=	028h

VK_GAMEPAD_DPAD_UP		= 0CBh
VK_GAMEPAD_DPAD_DOWN	= 0CCh

VK_GAMEPAD_LEFT_THUMBSTICK_UP	= 0D3h	
VK_GAMEPAD_LEFT_THUMBSTICK_DOWN = 0D4h

updateInput PROTO
isKeyPressed PROTO vkCode: VK_CODE
isKeyJustPressed PROTO vkCode: VK_CODE
