extends KinematicBody2D
class_name Stalagmite

const FALL_MULTIPLIER = 2.5;
const FRICTION_GROUND = 30
const FRICTION_AIR = 20

onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var falling: bool = false
export (Vector2) var velocity = Vector2(0,0)
export (bool) var triggered = false
export (bool) var on_floor = false

func _ready():
	pass

func _physics_process(delta):
	check_object_below()	
			
	on_floor = is_on_floor()
	if is_on_floor():
		falling = false
		velocity.x = sign(velocity.x) * max(0, abs(velocity.x) - FRICTION_GROUND)
	elif triggered:
		falling = true
		velocity.x = sign(velocity.x) * max(0, abs(velocity.x) - FRICTION_AIR)
		velocity.y += gravity * delta
		
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP,
					false, 4, PI/4, false)

func check_object_below() -> void:
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var result = space_state.intersect_ray(global_position, global_position + Vector2(0,500), [self])
	if len(result.keys()) != 0:
		if result["collider"] == null:
			return
			
		var collider = result["collider"] as PhysicsBody2D
		if collider != null and collider.is_in_group("bodies"):
			triggered = true
