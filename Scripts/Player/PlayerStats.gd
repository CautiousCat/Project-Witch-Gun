extends Node

export var shotgun_ammo_max := 2
export var magnum_ammo_max := 6
export var health_max := 4
export var dash_max := 1

onready var shotgun_ammo = shotgun_ammo_max setget set_shotgun_ammo
onready var magnum_ammo = magnum_ammo_max setget set_magnum_ammo
onready var health = health_max setget set_health
onready var dash = dash_max setget set_dash

signal no_shotgun_ammo
signal no_magnum_ammo
signal no_health
signal no_dash
signal shotgun_ammo_changed(value)
signal magnum_ammo_changed(value)
signal health_changed(value)
signal dash_changed(value)

func set_stats_full():
	self.set_health(health_max)
	self.set_magnum_ammo(magnum_ammo_max)
	self.set_shotgun_ammo(shotgun_ammo_max)

func set_shotgun_ammo(value):
	shotgun_ammo = clamp(value, 0, shotgun_ammo_max)
	emit_signal("shotgun_ammo_changed", shotgun_ammo)
	if shotgun_ammo <= 0:
		emit_signal("no_shotgun_ammo")
		
func set_magnum_ammo(value):
	magnum_ammo = clamp(value, 0, magnum_ammo_max)
	emit_signal("magnum_ammo_changed", magnum_ammo)
	if magnum_ammo <= 0:
		emit_signal("no_magnum_ammo")

func set_health(value):
	health = clamp(value, 0, health_max)
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

func set_dash(value):
	dash = clamp(value, 0, dash_max)
	emit_signal("dash_changed", dash)
	if dash <= 0:
		emit_signal("no_dash")
