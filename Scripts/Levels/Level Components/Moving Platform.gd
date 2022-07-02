extends StaticBody2D

export var rot_degrees: float
export var rot_duration: float
var rot_time_left: float

export var slide_distance: Vector2
export var slide_duration: float
var slide_time_left: float

export var rotating = false
export var moving = false

# Called when the node enters the scene tree for the first time.
func _ready():
	rot_time_left = rot_duration
	slide_time_left = slide_duration

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if rotating:
		if rot_duration:
			var new_delta = delta
			if rot_time_left - delta < 0:
				new_delta = rot_time_left
			rotation_degrees += (new_delta/rot_duration) * rot_degrees
			rot_time_left -= new_delta
			if rot_time_left == 0:
				rotating = false
	
	if moving:
		if slide_duration:
			var new_delta = delta
			if slide_time_left - delta < 0:
				new_delta = rot_time_left
			position += (delta/slide_duration) * slide_distance
			slide_time_left -= delta
			if slide_time_left == 0:
				moving = false
