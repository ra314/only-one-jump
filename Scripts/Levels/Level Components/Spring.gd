extends Area2D
class_name Spring

func _ready():
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body) -> void:
	if body.name == Utils.PLAYER_NAME:
		var player = body as Player
		
		var is_player_above = body.position.y < self.position.y
		if is_player_above and !player.is_on_floor():
			player.jump()
