extends Area2D

export var damage : float = 1.0
export var move_speed : float = 100.0
export var move_acceleration : float = 100.0

var velocity : Vector2 = Vector2.ZERO
var direction : Vector2 = Vector2.ZERO

var player

func _ready():
	player = get_tree().get_nodes_in_group("player")[-1]

func _physics_process(delta):
	direction = global_position.direction_to(player.global_position)
	velocity = velocity.move_toward(direction * move_speed, move_acceleration * delta)
	global_position += velocity * delta
	$Node2D.look_at(player.global_position)

func _on_GreenFire_area_entered(area):
	queue_free()

func _on_DeathTimer_timeout():
	queue_free()
