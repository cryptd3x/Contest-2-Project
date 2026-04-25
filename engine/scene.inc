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
