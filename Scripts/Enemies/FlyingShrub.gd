extends KinematicBody2D

enum{
	NORMAL
}

var STATE = NORMAL

onready var _Timer = preload("res://Scenes/Timer.tscn")
onready var DeathParticle = preload("res://Scenes/ParticleFX/DeathParticle.tscn")

var dir = Vector2.RIGHT
var velocity = Vector2.ZERO

export var move_speed : float = 100
export var move_acceleration : float = 500
export var dir_timer : float = 2
export var flash_timer : float = 0.1
export var damage : int = 1

func _ready():
	$AnimationPlayer.play("Idle")
	$Stats.connect("no_health", self, "no_health")
	$Timer.connect("timeout", self, "_on_Timer_timeout")
	$Timer.wait_time = dir_timer
	$Timer.start()

func _physics_process(delta):
	match STATE:
		NORMAL:
			move(delta)
			pass

func move(delta):
	velocity = velocity.move_toward(Vector2(move_speed * dir.x, velocity.y), move_acceleration * delta)
	velocity = move_and_slide(velocity)

func _on_Timer_timeout():
	dir.x *= -1

func take_damage(bullet_damage):
	$Stats.HP = $Stats.HP - bullet_damage
	flash()

func flash():
	$Sprite.material.set("shader_param/flash_modifier", 1)
	var _timer = _Timer.instance()
	get_tree().current_scene.add_child(_timer)
	_timer.wait_time = flash_timer
	_timer.one_shot = true
	_timer.start()
	_timer.connect("timeout", self, "_on_flashTimer_timeout")
	
func _on_flashTimer_timeout():
	$Sprite.material.set("shader_param/flash_modifier", 0)

func no_health():
	var deathParticle = DeathParticle.instance()
	get_tree().current_scene.add_child(deathParticle)
	deathParticle.global_position = global_position
	queue_free()
