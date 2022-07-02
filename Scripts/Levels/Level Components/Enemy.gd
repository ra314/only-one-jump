extends KinematicBody2D
class_name Enemy

const MAX_SPEED = 250

const FALL_MULTIPLIER = 2.5;

var velocity = Vector2(0, 0)
var dir = Vector2(1, 0)
var move_right = false
var dead = false

onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var init_position
var init_direction
var init_velocity
func _ready():
	init_position = position
	init_velocity = velocity

func _process(delta):
	if dead:
		return
		
	if is_on_wall():
		print("im on the wall")
		move_right = not move_right
		
		var sprite := $Sprite as Sprite
		sprite.scale *= Vector2(-1, 1)
		print(velocity)
	
	if move_right:
		velocity.x = MAX_SPEED
	else:
		velocity.x = -MAX_SPEED

	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)

func _physics_process(delta):
	if dead:
		return
		
	# Vertical movement code. Apply gravity.	
			
	if is_on_floor():
		velocity.y = 0
	elif velocity.y < 0:
		velocity.y += gravity * (FALL_MULTIPLIER - 1) * delta
	else:
		velocity.y += gravity * delta
	
	# Move based on the velocity and snap to the ground.
	move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	
func on_die():
	get_tree().queue_delete(self)

func _on_Area2D_body_entered(body):
	if dead:
		return
	
	if body.name != "Player1":
		return
	
	var player = body as Player
	
	var is_player_above = body.position.y < self.position.y
	if is_player_above and !player.is_on_floor():
		player.force_jump()
		
		on_die()
