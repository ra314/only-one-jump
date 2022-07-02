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
	get_parent().get_node("Player1").connect("on_reset", self, "reset")
	init_position = position
	init_velocity = velocity
	reset()

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

func reset():
	position = init_position
	velocity = init_velocity
	
	dead = false
	$"Normal Hitbox".disabled = false
	$"Collision Check/Jump Check".disabled = false
	visible = true
	
func on_die():
	dead = true
	
	$"Normal Hitbox".disabled = true
	$"Collision Check/Jump Check".disabled = true
	visible = false

func _on_Area2D_body_entered(body):
	if dead:
		return
	
	if body.name != "Player1":
		return
	
	var player = body as Player
	
	var is_player_above = body.position.y < self.position.y
	if is_player_above and !player.is_on_floor():
		player.jump(true)
		
		on_die()
