extends KinematicBody2D

enum {
	NORMAL,
	DASH,
	LEDGE
}

export (PackedScene) var Bullet
export (PackedScene) var TinySparkParticle
export (PackedScene) var DashParticle

var mTimer = preload("res://Scenes/Timer.tscn")
var camera
onready var main = get_tree().current_scene

export var moveSpeedMax := 150
export var moveAccel := 1000
export var dashMoveSpeed := 325
export var dashMoveAccel := 10000
export var airFriction := 1000
export var jumpHeight := 225
export var fallSpeedMax := 200
export var fallAccel := 600
export var knockbackMax := 450
export var knockbackDec := 2000
export var snapSensitivity := 30
export var shotgunBulletSpread := 12
export var magnumBulletSpread := 5
export var flashDuration := 0.1
export var hurtKnockBack := Vector2.ZERO

var direction := Vector2.ZERO
var velocity := Vector2.ZERO
var knockbackDir := Vector2.ZERO
var knockback := 0

var isShotgunReloading := false
var isMagnumReloading := false
var startPoint := Vector2.ZERO
var isOnFloor := false
var canDash := false
var dashOnCD := false
var hasFiredGun := false

var cameraShake := 50.0
var isShaking := false
var defaultCameraOffset

var State = NORMAL

func _ready():
	PlayerStats.connect("no_health", self, "_on_PlayerStats_no_health")
	startPoint = global_position
	add_to_group("player")
	camera = get_tree().get_nodes_in_group("player_camera")[-1]
	defaultCameraOffset = camera.offset

func _physics_process(delta):
	match State:
		NORMAL:
			normal_state(delta)
		DASH:
			dash(delta)
			gun_controls()
		LEDGE:
			ledge(delta)
	
	if isShaking:
		camera.offset += Vector2(rand_range(-cameraShake, cameraShake), rand_range(-cameraShake, cameraShake)) * delta + defaultCameraOffset
	
	velocity = move_and_slide(velocity)


func normal_state(delta):
	if Input.is_action_just_pressed("ui_shift") and canDash and dashOnCD == false:
		start_dash()
	
	if ($LedgeDetection.is_on_ledge() and velocity.y > 0):
		if ($LedgeDetection.is_on_left_ledge and $Sprite.flip_h == true) or ($LedgeDetection.is_on_right_ledge and $Sprite.flip_h == false):
			State = LEDGE
			ledge(delta)

	jump_and_fall(delta)
	gun_controls()
	move(delta)


func move(delta):
	if direction.x < 0:
		$Sprite.flip_h = true
	elif direction.x > 0:
		$Sprite.flip_h = false	
	
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		
	if isOnFloor:
		velocity = velocity.move_toward(Vector2(moveSpeedMax * direction.x, velocity.y), moveAccel * delta)
	else:
		if knockback > 0:
			velocity = velocity.move_toward(knockbackDir * -knockback * 1.75, 1000 * delta)
		velocity = velocity.move_toward(Vector2(moveSpeedMax * direction.x, velocity.y), airFriction * delta)
	
	knockback -= knockbackDec * delta
	if knockback < 0:
		knockback = 0


func jump_and_fall(delta):
	if isOnFloor:
		if not canDash:
			canDash = true
			PlayerStats.dash += 1
		check_reload()
	else:
		velocity.y += fallAccel * delta
		if velocity.y >= fallSpeedMax:
			velocity.y = fallSpeedMax
		elif velocity.y < -fallSpeedMax:
			velocity.y = -fallSpeedMax
	
	if (isOnFloor or State == LEDGE) and Input.get_action_strength("ui_jump"):
		velocity.y = -jumpHeight


func start_dash():
	State = DASH
	canDash = false
	PlayerStats.dash -= 1
	$DashTimer.start()
	AudioManager.play_sfx(load("res://Sounds/Player/DashSFX.ogg"))
	var dashParticle = DashParticle.instance()
	main.add_child(dashParticle)
	if $Sprite.flip_h == true:
		dashParticle.direction = 1
	else:
		dashParticle.direction = -1
	dashParticle.global_position = global_position + Vector2(0, 0)	


func dash(delta):
	if $Sprite.flip_h == true:
		direction.x = -1
	else:
		direction.x = 1
	
	velocity.y = 0
	velocity = velocity.move_toward(Vector2(dashMoveSpeed * direction.x, 0), dashMoveAccel * delta)


func ledge(delta):
	$LedgeDetection._update_ledge_points()
	
	if canDash == false:
		canDash = true
		PlayerStats.dash += 1
	
	check_reload()
	gun_controls()
	jump_and_fall(delta)
	
	if $LedgeDetection.which_ledge() == "left":
		global_position = $LedgeDetection.left_ledge
		$Sprite.flip_h = false
	else:
		global_position = $LedgeDetection.right_ledge
		$Sprite.flip_h = true
		
	velocity = Vector2.ZERO
	if Input.get_action_strength("ui_jump"):
		jump_and_fall(delta)
		move(delta)
		State = NORMAL	


