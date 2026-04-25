init_scene PROC PUBLIC USES esi, maxGameObjects:DWORD
	lea ecx, (Scene PTR [ecx]).camera
	INVOKE init_camera, 0, 0
	lea ecx, (Scene PTR [esi]).gameObjects
	INVOKE init_unordered_vector, maxGameObjects
	lea ecx, (Scene PTR [esi]).startQueue
	INVOKE init_unordered_vector, maxGameObjects
	lea ecx, (Scene PTR [esi]).freeQueue
	INVOKE init_unordered_vector, maxGameObjects
	lea ecx, (Scene PTR [esi]).renderCommands
	INVOKE init_unordered_vector, maxGameObjects
	ret
init_scene ENDP

new_scene PROC PUBLIC USES ecx, maxGameObjects:DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF Scene
	mov ecx, eax
	INVOKE init_scene, maxGameObjects
	ret
new_scene ENDP
