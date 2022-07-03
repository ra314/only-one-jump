extends KinematicBody2D
class_name Enemy

const MAX_SPEED = 250

const FALL_MULTIPLIER = 2.5;

export (bool) var move_right = false
var dead = false

export (Vector2) var velocity = Vector2(0, 0)
onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Changes direction after getting stuck in a position for too long
const WALL_TIMEOUT = 3
export (float) var wall_time = 0
export (Vector2) var last_pos = Vector2(0, 0)
export (int) var slide_count = 0
export (String) var recent_collide

func _ready():
	if move_right:
		$Sprite.scale *= Vector2(-1, 1)

func _process(delta):
	if dead:
		return
		
	slide_count = get_slide_count()
		
	if (get_slide_count() == 1) or wall_time >= WALL_TIMEOUT:
		recent_collide = get_slide_collision(0).collider.name
		if recent_collide == "TileMap" and is_on_wall():
			move_right = not move_right
			$Sprite.scale *= Vector2(-1, 1)
			wall_time = 0
			recent_collide = ""
	elif is_on_wall() and get_slide_count() > 1:
		if position == last_pos:
			wall_time += delta
		last_pos = position
		
	if move_right:
		velocity.x = MAX_SPEED
	else:
		velocity.x = -MAX_SPEED
		
export (int, 0, 200) var push = 40
export (int, 0, 200) var push_factor = 0.2

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
