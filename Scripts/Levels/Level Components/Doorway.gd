extends Area2D

var dragging_player: bool = false
var center: Vector2
const TELEPORT_DURATION = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "drag_player_in")
	center = position + Vector2(0.5, 0.5) * scale

func drag_player_in(body) -> void:
	if body.name == Utils.PLAYER_NAME and not dragging_player:
		var player: Player = body
		dragging_player = true
		$Tween.interpolate_property(player, "position",
		player.position, center, TELEPORT_DURATION,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
		$Tween.interpolate_callback(player, TELEPORT_DURATION, "go_to_next_level")
		$Tween.start()
		player.is_level_over = true
