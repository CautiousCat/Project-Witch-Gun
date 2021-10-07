extends Area2D

export(PackedScene) var TinySmokeParticle

export var damage := 2
export var speed := 1000

var wait_time = 1

var direction = Vector2.ZERO
onready var main = get_tree().current_scene

func _physics_process(delta):
	$RayCast2D.cast_to = Vector2(speed * delta + 10, 0)
	if $RayCast2D.is_colliding():
		if $RayCast2D.get_collider() is Area2D:
			if wait_time <= 0:
				var obj = $RayCast2D.get_collider()
				obj.get_parent().take_damage(damage)
			make_particle($RayCast2D.get_collision_point())
		else:
			make_particle($RayCast2D.get_collision_point())
		if wait_time <= 0:
			queue_free()
		wait_time -= 1
	else:
		global_position += Vector2(direction * speed * delta)
	
	$Trail.make_trail()
			
func get_direction(dir : Vector2):
	direction = dir.normalized()

func set_damage(value):
	damage = value
	
func set_death_timer(value):
	$DeathTimer.wait_time = value
	$DeathTimer.start()

func make_particle(collision_point : Vector2):
	var tinySmokeParticle = TinySmokeParticle.instance()
	main.add_child(tinySmokeParticle)
	tinySmokeParticle.global_position = collision_point
	global_position = collision_point
		
		
func _on_DeathTimer_timeout():
	queue_free()
