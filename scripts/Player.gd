extends CharacterBody2D

@export var gravity: float = 980
@export var speed: float = 300
@export var floor_friction: float = 0.2
@export var jump_speed: float = 500
@export var dash_speed_multiplier: float = 5
@export var max_jumps: int = 2
@export var fire_rate: float = 0.2
@export var max_health = 100
@export var can_move = true

@export var score_popup_scene: PackedScene
@export var bullet_scene: PackedScene
@export var player_death_effect_scene: PackedScene
@export var jump_effect_scene: PackedScene
@export var dash_ghost_scene: PackedScene

var current_jumps: int = 0
var can_dash = true
var is_dashing = false
var time_since_last_shoot: float = 0
var health: int

signal on_health_changed
signal on_died

# Called when the node enters the scene tree for the first time.
func _ready():
	health = max_health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if can_move:
		update_gun_position()
		update_enemy_damage()
	
		if is_on_floor():
			current_jumps = 0
		
		if Input.is_action_pressed("shoot") and time_since_last_shoot > fire_rate:
			shoot()
			time_since_last_shoot = 0
		else:
			time_since_last_shoot += delta

#Called every frame. Processes physics
func _physics_process(delta):
	if can_move:
		update_y_velocity(delta)
		update_x_velocity(delta)
		move_and_slide()

# Update x velocity of the player
func update_x_velocity(delta):
	if !is_dashing:
		if Input.is_action_pressed("move_right"):
			velocity.x = speed
		elif Input.is_action_pressed("move_left"):
			velocity.x = -speed
		else:
			if is_on_floor():
				velocity = velocity.lerp(Vector2(0, velocity.y), floor_friction)
	
	handle_dash(delta)

# Update y velocity of the player
func update_y_velocity(delta):
	if Input.is_action_just_pressed("jump"):
		if current_jumps < max_jumps:
			jump()
	else:
		# Apply gravity
		velocity.y += delta * gravity
		
func shoot():
	var bullet_instance = bullet_scene.instantiate()
	bullet_instance.position = $Gun/BulletMarker2D.global_position
	bullet_instance.rotation = (get_global_mouse_position() - bullet_instance.position).angle()
	bullet_instance.velocity = get_global_mouse_position() - bullet_instance.position
	get_parent().add_child(bullet_instance)
	
	$Gun/GunSound.play()
	
func update_gun_position():
	$Gun.look_at(get_global_mouse_position())
	
	if get_global_mouse_position() < position and !$Gun/BlasterD.flip_v:
		rotation = PI
		$Gun/BlasterD.flip_v = true
		
	if get_global_mouse_position() > position and $Gun/BlasterD.flip_v:
		$Gun/BlasterD.flip_v = false
		rotation = 0

func update_enemy_damage():
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if !enemy.is_connected("on_damage_player", Callable(self, "update_health")):
			enemy.connect("on_damage_player", Callable(self, "update_health"))
		
func update_health(value):
	if value < 0:
		$DamageSound.play()
	
	var score_popup_instance = score_popup_scene.instantiate()
	get_parent().add_child(score_popup_instance)
	score_popup_instance.start(value, position)
	
	health += value
	on_health_changed.emit(health)
	
	if health <= 0:
		die()

func jump():
	$JumpSound.play()
	current_jumps += 1
	velocity.y = -jump_speed
	
func handle_dash(delta):
	if Input.is_action_just_pressed("dash") and can_dash:
		can_dash = false
		is_dashing = true
		
		$DashGhostTimer.start()
		$DashSound.play()
		$DashCooldown.start()
		$DashDuration.start()
	
	if is_dashing:
		var max_speed = speed * dash_speed_multiplier
		velocity.x = clamp(velocity.x * dash_speed_multiplier, -max_speed, max_speed)
		

func die():
	can_move = false
	
	var player_death_effect = player_death_effect_scene.instantiate()
	player_death_effect.position = position
	get_tree().root.get_child(0).add_child(player_death_effect)
	
	$Sprite2D.hide()
	$Gun/BlasterD.hide()
	
	on_died.emit()

func _on_dash_cooldown_timeout():
	can_dash = true

func _on_dash_duration_timeout():
	is_dashing = false
	$DashGhostTimer.stop()
	
func add_ghost():
	var ghost = dash_ghost_scene.instantiate()
	ghost.texture = $Sprite2D.texture
	ghost.modulate = $Sprite2D.modulate
	ghost.position = position
	ghost.scale = scale
	get_tree().root.get_child(0).add_child(ghost)
	
func _on_dash_ghost_timer_timeout():
	add_ghost()
