extends KinematicBody2D
class_name Stalagmite

const FALL_MULTIPLIER = 2.5;
onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var falling: bool = false
var velocity: Vector2 = Vector2(0,0)

func _ready():
	pass

func _physics_process(delta):
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var result = space_state.intersect_ray(global_position, global_position + Vector2(0,500), [self])
	if len(result.keys()) != 0:
		if result["collider"].name == Utils.PLAYER_NAME:
			falling = true
	
	if falling:
		velocity.y += gravity * delta
		
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP,
					false, 4, PI/4, false)
