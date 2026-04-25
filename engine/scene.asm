INCLUDE default_header.inc
INCLUDE scene.inc
INCLUDE heap_functions.inc
INCLUDE input_manager.inc
INCLUDE renderer.inc

.code
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

free_scene PROC PUBLIC
	INVOKE HeapFree, hHeap, 0, ecx
	ret
free_scene ENDP

instantiate_game_object PROC PUBLIC USES esi, pGameObject:DWORD
	mov esi, ecx
	lea ecx, (Scene PTR [ecx]).startQueue
	INVOKE push_back, pGameObject
	mov (GameObject PTR [pGameObject]).pParentScene, esi
	ret
instantiate_game_object ENDP

queue_free_game_object PROC PUBLIC USES esi, pGameObject:DWORD
	mov esi, ecx
	lea ecx, (Scene PTR [ecx]).freeQueue
	INVOKE push_back, pGameObject
	mov (GameObject PTR [pGameObject]).awaitingFree, 0FFFFFFFFh
	ret
queue_free_game_object ENDP

scene_update PROC PUBLIC USES ecx, deltaTime:REAL4
	INVOKE updateInput
	; TODO: process start queue, update objects, free queue, render (add later)
	ret
scene_update ENDP

end
