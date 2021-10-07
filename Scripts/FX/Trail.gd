extends Line2D

var target
var point
export (NodePath) var targetPath
export var trailLength = 0

func _ready():
	target = get_node(targetPath)
		
func make_trail():
	global_position = Vector2.ZERO
	global_rotation = 0
	point = target.global_position
	add_point(point)
	while get_point_count() > trailLength:
		remove_point(0)	
