; // ==================================
; // Scene
; // ----------------------------------
; // Scenes are classes that hold a single section of a game. A scene contains a
; // pointer to a list of GameObjects that is updated by the scene_update function.
; // The scene also updates simulations and any game logic that isn't handled directly
; // by GameObjects or their components. At the end of every update, the scene will
; // call the renderer module to render its contents.
; // ==================================

IFNDEF SCENE_INC
SCENE_INC EQU 1

INCLUDE unordered_vector.inc
INCLUDE game_object_ids.inc
INCLUDE camera.inc 

Scene STRUCT
	camera Camera<>

; // The list of GameObjects in this Scene instance.
	gameObjects UnorderedVector<>
	
	; // The start queue is a list of GameObjects created by the add_gameobject method
	startQueue UnorderedVector<>

	; // The free queue is a list of GameObjects to free at the end of the frame
	freeQueue UnorderedVector<>

	; // The list of renderCommands that is built at the end of each frame
	renderCommands UnorderedVector<>
Scene ENDS

; // Constructors
init_scene	PROTO maxGameObjects		: DWORD
new_scene	PROTO maxGameObjects		: DWORD
free_scene	PROTO

; // Instance methods
get_first_game_object_which_is_a	PROTO gameObjectType: ENUM_GAME_OBJECT_ID
instantiate_game_object				PROTO pGameObject	: DWORD
queue_free_game_object				PROTO pGameObject	: DWORD
scene_update						PROTO deltaTime		: REAL4

ENDIF
