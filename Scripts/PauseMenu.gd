extends Control


func _on_Continue_button_up():
	get_tree().paused = false
	for obj in get_tree().get_nodes_in_group("overlay"):
		obj.visible = false

func _on_MainMenu_button_up():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
	get_tree().paused = false
