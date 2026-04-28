; // ==================================
; // game_object.asm
; // ==================================

INCLUDE default_header.inc
INCLUDE game_object.inc
INCLUDE game_object_ids.inc
INCLUDE component.inc
INCLUDE transform_component.inc
INCLUDE component_ids.inc
INCLUDE heap_functions.inc

.data
GAMEOBJECT_VTABLE GameObject_vtable <OFFSET game_object_start, OFFSET game_object_update, OFFSET game_object_exit, OFFSET free_game_object>

.code

; // ----------------------------------
; // add_component
; // ----------------------------------
add_component PROC PUBLIC USES eax ebx ecx esi edi, pGameObject: DWORD, pComponent: DWORD
    mov esi, pGameObject
    lea ecx, (GameObject PTR [esi]).components
    mov eax, pComponent
    INVOKE push_back, eax
    ret
add_component ENDP

; // ----------------------------------
; // get_first_component_which_is_a
; // ----------------------------------
get_first_component_which_is_a PROC PUBLIC USES ebx esi edi, componentType_: DWORD
    mov esi, ecx
    lea ecx, (GameObject PTR [esi]).components
    mov ebx, (UnorderedVector PTR [ecx]).count
    mov esi, (UnorderedVector PTR [ecx]).pData
    mov edi, 0
search_loop:
    cmp edi, ebx
    jge not_found
    mov eax, [esi + edi*4]
    mov edx, componentType_
    cmp (Component PTR [eax]).componentType, edx
    je found
    inc edi
    jmp search_loop
not_found:
    mov eax, 0
    ret
found:
    ret
get_first_component_which_is_a ENDP

; // ----------------------------------
; // init_game_object
; // ----------------------------------
init_game_object PROC PUBLIC USES eax ebx ecx esi edi, maxComponents: DWORD
    mov (GameObject PTR [ecx]).pVt, OFFSET GAMEOBJECT_VTABLE
    mov esi, maxComponents
    lea ecx, (GameObject PTR [ecx]).components
    INVOKE init_unordered_vector, esi
    ret
init_game_object ENDP

; // ----------------------------------
; // free_game_object
; // ----------------------------------
free_game_object PROC PUBLIC USES esi edi
    mov esi, ecx
    lea ecx, (GameObject PTR [esi]).components
    mov edi, (UnorderedVector PTR [ecx]).count
free_comp_loop:
    cmp edi, 0
    je free_comp_done
    dec edi
    mov eax, (UnorderedVector PTR [ecx]).pData
    mov eax, [eax + edi*4]
    push ecx
    mov ecx, eax
    INVOKE free_component_virtual
    pop ecx
    jmp free_comp_loop
free_comp_done:
    INVOKE free_unordered_vector
    mov ecx, esi
    INVOKE HeapFree, hHeap, 0, ecx
    ret
free_game_object ENDP

; // ----------------------------------
; // game_object_start_virtual
; // ----------------------------------
game_object_start_virtual PROC PUBLIC USES ebx
    mov ebx, (GameObject PTR [ecx]).pVt
    mov ebx, (GameObject_vtable PTR [ebx]).pStart
    call ebx
    ret
game_object_start_virtual ENDP

; // ----------------------------------
; // game_object_update_virtual
; // ----------------------------------
game_object_update_virtual PROC PUBLIC USES ebx, deltaTime: REAL4
    mov ebx, (GameObject PTR [ecx]).pVt
    mov ebx, (GameObject_vtable PTR [ebx]).pUpdate
    
    ; ---> CRITICAL FIX: Push the deltaTime parameter BEFORE calling the pointer! <---
    push deltaTime
    
    call ebx
    ret
game_object_update_virtual ENDP

; // ----------------------------------
; // game_object_free_virtual
; // ----------------------------------
game_object_free_virtual PROC PUBLIC USES ebx
    mov ebx, (GameObject PTR [ecx]).pVt
    mov ebx, (GameObject_vtable PTR [ebx]).pFree
    call ebx
    ret
game_object_free_virtual ENDP

; // ----------------------------------
; // game_object_update (Default)
; // ----------------------------------
game_object_update PROC stdcall PUBLIC, deltaTime: REAL4
    ret
game_object_update ENDP

; // ----------------------------------
; // game_object_exit (Default)
; // ----------------------------------
game_object_exit PROC stdcall PUBLIC
    ret
game_object_exit ENDP

; // ----------------------------------
; // game_object_start (Default)
; // ----------------------------------
game_object_start PROC stdcall PUBLIC
    ret
game_object_start ENDP

END