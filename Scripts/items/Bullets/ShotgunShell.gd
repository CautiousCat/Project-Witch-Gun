extends Area2D

onready var Timer := $Timer

var speed := 100

signal collected(value)

func _ready():
	add_to_group("shotgun_shell")
	$AnimationPlayer.play("ShotgunShell")

func _on_Timer_timeout():
	visible = true

func _on_ShotgunShell_area_entered(_area):
	$AudioStreamPlayer2D.stop()
	$AudioStreamPlayer2D.play()
	emit_signal("collected", global_position)
	queue_free()
