extends Area2D

export(String) onready var room_type

signal change_room(value, area)

func _ready():
	add_to_group("room")

func _on_Room1_body_entered(_body):
	emit_signal("change_room", $CollisionShape2D.shape.get("extents"), self)
