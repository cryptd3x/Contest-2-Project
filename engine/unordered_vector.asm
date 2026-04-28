; unordered_vector.asm
; =============================================
; Dynamic array (vector) implementation.
; Stores DWORD pointers and grows automatically when full.
; Used by Scene for gameObjects, startQueue, freeQueue, etc.
; =============================================

INCLUDE default_header.inc
INCLUDE heap_functions.inc
INCLUDE unordered_vector.inc

.code

; ------------------------------------------------------------------
; init_unordered_vector
; Initializes an UnorderedVector in-place.
; ecx = pointer to UnorderedVector struct
; ------------------------------------------------------------------
init_unordered_vector PROC PUBLIC USES esi, capacity:DWORD
    mov esi, ecx                    ; save THIS pointer

    ; Allocate memory for the internal array (capacity * 4 bytes)
    mov eax, capacity
    shl eax, 2
    .IF eax == 0
        mov eax, 16                 ; minimum 4 elements
    .ENDIF

    INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, eax
    mov (UnorderedVector PTR [esi]).pData, eax

    mov (UnorderedVector PTR [esi]).count, 0
    mov eax, capacity
    mov (UnorderedVector PTR [esi]).capacity, eax   ; fixed: use register instead of parameter name

    mov eax, esi                    ; return THIS pointer
    ret
init_unordered_vector ENDP

; ------------------------------------------------------------------
; new_unordered_vector
; Allocates and initializes a new UnorderedVector on the heap.
; ------------------------------------------------------------------
new_unordered_vector PROC PUBLIC USES ecx, capacity:DWORD
    INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF UnorderedVector
    mov ecx, eax
    INVOKE init_unordered_vector, capacity
    ret
new_unordered_vector ENDP

; ------------------------------------------------------------------
; free_unordered_vector
; Frees the data array (does not free the vector struct itself).
; ecx = pointer to UnorderedVector
; ------------------------------------------------------------------
free_unordered_vector PROC PUBLIC USES esi
    mov esi, ecx
    mov eax, (UnorderedVector PTR [esi]).pData
    .IF eax != 0
        INVOKE HeapFree, hHeap, 0, eax
        mov (UnorderedVector PTR [esi]).pData, 0
    .ENDIF
    ret
free_unordered_vector ENDP

; ------------------------------------------------------------------
; push_back
; Adds an element to the end. Doubles capacity when full.
; ecx = pointer to UnorderedVector
; ------------------------------------------------------------------
push_back PROC PUBLIC USES ebx edx edi, element:DWORD
    mov ebx, (UnorderedVector PTR [ecx]).count
    mov edx, (UnorderedVector PTR [ecx]).capacity

    ; Grow capacity if full
    .IF ebx == edx
        .IF edx == 0
            mov edx, 4
        .ELSE
            shl edx, 1
        .ENDIF
        mov (UnorderedVector PTR [ecx]).capacity, edx

        shl edx, 2                      ; bytes needed
        push ecx                        ; protect THIS pointer
        INVOKE HeapReAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, \
               (UnorderedVector PTR [ecx]).pData, edx
        pop ecx

        mov (UnorderedVector PTR [ecx]).pData, eax
    .ENDIF

    ; Insert element
    mov edi, (UnorderedVector PTR [ecx]).pData
    mov eax, (UnorderedVector PTR [ecx]).count
    mov edx, element
    mov [edi + eax*4], edx

    inc (UnorderedVector PTR [ecx]).count
    ret
push_back ENDP

; ------------------------------------------------------------------
; remove_element
; Removes first occurrence of element (swap-with-last method).
; Returns 0 = success, 1 = not found.
; ecx = pointer to UnorderedVector
; ------------------------------------------------------------------
remove_element PROC PUBLIC USES edi ebx edx, element:DWORD
    mov edi, ecx
    mov eax, (UnorderedVector PTR [edi]).pData
    mov ebx, (UnorderedVector PTR [edi]).count
    xor ecx, ecx                        ; i = 0

    .WHILE ecx < ebx
        mov edx, [eax + ecx*4]
        .IF edx == element
            dec (UnorderedVector PTR [edi]).count
            mov ebx, (UnorderedVector PTR [edi]).count
            mov edx, [eax + ebx*4]
            mov [eax + ecx*4], edx
            xor eax, eax                ; return 0 (success)
            ret
        .ENDIF
        inc ecx
    .ENDW

    mov eax, 1                          ; return 1 (not found)
    ret
remove_element ENDP

END