func gun_controls():
	rotateGun()
	
	#Aim Snap
	if (Input.get_action_strength("ui_alt")):
		for i in range(9):
			if abs(abs($GunPivot/Gun.rotation_degrees) - (360/8)*i) < snapSensitivity:
				$GunPivot/Gun.rotation_degrees = (360/8)*i

	#Shooting
	if (PlayerStats.shotgun_ammo != 0 and Input.is_action_just_pressed("ui_right_shoot") and global_position.distance_to(get_global_mouse_position()) > 33 and not isShotgunReloading):
		shake_camera()
		shoot_gun($GunPivot/Gun, 3, 4, shotgunBulletSpread, 3.0, 0.85, "Shotgun Recoil", "Shotgun")
		
		$GunPivot/Gun/Sprite.visible = true
		$GunPivot/Gun2/Sprite.visible = false
		
		PlayerStats.shotgun_ammo -= 1
		
	if (PlayerStats.magnum_ammo != 0 and Input.is_action_just_pressed("ui_shoot") and global_position.distance_to(get_global_mouse_position()) > 33 and not isMagnumReloading):
		shake_camera()
		shoot_gun($GunPivot/Gun2, 5, 1, magnumBulletSpread, 0, 0.2, "Magnum Recoil", "Magnum")
		
		$GunPivot/Gun/Sprite.visible = false
		$GunPivot/Gun2/Sprite.visible = true
		
		PlayerStats.magnum_ammo -= 1
	
	reload_gun()

func shoot_gun(gun : Object, bulletDamage : float, bulletAmount : int, bulletSpread : float, bulletOffset : float, knockbackFactor : float, shootAnim : String, audio : String):
	var nozzle = gun.get_node("Nozzle")
	var animPlayer = gun.get_node("AnimationPlayer")
	
	if State == DASH:
		State = NORMAL
	if !isOnFloor:
		knockbackDir = Vector2(cos(gun.rotation), sin(gun.rotation))
		knockback = knockbackMax * knockbackFactor
		if audio == "Shotgun":
			velocity = Vector2.ZERO
		velocity += knockbackDir * -knockback
		
	for _x in range(bulletAmount):
		var bullet = Bullet.instance()
		
		main.add_child(bullet)
		bullet.global_position = nozzle.global_position + Vector2(rand_range(-bulletOffset, bulletOffset), rand_range(-bulletOffset, bulletOffset))
		bullet.look_at(get_global_mouse_position())
		
		var bullet_dir = Vector2(cos(gun.rotation), sin(gun.rotation))*100 + Vector2(rand_range(-bulletSpread, bulletSpread), rand_range(-bulletSpread, bulletSpread))
		bullet.get_direction(bullet_dir)
		bullet.set_damage(bulletDamage)
		
		match audio:
			"Shotgun":
				bullet.set_death_timer(0.20)
			"Magnum":
				bullet.set_death_timer(0.25)
		
	animPlayer.stop()
	animPlayer.play(shootAnim)
	
	var volume : float = 0
	match audio:
		"Shotgun":
			volume = -20
		"Magnum":
			volume = -20
	AudioManager.play_sfx(load("res://Sounds/Items/" + audio + "FireSFX.ogg"), volume)
	var tinySparkParticle = TinySparkParticle.instance()
	get_tree().get_nodes_in_group("world")[-1].add_child(tinySparkParticle)
	tinySparkParticle.global_position = nozzle.global_position	

func check_reload():
	if isShotgunReloading == false and PlayerStats.shotgun_ammo == 0:
		reloadShotgun()
	if isMagnumReloading == false and PlayerStats.magnum_ammo == 0:
		reloadMagnum()
		
	if Input.is_action_pressed("ui_restart"):
		if isShotgunReloading == false and PlayerStats.shotgun_ammo != PlayerStats.shotgun_ammo_max:
			reloadShotgun()
		if isMagnumReloading == false and PlayerStats.magnum_ammo != PlayerStats.magnum_ammo_max:
			reloadMagnum()

func reload_gun():
	if isShotgunReloading == true and PlayerStats.shotgun_ammo < PlayerStats.shotgun_ammo_max:
		$ShotgunReloadProgress.value = ($ShotgunReloadTimer.wait_time - $ShotgunReloadTimer.time_left)/$ShotgunReloadTimer.wait_time * 100
	
	if isMagnumReloading == true and PlayerStats.magnum_ammo < PlayerStats.magnum_ammo_max:
		$MagnumReloadProgress.value = ($MagnumReloadTimer.wait_time - $MagnumReloadTimer.time_left)/$MagnumReloadTimer.wait_time * 100
	

