extends Area2D


export(PoolStringArray) onready var text_to_display

onready var text = $CanvasLayer/MarginContainer/ColorRect/RichTextLabel
onready var bg = $CanvasLayer/MarginContainer/ColorRect

var line : int = 0

func _ready():
	text.text = text_to_display[0]
	set_visible(false)

func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_e"):
		line += 1
	if line > len(text_to_display) - 1:
		set_visible(false)
		set_physics_process(false)
	else:
		text.text = text_to_display[line] 

func set_visible(is_visible : bool):
	if is_visible:
		text.visible = true
		bg.visible = true
		return
	
	text.visible = false
	bg.visible = false

func _on_SignBoard_body_entered(_body):
	set_visible(true)
	set_physics_process(true)
	line = 0
	$Sprite.frame = 1

func _on_SignBoard_body_exited(_body):
	set_visible(false)
	set_physics_process(false)
	$Sprite.frame = 0
