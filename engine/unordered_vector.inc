IFNDEF UNORDERED_VECTOR_INC
UNORDERED_VECTOR_INC EQU 1

UnorderedVector STRUCT
	pData		DWORD ?
	count		DWORD ?
	capacity	DWORD ?
UnorderedVector ENDS

init_unordered_vector PROTO capacity : DWORD
new_unordered_vector PROTO capacity: DWORD
free_unordered_vector PROTO

push_back PROTO element: DWORD
remove_element PROTO element: DWORD

ENDIF
