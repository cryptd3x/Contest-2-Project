IFNDEF CAMERA_INC
CAMERA_INC EQU 1

Camera STRUCT
	; // Perhaps, some time in the future, this data could be 
	; // replaced by a TransformComponent.
	x DWORD ?
	y DWORD ?

	; // These are out of scope for the project and are unused
	h DWORD ? ; // Viewport Height
	w DWORD ? ; // Viewport Width
Camera ENDS

init_camera PROTO x: DWORD, y: DWORD
new_camera PROTO x: DWORD, y: DWORD
free_camera PROTO 

ENDIF
