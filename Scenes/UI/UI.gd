extends Control

var shotgun_ammo_count : int = 2 setget set_shotgun_ammo_count
var shotgun_ammo_count_max : int = 2 setget set_shotgun_ammo_count_max

var magnum_ammo_count : int = 6 setget set_magnum_ammo_count
var magnum_ammo_count_max : int = 6 setget set_magnum_ammo_count_max

var health : float = 2 setget set_health
var health_max : float = 2 setget set_health_max

var dash : int = 1 setget set_dash
var dash_max : int = 1 setget set_dash_max

func _ready():
	self.shotgun_ammo_count_max = PlayerStats.shotgun_ammo_max
	self.shotgun_ammo_count = PlayerStats.shotgun_ammo
	self.magnum_ammo_count_max = PlayerStats.magnum_ammo_max
	self.magnum_ammo_count = PlayerStats.magnum_ammo
	self.health_max = PlayerStats.health_max
	self.health = PlayerStats.health
	self.dash_max = PlayerStats.dash_max
	self.dash = PlayerStats.dash
	PlayerStats.connect("shotgun_ammo_changed", self, "set_shotgun_ammo_count")
	PlayerStats.connect("magnum_ammo_changed", self, "set_magnum_ammo_count")
	PlayerStats.connect("health_changed", self, "set_health")
	PlayerStats.connect("dash_changed", self, "set_dash")
	
func set_shotgun_ammo_count(value):
	shotgun_ammo_count = clamp(value, 0.0, shotgun_ammo_count_max)
	if (shotgun_ammo_count != null):
		$ShotgunAmmoCounter.text = "Shotgun Ammo: " + str(shotgun_ammo_count)
		$ShotgunAmmoCounterTexture.rect_size.x = 32 * shotgun_ammo_count
		
func set_shotgun_ammo_count_max(value):
	shotgun_ammo_count_max = max(value, 1)

func set_magnum_ammo_count(value):
	magnum_ammo_count = clamp(value, 0, magnum_ammo_count_max)
	if (magnum_ammo_count != null):
		$MagnumAmmoCounter.text = "Magnum Ammo: " + str(magnum_ammo_count)
		$MagnumAmmoCounterTexture.rect_size.y = 12 * magnum_ammo_count

func set_magnum_ammo_count_max(value):
	magnum_ammo_count_max = max(value, 1)

func set_health(value):
	health = clamp(value, 0, health_max)
	if (health != null):
		$HealthCounter.text = "Health: " + str(health)
		$HealthCounterTexture.value = (health/health_max) * 100
		
func set_health_max(value):
	health_max = max(value, 1)
	
func set_dash(value):
	dash = clamp(value, 0, dash_max)
	if (dash != null):
		$DashCounter.text = "Dash: " + str(dash)
		$DashCounterTexture.value = (dash/dash_max) * 100
		
func set_dash_max(value):
	dash_max = max(value, 1)
