extends Node

onready var current_scene = $Forest_001
onready var anim_player = $AnimationPlayer
var next_scene = null
var direction : String = "right"

func _ready():
	$AnimationPlayer.play("FadeOut")
	AudioManager.play_music(load("res://Music/Final Fantasy 3 - Boundless Ocean (a la FF4).mp3"), -10)

func handle_changed_rooms(scene_to_transition, coming_from):
	direction = coming_from
	anim_player.play("FadeIn")
	yield(anim_player, "animation_finished")	
	next_scene = load(scene_to_transition)
	current_scene.queue_free()
	current_scene = next_scene.instance()
	add_child(current_scene)
	next_scene = null
	anim_player.play("FadeOut")
	
