tool
extends Sprite

var size = 0
var thickness = 0.2
var scale_factor = 1.1
func _physics_process(delta):
	scale_factor += delta * (scale_factor * scale_factor) * 0.75
	size += 1 * scale_factor * delta;
	thickness -= 0.16 * delta
	material.set_shader_param("size", size)
	material.set_shader_param("thickness", thickness)
	
	if thickness <= 0:
		size = 0
		scale_factor = 3
		thickness = 0.2
		
	_zoom_changed()
	pass

func _zoom_changed():
	material.set_shader_param("y_zoom", get_viewport_transform().get_scale().y)
	pass

func _on_Sprite2_item_rect_changed():
	material.set_shader_param("scale", scale)
	pass
