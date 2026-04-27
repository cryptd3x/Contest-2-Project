INCLUDE default_header.inc
INCLUDE scene.inc
INCLUDE heap_functions.inc
INCLUDE input_manager.inc
INCLUDE renderer.inc

.code
init_scene PROC PUBLIC USES esi, maxGameObjects:DWORD
	mov esi, ecx                           ; // Save Scene pointer — ecx is about to be overwritten
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
	; // BUG FIX: init_scene had no return value. The last INVOKE left eax pointing at
	; //   the renderCommands embedded field (Scene base + 52), not the Scene base.
	; //   new_scene returned that wrong pointer to every caller. esi still holds the
	; //   original Scene pointer from the "mov esi, ecx" at the top of this proc.
	mov eax, esi
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

scene_update PROC PUBLIC USES esi edi ebx, deltaTime:REAL4
    INVOKE updateInput

    ; Process start queue
    lea ecx, (Scene PTR [ecx]).startQueue
    mov ebx, (UnorderedVector PTR [ecx]).count
    .IF ebx > 0
        mov esi, (UnorderedVector PTR [ecx]).pData
        mov edi, 0
        .WHILE edi < ebx
            mov eax, [esi + edi*4]
            push eax
            INVOKE game_object_start_virtual
            pop eax
            lea ecx, (Scene PTR [ecx]).gameObjects
            INVOKE push_back, eax
            lea ecx, (Scene PTR [ecx]).startQueue   ; restore
            inc edi
        .ENDW
        ; clear start queue (simple reset for this implementation)
        mov (UnorderedVector PTR [ecx]).count, 0
    .ENDIF

    ; Update all active GameObjects
    ; Process free queue and remove destroyed objects
    ; Collect render commands from components
    ; Render the frame

    ret
scene_update ENDP

end
