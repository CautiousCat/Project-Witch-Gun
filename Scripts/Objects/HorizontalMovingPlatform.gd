extends KinematicBody2D

export var speed := 50

var dir = 1
var collided_objects := []

func _physics_process(delta):
	var displacement = dir * speed * delta
	global_position.x += displacement
	for obj in collided_objects:
		obj.position.x += displacement

func _on_Area2D_body_entered(body):
	collided_objects.append(body)

func _on_Area2D_body_exited(body):
	collided_objects.erase(body)

func _on_Timer_timeout():
	dir *= -1
