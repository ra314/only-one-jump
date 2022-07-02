extends KinematicBody2D
class_name Player

# This is roughly 3.25 blocks high
const JUMP_SPEED = 1200
const MAX_SPEED = 400

const ACCELERATION_GROUND = 300
const ACCELERATION_AIR = 75
const FRICTION_GROUND = 30
const FRICTION_AIR = 20

const FALL_MULTIPLIER = 2.5;

export (Vector2) var velocity = Vector2(0, 0)
export (bool) var is_jumping = false
var has_jumped = false
var is_level_over = false

export (bool) var touching_floor = false
export (bool) var touching_wall = false


onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

export (float) var time_scale = 1
func _ready():
	Engine.time_scale = time_scale

func _process(delta):
	if is_level_over:
		return
		
	touching_floor = is_on_floor()
	touching_wall = is_on_wall()
	
	if Input.is_action_pressed("move_right"):
		if is_on_floor(): 
			velocity += Vector2(ACCELERATION_GROUND, 0)
		else:
			velocity += Vector2(ACCELERATION_AIR, 0)
	if Input.is_action_pressed("move_left"):
		if is_on_floor(): 
			velocity -= Vector2(ACCELERATION_GROUND, 0)
		else:
			velocity -= Vector2(ACCELERATION_AIR, 0)
	
	# We use just_pressed so that the player can't hold jump infinitely to fly
	if Input.is_action_just_pressed("jump") and not has_jumped:
		has_jumped = true
		jump()
		
	if Input.is_key_pressed(KEY_X):
		reset()
	# Die below a certain height
	if position.y > 2000:
		reset()
	# Applying max speed
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)

func jump() -> void:
	velocity.y = -JUMP_SPEED
	is_jumping = true

export (int, 0, 200) var push = 25
export (int, 0, 200) var push_factor = 0.2

func _physics_process(delta):
	if is_level_over:
		return
	
	# Vertical movement code. Apply gravity.	
	if !is_on_floor():
		# FRICTION_AIR when on the floor
		velocity.x = sign(velocity.x) * max(0, abs(velocity.x) - FRICTION_AIR)
	
	if is_on_floor() and !is_jumping:
		velocity.y = 0
		# FRICTION_GROUND when on the floor
		velocity.x = sign(velocity.x) * max(0, abs(velocity.x) - FRICTION_GROUND)
	elif velocity.y < 0:
		is_jumping = false
		velocity.y += gravity * (FALL_MULTIPLIER - 1) * delta
	else:
		velocity.y += gravity * delta
	
	# Move based on the velocity and snap to the ground.
	# move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP,
					false, 4, PI/4, false)

	# after calling move_and_slide()
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("bodies"):
			if is_on_floor():
				collision.collider.apply_central_impulse(-collision.normal * push)
			else:
				collision.collider.apply_central_impulse(-collision.normal * velocity.length() * push_factor)

func reset() -> void:
	reload_current_level()

func get_curr_level_num() -> int:
	return int(get_parent().name.replace("Level", ""))

func get_main() -> Main:
	var children = get_tree().get_root().get_children()
	for child in children:
		if "Main" in child.name:
			return child
	# assert(false)
	return null

func reload_current_level() -> void:
	if get_main() == null:
		get_tree().reload_current_scene()
	else:
		get_main().load_level(get_curr_level_num())

func go_to_next_level() -> void:
	get_main().load_level(get_curr_level_num()+1)
	$Camera2D.current = true