func reloadShotgun():
	AudioManager.play_sfx(load("res://Sounds/Player/ShotgunReloadSFX.ogg"))
	$ShotgunReloadProgress.visible = true
	$ShotgunReloadTimer.start()
	isShotgunReloading = true
	
	if isMagnumReloading:
		$MagnumReloadProgress.tint_progress = Color(1,1,1,0.75)
		$MagnumReloadProgress.tint_under = Color(1,1,1,0)
	else:
		$ShotgunReloadProgress.tint_progress = Color(1,1,1,1)
		$MagnumReloadProgress.tint_under = Color(1,1,1,1)
	
func reloadMagnum():
	AudioManager.play_sfx(load("res://Sounds/Player/ShotgunReloadSFX.ogg"))
	$MagnumReloadProgress.visible = true
	$MagnumReloadTimer.start()
	isMagnumReloading = true
	
	if isShotgunReloading:
		$ShotgunReloadProgress.tint_progress = Color(1,1,1,0.75)
		$MagnumReloadProgress.tint_under = Color(1,1,1,0)
	else:
		$MagnumReloadProgress.tint_progress = Color(1,1,1,1)
		$MagnumReloadProgress.tint_under = Color(1,1,1,1)

func rotateGun():
	$GunPivot/Gun.look_at(get_global_mouse_position())
	$GunPivot/Gun2.look_at(get_global_mouse_position())
	
	if abs($GunPivot/Gun.rotation_degrees) > 360:
		$GunPivot/Gun.rotation_degrees = 0
		$GunPivot/Gun2.rotation_degrees = 0
	if $GunPivot/Gun.rotation_degrees < 0:
		$GunPivot/Gun.rotation_degrees = 360
		$GunPivot/Gun2.rotation_degrees = 360
		
	if abs($GunPivot/Gun.rotation_degrees) > 90 and abs($GunPivot/Gun.rotation_degrees) < 270:
		$GunPivot/Gun/Sprite.flip_v = true
		$GunPivot/Gun2/Sprite.flip_v = true
		$GunPivot/Gun2/Nozzle.position = Vector2(28, 3)
	else:
		$GunPivot/Gun/Sprite.flip_v = false
		$GunPivot/Gun2/Sprite.flip_v = false
		$GunPivot/Gun2/Nozzle.position = Vector2(28, -1)

func reset():
	global_position = startPoint
	PlayerStats.health = PlayerStats.health_max

#Floor Detection Signal Receivers
func _on_FloorDetection_body_entered(_body):
	isOnFloor = true

func _on_FloorDetection_body_exited(_body):
	isOnFloor = false

#On enemy hitbox contact
func _on_HurtBox_area_entered(area):
	if area.global_position.x < global_position.x:
		velocity = hurtKnockBack * Vector2(1,-1)
	else:
		velocity = hurtKnockBack * Vector2(-1, -1)
		
	flash()
	AudioManager.play_sfx(load("res://Sounds/Player/FMCPainSFX.ogg"))
	PlayerStats.health = PlayerStats.health - area.damage
	State = NORMAL


#Custom instanced timer
func _on_mTimer_timeout():
	$Sprite.material.set("shader_param/flash_modifier", 0)

#Flash Animation
func flash():
	$Sprite.material.set("shader_param/flash_modifier", 1)
	var mtimer = mTimer.instance()
	mtimer.wait_time = flashDuration
	mtimer.one_shot = true
	main.add_child(mtimer)
	mtimer.connect("timeout", self, "_on_mTimer_timeout")
	mtimer.start()


#Reset game upon death
func _on_PlayerStats_no_health():
	PlayerStats.set_stats_full()
	get_tree().reload_current_scene()


#Collecting collectibles
func _on_CollectBox_area_entered(area):
	PlayerStats.shotgun_ammo += 1
	area.visible = false
	area.Timer.start()


func _on_ShotgunReloadTimer_timeout():
	isShotgunReloading = false
	PlayerStats.shotgun_ammo = PlayerStats.shotgun_ammo_max
	$ShotgunReloadProgress.visible = false
	if isMagnumReloading:
		$MagnumReloadProgress.tint_progress = Color(1,1,1,1)
		$MagnumReloadProgress.tint_under = Color(1,1,1,1)

func _on_MagnumReloadTimer_timeout():
	isMagnumReloading = false
	PlayerStats.magnum_ammo = PlayerStats.magnum_ammo_max
	$MagnumReloadProgress.visible = false
	if isShotgunReloading:
		$ShotgunReloadProgress.tint_progress = Color(1,1,1,1)
		$MagnumReloadProgress.tint_under = Color(1,1,1,1)

		
func _on_DashTimer_timeout():
	State = NORMAL
	dashOnCD = true
	$DashWaitTimer.start()


func _on_DashWaitTimer_timeout():
	dashOnCD = false

	
func _enter_room():
	global_position.x += direction.x * 10

	
func shake_camera():
	$Tween.stop_all()
	$ShakeTimer.start()
	isShaking = true

func _on_ShakeTimer_timeout():
	isShaking = false
	$Tween.interpolate_property(camera, "offset", camera.offset, defaultCameraOffset, 0.1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()
