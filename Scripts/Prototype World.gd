extends Node2D

var MyTimer = preload("res://Scenes/Timer.tscn")
var ShotgunShell = preload("res://Scenes/Items/ShotgunShell.tscn") 

var shotgun_shells := []
var shotgun_shell_coordinates : PoolVector2Array
export var shotgun_shell_wait_time = 5

var rooms := []
var player

func _ready():
	player = get_tree().get_nodes_in_group("player")[-1]
	var game = get_tree().get_nodes_in_group("game")[0]
	var entrance = null
	match game.direction:
		"left":
			entrance = get_tree().get_nodes_in_group("right_entrance")[-1]
			player.direction = Vector2(-1, 0)
		"right":
			entrance = get_tree().get_nodes_in_group("left_entrance")[-1]
			player.direction = Vector2(1, 0)
		"up":
			pass
		"down":
			pass
	player.global_position = entrance.global_position
	
	shotgun_shells = get_tree().get_nodes_in_group("shotgun_shell")
	for obj in shotgun_shells:
		obj.connect("collected", self, "just_collected")
	
	rooms = get_tree().get_nodes_in_group("room")
	for obj in rooms:
		obj.connect("change_room", self, "changed_room")

func just_collected(value):
	shotgun_shell_coordinates.append(value)
	var main = get_tree().current_scene
	var timer = MyTimer.instance()
	main.add_child(timer)
	timer.wait_time = shotgun_shell_wait_time
	timer.one_shot = true
	timer.connect("timeout", self, "respawn_collectible")
	timer.start()
	
	AudioManager.play_sfx(load("res://Sounds/Items/PickUpItemSFX.ogg"))

func respawn_collectible():
	var coordinates = shotgun_shell_coordinates[0]
	shotgun_shell_coordinates.remove(0)
	var main = get_tree().current_scene
	var shotgunShell = ShotgunShell.instance()
	main.add_child(shotgunShell)
	shotgunShell.global_position = coordinates
	shotgunShell.connect("collected", self, "just_collected")

func changed_room(value, area):
	var bottom_offset = area.position.y + value.y
	var top_offset = area.position.y - value.y
	var left_offset = area.position.x - value.x
	var right_offset = area.position.x + value.x
	
	$Player/Camera2D.limit_bottom = bottom_offset
	$Player/Camera2D.limit_top = top_offset
	$Player/Camera2D.limit_left = left_offset
	$Player/Camera2D.limit_right = right_offset
	


