extends KinematicBody2D
class_name Player

const WALK_MAX_SPEED = 600
const WALK_ACCELERATION = 300
const AIR_ACCELERATION = 75
const JUMP_SPEED = 1200
const FRICTION = 30
const FRICTION_AIR = 20
const MAX_SPEED = 400

const FALL_MULTIPLIER = 2.5;

var velocity = Vector2(0, 0)
export(String, "Blue", "Red") var color
var is_jumping = false
var dead = false

onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var init_position
var init_direction
var init_velocity
func _ready():
	init_position = position
	init_velocity = velocity
	reset()

func die():
	dead = true
	visible = false

func _process(delta):
	if Input.is_action_pressed("move_right"):
		if is_on_floor(): 
			velocity += Vector2(WALK_ACCELERATION, 0)
		else:
			velocity += Vector2(AIR_ACCELERATION, 0)
	if Input.is_action_pressed("move_left"):
		if is_on_floor(): 
			velocity -= Vector2(WALK_ACCELERATION, 0)
		else:
			velocity -= Vector2(AIR_ACCELERATION, 0)
	
	# We use just_pressed so that the player can't hold jump infinitely to fly
	if Input.is_action_just_pressed("jump"):
		velocity.y = -JUMP_SPEED
		is_jumping = true
	# Applying max speed
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)

func _physics_process(delta):
	if dead:
		return
	
	# Vertical movement code. Apply gravity.	
	if !is_on_floor():
		if velocity.x > 0:
			if velocity.x - FRICTION < 0:
				velocity.x = 0
			else:
				velocity.x = clamp(velocity.x, 0, velocity.x - FRICTION_AIR)
		elif velocity.x < 0:
			if velocity.x - FRICTION > 0:
				velocity.x = 0
			else:
				velocity.x = clamp(velocity.x, velocity.x + FRICTION_AIR, 0)
			
	if is_on_floor() and !is_jumping:
		velocity.y = 0
		# Friction when on the floor
		if velocity.x > 0:
			if velocity.x - FRICTION < 0:
				velocity.x = 0
			else:
				velocity.x = clamp(velocity.x, 0, velocity.x - FRICTION)
		elif velocity.x < 0:
			if velocity.x - FRICTION > 0:
				velocity.x = 0
			else:
				velocity.x = clamp(velocity.x, velocity.x + FRICTION, 0)
	elif velocity.y < 0:
		is_jumping = false
		velocity.y += gravity * (FALL_MULTIPLIER - 1) * delta
	else:
		velocity.y += gravity * delta
	
	# Move based on the velocity and snap to the ground.
	move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)

func reset():
	position = init_position
	velocity = init_velocity
	dead = false
	visible = true

func action():
	# Check for jumping. is_on_floor() must be called after movement code.
	if is_on_floor():
		velocity.y = -JUMP_SPEED
		is_jumping = true
