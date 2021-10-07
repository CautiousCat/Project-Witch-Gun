extends KinematicBody2D

onready var raycast = $RayCast2D
export(PackedScene) var DeathParticle

export var move_speed : float = 200
export var damage : float = 1

enum {
	CRAWL,
	ROTATE
}

var direction = Vector2(1, 0)
var velocity = Vector2.ZERO
var current_rotation = 0.0
var State = CRAWL

func _physics_process(delta):
	match State:
		CRAWL:
			velocity = direction * move_speed
			if not raycast.is_colliding():
				State = ROTATE
			velocity = move_and_slide(velocity)
		ROTATE:
			rotation_degrees += 180 * delta
			if rotation_degrees > current_rotation + 90.0:
				rotation_degrees = current_rotation + 90.0
				current_rotation = rotation_degrees
				if current_rotation == 180:
					current_rotation = -current_rotation
				State = CRAWL
				
			match round(rotation_degrees):
				0.0:
					direction = Vector2(1, 0)
				90.0:
					direction = Vector2(0, 1)
				180.0:
					direction = Vector2(-1, 0)
				-90.0:
					direction = Vector2(0, -1)

func take_damage(bullet_damage):
	$Stats.HP = $Stats.HP - bullet_damage
	flash()

func _on_Stats_no_health():
	var main = get_tree().current_scene
	var deathParticle = DeathParticle.instance()
	main.add_child(deathParticle)
	deathParticle.global_position = global_position + Vector2(0, 10)
	queue_free()

func flash():
	$AnimatedSprite.material.set("shader_param/flash_modifier", 1)
	$FlashTimer.start()

func _on_FlashTimer_timeout():
	$AnimatedSprite.material.set("shader_param/flash_modifier", 0)
