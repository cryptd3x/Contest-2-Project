; scene.asm
INCLUDE default_header.inc
INCLUDE scene.inc
INCLUDE tetris_board.inc
INCLUDE heap_functions.inc
INCLUDE input_manager.inc
INCLUDE renderer.inc
INCLUDE game_object.inc
INCLUDE component.inc
INCLUDE transform_component.inc
INCLUDE rect_component.inc
INCLUDE component_ids.inc
INCLUDE render_command.inc
INCLUDE engine_types.inc

.data
MAX_RENDER_COMMANDS EQU 256
renderCommandPool RenderCommand MAX_RENDER_COMMANDS DUP(<0,0,0,0>)

.code

; ------------------------------------------------------------------
init_scene PROC PUBLIC USES esi, maxGameObjects:DWORD
    mov esi, ecx

    lea ecx, (Scene PTR [esi]).camera
    INVOKE init_camera, 0, 0

    lea ecx, (Scene PTR [esi]).gameObjects
    INVOKE init_unordered_vector, maxGameObjects

    lea ecx, (Scene PTR [esi]).startQueue
    INVOKE init_unordered_vector, maxGameObjects

    lea ecx, (Scene PTR [esi]).freeQueue
    INVOKE init_unordered_vector, maxGameObjects

    lea ecx, (Scene PTR [esi]).renderCommands
    INVOKE init_unordered_vector, maxGameObjects

    mov eax, esi
    ret
init_scene ENDP

; ------------------------------------------------------------------
new_scene PROC PUBLIC USES ecx, maxGameObjects:DWORD
    INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF Scene
    mov ecx, eax
    INVOKE init_scene, maxGameObjects
    ret
new_scene ENDP

; ------------------------------------------------------------------
free_scene PROC PUBLIC
    INVOKE HeapFree, hHeap, 0, ecx
    ret
free_scene ENDP

; ------------------------------------------------------------------
instantiate_game_object PROC PUBLIC USES esi, pGameObject:DWORD
    mov esi, ecx
    lea ecx, (Scene PTR [esi]).startQueue
    INVOKE push_back, pGameObject
    mov eax, pGameObject
    mov (GameObject PTR [eax]).pParentScene, esi
    ret
instantiate_game_object ENDP

; ------------------------------------------------------------------
queue_free_game_object PROC PUBLIC USES esi, pGameObject:DWORD
    mov esi, ecx
    lea ecx, (Scene PTR [esi]).freeQueue
    INVOKE push_back, pGameObject
    mov eax, pGameObject
    mov (GameObject PTR [eax]).awaitingFree, 0FFFFFFFFh
    ret
queue_free_game_object ENDP

; ------------------------------------------------------------------
get_first_game_object_which_is_a PROC PUBLIC USES ebx ecx edx esi,
        gameObjectType : ENUM_GAME_OBJECT_ID

    mov eax, (GameObject PTR [ecx]).pParentScene
    cmp eax, 0
    je not_found

    lea ecx, (Scene PTR [eax]).gameObjects
    mov edx, (UnorderedVector PTR [ecx]).count
    mov esi, (UnorderedVector PTR [ecx]).pData
    mov ebx, 0

search_loop:
    cmp ebx, edx
    jge not_found
    mov eax, [esi + ebx*4]
    mov ecx, (GameObject PTR [eax]).gameObjectType
    cmp ecx, gameObjectType
    je found
    inc ebx
    jmp search_loop

not_found:
    mov eax, 0
found:
    ret
get_first_game_object_which_is_a ENDP

; ------------------------------------------------------------------
build_render_commands_for_scene PROC PRIVATE USES esi edi ebx edx,
        pScene : DWORD

    local pCmdVec    : DWORD
    local cmdIndex   : DWORD
    local objCount   : DWORD
    local objData    : DWORD
    local i          : DWORD
    local pTrans     : DWORD
    local pRect      : DWORD
    local pBoard     : DWORD
    local row        : DWORD
    local col        : DWORD

    mov esi, pScene
    lea eax, (Scene PTR [esi]).renderCommands
    mov pCmdVec, eax
    mov (UnorderedVector PTR [eax]).count, 0
    mov cmdIndex, 0

    lea esi, (Scene PTR [esi]).gameObjects
    mov eax, (UnorderedVector PTR [esi]).count
    mov objCount, eax
    mov eax, (UnorderedVector PTR [esi]).pData
    mov objData, eax

    mov i, 0
