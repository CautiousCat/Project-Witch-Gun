extends Node

export var maxHP := 20
export var HP := 0 setget set_hp

signal no_health

func _ready():
	HP = maxHP

func set_hp(value):
	HP = clamp(value, 0, maxHP)
	if HP == 0:
		emit_signal("no_health")

