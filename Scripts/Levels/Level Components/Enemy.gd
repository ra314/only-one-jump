extends KinematicBody2D
class_name Enemy

const MAX_SPEED = 250

const FALL_MULTIPLIER = 2.5;

export (bool) var move_right = false
var dead = false

export (Vector2) var velocity = Vector2(0, 0)
onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

export (Vector2) var last_pos = Vector2(0, 0)
export (int) var slide_count = 0
export (String) var recent_collide

func _ready():
	if move_right:
		$Sprite.scale *= Vector2(-1, 1)

func flip_movement():
	move_right = not move_right
	$Sprite.scale *= Vector2(-1, 1)
	recent_collide = ""

func _process(delta):
	if dead:
		return
	
	if time_spent_still > TIME_SPENT_STILL_LIMIT:
		flip_movement()
	
	if move_right:
		velocity.x = MAX_SPEED
	else:
		velocity.x = -MAX_SPEED
		
export (int, 0, 200) var push = 40
export (int, 0, 200) var push_factor = 0.2

var time_spent_still: float = 0.0
const TIME_SPENT_STILL_LIMIT: float = 0.2
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
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP,
					false, 4, PI/4, false)
	
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("bodies"):
			if collision.collider is KinematicBody2D:
				continue
			if is_on_floor():
				collision.collider.apply_central_impulse(-collision.normal * push)
			else:
				collision.collider.apply_central_impulse(-collision.normal * velocity.length() * push_factor)
	
	if velocity.distance_to(Vector2(0,0)) == 0:
		time_spent_still += delta
	else:
		time_spent_still = 0
	
	
	
func on_die() -> void:
	get_tree().queue_delete(self)

func _on_Area2D_body_entered(body) -> void:
	if dead:
		return
	
	if body.name != Utils.PLAYER_NAME:
		return
	
	var player = body as Player
	
	var is_player_above = body.position.y < self.position.y
	if is_player_above and !player.is_on_floor():
		player.jump()
		
		on_die()
