extends Control


onready var title_texture = $TitleTexture
onready var bottom_texture = $BottomCloudTexture

onready var texture_1 = $TextureRect
onready var texture_2 = $TextureRect2

export var cloud_speed = 80
export var move_offset = 400
var timer = 0

func _ready():
	$AnimationPlayer.play("FadeOut")
	AudioManager.play_music(load("res://Music/HeirOfWitch_OST_001.mp3"))
#	for button in $Menu/CenterRow/Buttons.get_children():
#		button.get_children()[-1].connect("pressed", self, "_on_Button_pressed", [button.get_children()[-1].scene_to_load])
	var button = $Menu/CenterRow/Buttons/CenterContainer/NewGame
	button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])
	
func _physics_process(delta):
	var offset = move_offset * sin(timer) * delta 
	
	title_texture.margin_bottom = offset
	title_texture.margin_top = offset 
	
	bottom_texture.margin_bottom += offset * 0.025
	bottom_texture.margin_top += offset * 0.025
	
	if texture_1.margin_left <= -1391:
		texture_1.margin_left = 1168
		texture_1.margin_right = 1393
	
	if texture_2.margin_left <= -1391:
		texture_2.margin_left = 1168
		texture_2.margin_right = 1393	
	
	texture_1.margin_left -= cloud_speed * delta
	texture_1.margin_right -= cloud_speed * delta
	texture_2.margin_left -= cloud_speed * delta
	texture_2.margin_right -= cloud_speed * delta
	
	
	timer += delta
	
func _on_Button_pressed(scene_to_load):
	print("Trying to load scene")
	$AnimationPlayer.play("FadeIn")
	yield($AnimationPlayer, "animation_finished")
	get_tree().change_scene(scene_to_load)

func _on_ExitButton_pressed():
	get_tree().quit()
