IFNDEF SCENE_INC
SCENE_INC EQU 1

INCLUDE unordered_vector.inc
INCLUDE game_object_ids.inc
INCLUDE camera.inc 

Scene STRUCT
	camera Camera<>
