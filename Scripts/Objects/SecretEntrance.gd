extends StaticBody2D

export var health = 20
var col_rect : ColorRect

func _ready():
	col_rect = get_tree().get_nodes_in_group("secret_entrance_001")[0]


func _on_SecretEntrance_area_entered(area):
	health -= area.damage
	if health <= 0:
		col_rect.visible = false
		queue_free()
