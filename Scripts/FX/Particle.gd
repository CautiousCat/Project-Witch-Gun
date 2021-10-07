extends Particles2D

export var duration : float = 1.0
export var texture_scale : float
export var time_scale : float = 1

func _ready():
	emitting = true
	$EmitterTimer.wait_time = duration
	$Timer.wait_time = duration + 0.5
	$EmitterTimer.start()
	$Timer.start()
	$AnimationPlayer.play("FadeOut")
	$Light2D.texture_scale = texture_scale

func _process(delta):
	if $Light2D.texture_scale > 0:
		$Light2D.texture_scale -= (texture_scale + 0.05) * delta * time_scale
	else:
		$Light2D.texture_scale = 0

func _on_EmitterTimer_timeout():
	emitting = false

func _on_Timer_timeout():
	queue_free()
