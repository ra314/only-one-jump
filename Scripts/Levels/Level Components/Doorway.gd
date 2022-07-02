extends Area2D

var dragging_player: bool = false
var center: Vector2
const TELEPORT_DURATION = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "drag_player_in")
	center = Vector2(64*5, 64) * 0.5 * scale
	print(center)

func drag_player_in(body):
	if body.name == Utils.PLAYER_NAME and not dragging_player:
		var player: Player = body
		dragging_player = true
		$Tween.interpolate_property(player, "global_position",
		player.global_position, global_position+center, TELEPORT_DURATION,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.interpolate_callback(player, TELEPORT_DURATION, "go_to_next_level")
		$Tween.start()
		player.is_level_over = true
		print(player.global_position)
