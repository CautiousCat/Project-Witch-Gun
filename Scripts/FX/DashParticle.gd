extends Particles2D

export var duration := 1.0

var direction : int

func _ready():
	emitting = true
	$EmitterTimer.wait_time = duration
	$Timer.wait_time = duration + 0.5
	$EmitterTimer.start()
	$Timer.start()

func _process(_delta):
	process_material.set("direction", Vector3(direction, 0, 5))

func _on_EmitterTimer_timeout():
	emitting = false

func _on_Timer_timeout():
	queue_free()
