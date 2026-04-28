; unordered_vector.inc
IFNDEF UNORDERED_VECTOR_INC
UNORDERED_VECTOR_INC EQU 1

UnorderedVector STRUCT
    pData       DWORD ?     ; pointer to array of DWORDs
    count       DWORD ?     ; number of elements currently in use
    capacity    DWORD ?     ; total allocated slots
UnorderedVector ENDS

init_unordered_vector   PROTO capacity:DWORD
new_unordered_vector    PROTO capacity:DWORD
free_unordered_vector   PROTO

push_back       PROTO element:DWORD
remove_element  PROTO element:DWORD

ENDIF