pass1_loop:
    mov eax, i
    cmp eax, objCount
    jge pass1_done

    mov eax, i
    mov eax, [objData + eax*4]

    cmp (GameObject PTR [eax]).awaitingFree, 0
    jne pass1_next

    mov pTrans, 0
    mov pRect, 0
    lea ecx, (GameObject PTR [eax]).components
    mov edx, (UnorderedVector PTR [ecx]).count
    mov esi, (UnorderedVector PTR [ecx]).pData
    mov ebx, 0

comp_loop:
    cmp ebx, edx
    jge comp_done
    mov ecx, [esi + ebx*4]
    mov eax, (Component PTR [ecx]).componentType
    cmp eax, TRANSFORM_COMPONENT_ID
    jne check_rect
    mov pTrans, ecx
    jmp comp_next
check_rect:
    cmp eax, RECT_COMPONENT_ID
    jne comp_next
    mov pRect, ecx
comp_next:
    inc ebx
    jmp comp_loop

comp_done:
    cmp pTrans, 0
    je pass1_next
    cmp pRect, 0
    je pass1_next

    mov eax, cmdIndex
    cmp eax, MAX_RENDER_COMMANDS
    jge pass1_next

    mov eax, cmdIndex
    mov ebx, SIZEOF RenderCommand
    mul ebx
    add eax, OFFSET renderCommandPool

    mov esi, pTrans
    mov ecx, (TransformComponent PTR [esi]).x
    mov (RenderCommand PTR [eax]).x, ecx
    mov ecx, (TransformComponent PTR [esi]).y
    mov (RenderCommand PTR [eax]).y, ecx
    mov ecx, (TransformComponent PTR [esi]).ignoreCamera
    mov (RenderCommand PTR [eax]).ignoreCamera, ecx

    mov esi, pRect
    mov ecx, (RectComponent PTR [esi]).colorBGRA
    mov (RenderCommand PTR [eax]).colorBGRA, ecx

    mov ecx, pCmdVec
    INVOKE push_back, eax
    inc cmdIndex

pass1_next:
    inc i
    ; Refresh objData — push_back may have reallocated
    mov esi, pScene
    lea esi, (Scene PTR [esi]).gameObjects
    mov eax, (UnorderedVector PTR [esi]).pData
    mov objData, eax
    jmp pass1_loop

pass1_done:

    mov pBoard, 0
    mov esi, pScene
    lea esi, (Scene PTR [esi]).gameObjects
    mov edx, (UnorderedVector PTR [esi]).count
    mov esi, (UnorderedVector PTR [esi]).pData
    mov ebx, 0

board_search_loop:
    cmp ebx, edx
    jge board_search_done
    mov eax, [esi + ebx*4]
    mov ecx, (GameObject PTR [eax]).gameObjectType
    cmp ecx, TETRIS_BOARD_GAME_OBJECT_ID
    jne board_search_next
    mov pBoard, eax
    jmp board_search_done
board_search_next:
    inc ebx
    jmp board_search_loop

board_search_done:
    cmp pBoard, 0
    je pass2_done

    mov row, 0
row_loop:
    cmp row, TETRIS_BOARD_HEIGHT
    jge pass2_done

    mov col, 0
