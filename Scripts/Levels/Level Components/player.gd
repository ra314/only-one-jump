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

var velocity = Vector2(0, 0)
var is_jumping = false
var has_jumped = false

onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var init_position
var init_direction
var init_velocity
func _ready():
	init_position = position
	init_velocity = velocity
	reset()

func _process(delta):
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
		velocity.y = -JUMP_SPEED
		has_jumped = true
		is_jumping = true
	if Input.is_key_pressed(KEY_X):
		reset()
	# Die below a certain height
	if position.y > 2000:
		reset()
	# Applying max speed
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)

func jump(force_jump = false) -> void:
	if (!force_jump and has_jumped):
		return

	if (!force_jump):
		has_jumped = true

	velocity.y = -JUMP_SPEED
	is_jumping = true

func _physics_process(delta):
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
	move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)

signal on_reset
func reset():
	position = init_position
	velocity = init_velocity
	has_jumped = false
	
	emit_signal("on_reset")

func action():
	# Check for jumping. is_on_floor() must be called after movement code.
	if is_on_floor():
		velocity.y = -JUMP_SPEED
		is_jumping = true
