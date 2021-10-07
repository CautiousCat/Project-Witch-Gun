extends KinematicBody2D

export(PackedScene) var DeathParticle
export(PackedScene) var Projectile

export var move_speed : float = 50
export var move_acceleration : float = 200
export var fall_speed : float = 50
export var damage : float = 1

var direction : Vector2 = Vector2.RIGHT
var velocity : Vector2 = Vector2.ZERO

var player

func _ready():
	player = get_tree().get_nodes_in_group("player")[-1]
	$AnimationPlayerLimbs.play("walk")
	$AnimationPlayerHeadTorso.play("idle")

func _physics_process(delta):
	if global_position.x > player.global_position.x:
		direction.x = -1
		$Limbs.flip_h = true
		$Torso.flip_h = true
		$Head.flip_h = true
	else:
		direction.x = 1
		$Limbs.flip_h = false
		$Torso.flip_h = false
		$Head.flip_h = false
		
	velocity.y += 50
	velocity.y = clamp(velocity.y, 0, 100)
	
	velocity = velocity.move_toward(Vector2(direction.x * move_speed, velocity.y), move_speed)
	velocity = move_and_slide(velocity)

func move():
	set_physics_process(true)

func stop():
	set_physics_process(false)

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
	$Limbs.material.set("shader_param/flash_modifier", 1)
	$Torso.material.set("shader_param/flash_modifier", 1)
	$Head.material.set("shader_param/flash_modifier", 1)
	$FlashTimer.start()
	
func _on_FlashTimer_timeout():
	$Limbs.material.set("shader_param/flash_modifier", 0)
	$Torso.material.set("shader_param/flash_modifier", 0)
	$Head.material.set("shader_param/flash_modifier", 0)


func _on_ProjectileTimer_timeout():
	var projectile = Projectile.instance()
	get_tree().get_nodes_in_group("world")[-1].add_child(projectile)
	projectile.global_position = $ProjectileSpawn.global_position