col_loop:
    cmp col, TETRIS_BOARD_WIDTH
    jge row_next

    mov eax, row
    mov ebx, TETRIS_BOARD_WIDTH
    mul ebx
    add eax, col

    mov esi, pBoard
    movzx ecx, BYTE PTR [esi + eax + TetrisBoard.grid]

    cmp ecx, 0
    je col_next

    mov eax, cmdIndex
    cmp eax, MAX_RENDER_COMMANDS
    jge col_next

    mov eax, cmdIndex
    mov ebx, SIZEOF RenderCommand
    mul ebx
    add eax, OFFSET renderCommandPool

    mov ecx, col
    mov (RenderCommand PTR [eax]).x, ecx
    mov ecx, row
    mov (RenderCommand PTR [eax]).y, ecx
    mov ecx, 0
    mov (RenderCommand PTR [eax]).ignoreCamera, ecx
    mov ecx, 0FFAAAAAh
    mov (RenderCommand PTR [eax]).colorBGRA, ecx

    mov ecx, pCmdVec
    INVOKE push_back, eax
    inc cmdIndex

col_next:
    inc col
    jmp col_loop

row_next:
    inc row
    jmp row_loop

pass2_done:
    ret
build_render_commands_for_scene ENDP

; ------------------------------------------------------------------
scene_update PROC PUBLIC USES esi edi ebx, deltaTime:REAL4
    local pScene : DWORD
    mov pScene, ecx

    INVOKE updateInput

    ; --- Start queue ---
    mov ecx, pScene
    lea ecx, (Scene PTR [ecx]).startQueue
    mov ebx, (UnorderedVector PTR [ecx]).count
    cmp ebx, 0
    je skip_start

    mov esi, (UnorderedVector PTR [ecx]).pData
    mov edi, 0
start_loop:
    cmp edi, ebx
    jge start_done

    mov ecx, [esi + edi*4]
    push esi                            
    push edi
    INVOKE game_object_start_virtual    

    mov ecx, pScene
    lea ecx, (Scene PTR [ecx]).gameObjects
    pop edi                             
    pop esi                             
    INVOKE push_back, [esi + edi*4]     

    inc edi
    jmp start_loop
start_done:
    mov ecx, pScene
    lea ecx, (Scene PTR [ecx]).startQueue
    mov (UnorderedVector PTR [ecx]).count, 0
skip_start:

    ; --- Update all active objects ---
    mov ecx, pScene
    lea ecx, (Scene PTR [ecx]).gameObjects
    mov ebx, (UnorderedVector PTR [ecx]).count
    mov esi, (UnorderedVector PTR [ecx]).pData
    mov edi, 0
update_loop:
    cmp edi, ebx
    jge update_done
    mov ecx, [esi + edi*4]
    push esi
    push edi
    push ebx
    INVOKE game_object_update_virtual, deltaTime
    pop ebx
    pop edi
    pop esi
    mov ecx, pScene
    lea ecx, (Scene PTR [ecx]).gameObjects
    mov ebx, (UnorderedVector PTR [ecx]).count
    mov esi, (UnorderedVector PTR [ecx]).pData
    inc edi
    jmp update_loop
update_done:

    INVOKE build_render_commands_for_scene, pScene

    mov ecx, pScene
    lea ecx, (Scene PTR [ecx]).renderCommands
    mov eax, (UnorderedVector PTR [ecx]).count
    mov esi, (UnorderedVector PTR [ecx]).pData
    mov ecx, pScene
    lea ecx, (Scene PTR [ecx]).camera
    INVOKE renderCommands, esi, eax, ecx

    ; --- Free queue ---
    mov ecx, pScene
    lea esi, (Scene PTR [ecx]).freeQueue
    mov ebx, (UnorderedVector PTR [esi]).count
    cmp ebx, 0
    je skip_free

    mov edi, (UnorderedVector PTR [esi]).pData
    mov ecx, 0
free_loop:
    cmp ecx, ebx
    jge free_done

    push ecx
    mov edx, [edi + ecx*4]              ; edx = pGameObject

    ; ---> CRITICAL FIX: Save edx before remove_element destroys it! <---
    push edx

    mov ecx, pScene
    lea ecx, (Scene PTR [ecx]).gameObjects
    INVOKE remove_element, edx          

    ; ---> CRITICAL FIX: Pop the object pointer safely into ecx! <---
    pop ecx                        
    INVOKE game_object_free_virtual

    pop ecx                             
    inc ecx
    jmp free_loop

free_done:
    mov (UnorderedVector PTR [esi]).count, 0
skip_free:

    ret
scene_update ENDP

end