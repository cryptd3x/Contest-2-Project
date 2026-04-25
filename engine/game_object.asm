; // ==================================
; // GameObject
; // ----------------------------------
; //	GameObjects are the core elements of a scene
; // that contain gameplay logic and anything the player
; // will see.
; //	The GameObject STRUCT is intended to be 'subclassed' by 
; // overriding the virtual function table.
; //	GameObjects contain a list of components that
; // define utility behavior such as sprites to render
; // or animation states. These componenets are updated
; // by the scene_update to keep their auxillary functionality
; // separate from main game logic.
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

; // ********************************************
; // Static methods
; // ********************************************

; // ----------------------------------
; // add_component
; // Initializes memory with the contents of a GameObject
; // ----------------------------------
add_component PROC PUBLIC USES eax ebx ecx esi edi, pGameObject: DWORD, pComponent: DWORD
	mov esi, pGameObject
	lea ecx, (GameObject PTR [esi]).components
	
	mov eax, pComponent
	INVOKE push_back, eax

	ret
add_component ENDP


; // ********************************************
; // Constructor Methods
; // ********************************************

; // ----------------------------------
; // init_game_object
; // Initializes memory with the contents of a GameObject
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
init_game_object PROC PUBLIC USES esi ebx edx, maxComponents : DWORD
	local pThis: DWORD
	mov pThis, ecx
	mov (GameObject PTR [ecx]).gameObjectType, DEFAULT_GAME_OBJECT_ID
	mov (GameObject PTR [ecx]).awaitingFree, 0 ; // Set awaiting free to false (0)
	mov (GameObject PTR [ecx]).pParentScene, 0 ; // Set parent to a NULL pointer

	; // Set up vTable
	mov (GameObject PTR [ecx]).pVt, OFFSET GAMEOBJECT_VTABLE

	; // Now set up the component pointer table
	lea ecx, (GameObject PTR [ecx]).components
	INVOKE init_unordered_vector, maxComponents

	mov ecx, pThis
	mov eax, ecx ; // Return the this pointer

	ret
init_game_object ENDP

; // ----------------------------------
; // free_game_object
; // Convenient method for freeing a GameObject
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
free_game_object PROC PUBLIC USES eax esi ebx
	; // Destruct the components
	mov esi, ecx ; // Move the this pointer to esi
	lea ecx, (GameObject PTR [ecx]).components
	mov eax, (UnorderedVector PTR [ecx]).pData
	mov ebx, (UnorderedVector PTR [ecx]).count
	mov ecx, 0 ; // Loop counter (int i = 0)

	.WHILE ecx < ebx
		mov edx, [eax + ecx * 4] ; // edx = pComponents[i]
		; // pComponents[i]->free()
		push ecx
		push eax
		mov ecx, edx
		INVOKE free_component_virtual
		pop eax
		pop ecx
		inc ecx ; // i++
	.ENDW
	
	mov ecx, esi
	lea ecx, (GameObject PTR [ecx]).components
	INVOKE free_unordered_vector
	mov ecx, esi ; // Restore the THIS pointer to ecx
	INVOKE HeapFree, hHeap, 0, ecx ; // Free myself
	ret
free_game_object ENDP

; // ----------------------------------
; // new_game_object
; // Reserves heap space for the Object with parameters calls the initializer method
; // ----------------------------------
new_game_object PROC PUBLIC USES ecx, maxComponents:DWORD
	INVOKE HeapAlloc, hHeap, HEAP_GENERATE_EXCEPTIONS, SIZEOF GameObject
	mov ecx, eax ;// Move the memory address to ecx so it can function as a "this" pointer
	INVOKE init_game_object, maxComponents
	ret ;// Return with the address of the memory block in HeapAlloc
new_game_object ENDP

; // ********************************************
; // Instance methods
; // ********************************************

; // ----------------------------------
; // get_first_component_which_is_a
; // Returns a pointer to the first component of the GameObject that is
; // the type specified, or NULL if it doesn't exist.
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
get_first_component_which_is_a PROC PUBLIC USES ecx ebx edx esi, componentType: ENUM_COMPONENT_ID
	local pThis
	mov pThis, ecx
	lea ecx, (GameObject PTR [ecx]).components
	mov ebx, (UnorderedVector PTR [ecx]).count
	mov eax, (UnorderedVector PTR [ecx]).pData
	mov edx, 0 ; // int i = 0
	; // Iterate through the Components
	.WHILE edx < ebx
		; // esi = components[i]
		mov esi, [eax + edx * 4]
		mov ecx, (Component PTR [esi]).componentType
		.IF ecx == componentType
			mov eax, esi ; // return the pointer to the component
			jmp exit_get_first_component_which_is_a
		.ENDIF
		inc edx
	.ENDW
	mov eax, 0 ; // Return NULL if nothing was found
	exit_get_first_component_which_is_a:
	ret
get_first_component_which_is_a ENDP

; // ----------------------------------
; // game_object_start_virtual
; // Calls the GameObject's virtual start method
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
game_object_start_virtual PROC PUBLIC USES ebx
	mov ebx, (GameObject PTR [ecx]).pVt
	mov ebx, (GameObject_vtable PTR [ebx]).pStart
	call ebx
	ret
game_object_start_virtual ENDP

; // ----------------------------------
; // game_object_update_virtual
; // Default blank update method for a GameObject
; // Can be left blank, or overriden by the virtual function table
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
game_object_update_virtual PROC stdcall PUBLIC USES ebx, deltaTime:REAL4
	mov ebx, (GameObject PTR [ecx]).pVt
	mov ebx, (GameObject_vtable PTR [ebx]).pUpdate
	push deltaTime
	call ebx
	ret
game_object_update_virtual ENDP

; // ----------------------------------
; // game_object_update_virtual
; // Calls the GameObject's virtual update method
; //
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
game_object_free_virtual PROC PUBLIC USES ebx
	mov ebx, (GameObject PTR [ecx]).pVt
	mov ebx, (GameObject_vtable PTR [ebx]).pFree
	call ebx
	ret
game_object_free_virtual ENDP

; // ----------------------------------
; // game_object_update
; // Default blank update method for a GameObject
; // Can be left blank, or overriden by the virtual function table
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
game_object_update PROC stdcall PUBLIC, deltaTime: REAL4
	mov eax, deltaTime
	ret
game_object_update ENDP

; // ----------------------------------
; // game_object_exit
; // Default blank exit method for a GameObject
; // Can be left blank, or overriden by the virtual function table
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
game_object_exit PROC stdcall PUBLIC
	ret
game_object_exit ENDP

; // ----------------------------------
; // game_object_start
; // Default blank start method for a GameObject
; // Can be left blank, or overriden by the virtual function table
; // 
; // Register Parameters: 
; //	ecx - THIS pointer
; // ----------------------------------
game_object_start PROC stdcall PUBLIC
	ret
game_object_start ENDP

END
