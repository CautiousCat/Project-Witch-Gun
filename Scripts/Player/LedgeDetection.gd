extends Node2D

onready var empty_check_left = $LeftLedgeDetection/EmptyCheckLeft
onready var wall_check_left = $LeftLedgeDetection/WallCheckLeft
onready var empty_check_right = $RightLedgeDetection/EmptyCheckRight
onready var wall_check_right = $RightLedgeDetection/WallCheckRight

var left_ledge = Vector2()
var right_ledge = Vector2()

var is_on_left_wall = false
var is_on_right_wall = false
var is_on_left_empty = false
var is_on_right_empty = false

var is_on_left_ledge = false
var is_on_right_ledge = false

func _process(_delta):
	check_for_ledge()

func _update_ledge_points():
	if is_on_left_ledge:
		left_ledge.y = $LeftLedgeDetection/DownRay.get_collision_point().y
		left_ledge.x = $LeftLedgeDetection/LeftRay.get_collision_point().x
	
	if is_on_right_ledge:
		right_ledge.y = $RightLedgeDetection/DownRay.get_collision_point().y
		right_ledge.x = $RightLedgeDetection/RightRay.get_collision_point().x

func check_for_ledge():
	is_on_left_empty = false
	is_on_left_wall = false
	is_on_right_empty = false
	is_on_right_wall = false
	
	if len(empty_check_left.get_overlapping_bodies()) <= 0:
		is_on_left_empty = true
		
	if len(wall_check_left.get_overlapping_bodies()) > 0:
		is_on_left_wall = true
		
	if len(empty_check_right.get_overlapping_bodies()) <= 0:
		is_on_right_empty = true

	if len(wall_check_right.get_overlapping_bodies()) > 0:
		is_on_right_wall = true

	
func is_on_ledge():
	is_on_left_ledge = is_on_left_wall and is_on_left_empty
	is_on_right_ledge = is_on_right_wall and is_on_right_empty
		
	return is_on_left_ledge or is_on_right_ledge

func which_ledge():
	if is_on_left_ledge:
		return "left"
	if is_on_right_ledge:
		return "right"
