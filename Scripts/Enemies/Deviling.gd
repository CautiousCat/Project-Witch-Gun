extends KinematicBody2D

export(PackedScene) var DeathParticle

export var moveSpeedMax := 100
export var moveSpeedAccel := 2000
export var fallAccel := 600
export var fallSpeedMax := 200
export var damage : int = 1

export(String) var animToPlay

var direction := Vector2.ZERO
var velocity := Vector2.ZERO

func _ready():
	if $AnimationPlayer != null:
		$AnimationPlayer.play(animToPlay)
	direction = Vector2(1, 0)

func _physics_process(delta):
	velocity.y += fallAccel * delta
	if velocity.y > fallSpeedMax:
		velocity.y = fallSpeedMax
	if is_on_floor():
		velocity.y = 0
	velocity = velocity.move_toward(Vector2(direction.x * moveSpeedMax, velocity.y), moveSpeedAccel * delta)

	velocity = move_and_slide(velocity, Vector2.UP)

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
	$Sprite.material.set("shader_param/flash_modifier", 1)
	$FlashTimer.start()

func _on_FlashTimer_timeout():
	$Sprite.material.set("shader_param/flash_modifier", 0)

func _on_LeftEdgeDetection_body_exited(_body):
	direction *= -1
	$Sprite.flip_h = false
func _on_RightEdgeDetection_body_exited(_body):
	direction *= -1
	$Sprite.flip_h = true

func _on_LeftWallDetection_body_entered(_body):
	direction *= -1
	$Sprite.flip_h = false
func _on_RightWallDetection_body_entered(_body):
	direction *= -1
	$Sprite.flip_h = true
