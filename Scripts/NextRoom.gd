extends Area2D

export(String) var next_room
export(String) var coming_from

signal changed_room(scene_to_transition, direction)

func _ready():
	var main = get_tree().get_nodes_in_group("game")[0]
	connect("changed_room", main, "handle_changed_rooms")
	print("Connected Signal to Game Manager.")

func _on_NextRoom_body_entered(_body):
	emit_signal("changed_room", next_room, coming_from)
