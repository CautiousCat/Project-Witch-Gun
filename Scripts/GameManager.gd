extends Node

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _input(_event):
	if Input.is_action_just_pressed("ui_accept"):
		if get_tree().paused == false:
			get_tree().paused = true
			
			for obj in get_tree().get_nodes_in_group("overlay"):
				obj.visible = true
		else:
			get_tree().paused = false
			for obj in get_tree().get_nodes_in_group("overlay"):
				obj.visible = false
