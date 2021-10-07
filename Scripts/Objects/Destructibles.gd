extends Node2D

export var max_health : int = 10
export var health : int = 10

func take_damage(damage):
	health -= damage
	health = clamp(health, 0, max_health)
	if health == 0:
		destroy()
		
func destroy():
	queue_free()
