extends CharacterBody2D

@export var gravity: float = 980
@export var speed: float = 300
@export var floor_friction: float = 0.2
@export var jump_speed: float = 500
@export var max_jumps: int = 2
@export var fire_rate: float = 0.2
@export var max_health = 100

var current_jumps: int = 0
var is_gun_flipped = false
var time_since_last_shoot: float = 0
var health: int

const bulletPath = preload('res://scenes/Bullet.tscn')

signal on_health_changed
signal on_died

# Called when the node enters the scene tree for the first time.
func _ready():
	health = max_health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_gun_postion()
	
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
	update_y_velocity(delta)
	update_x_velocity(delta)
	move_and_slide()

# Update x velocity of the player
func update_x_velocity(delta):
	if Input.is_action_pressed("move_right"):
		velocity.x = speed
	elif Input.is_action_pressed("move_left"):
		velocity.x = -speed
	else:
		if (is_on_floor()):
			velocity = velocity.lerp(Vector2(0, velocity.y), floor_friction)

# Update y velocity of the player
func update_y_velocity(delta):
	if Input.is_action_just_pressed("jump"):
		if current_jumps < max_jumps:
			$JumpSound.play()
			current_jumps += 1
			velocity.y = -jump_speed
	else:
		# Apply gravity
		velocity.y += delta * gravity
		
func shoot():
	var bullet = bulletPath.instantiate()
	get_parent().add_child(bullet)
	bullet.position = $Gun/BulletMarker2D.global_position
	bullet.rotation = (get_global_mouse_position() - bullet.position).angle()
	bullet.velocity = get_global_mouse_position() - bullet.position
	
	$Gun/GunSound.play()
	
func update_gun_postion():
	$Gun.look_at(get_global_mouse_position())
	
	if get_global_mouse_position() < position and !is_gun_flipped:
		rotation = PI
		$Gun/BlasterD.flip_v = true
		is_gun_flipped = true
		
	if get_global_mouse_position() > position and is_gun_flipped:
		$Gun/BlasterD.flip_v = false
		rotation = 0
		is_gun_flipped = false

func update_enemy_damage():
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		enemy.connect("on_damage_player", Callable(self, "update_health"))
		
func update_health(value):
	if value < 0:
		$DamageSound.play()
	
	health += value
	on_health_changed.emit(health)
	
	if health <= 0:
		die()

func die():
	on_died.emit()
