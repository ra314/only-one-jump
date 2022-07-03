extends Area2D
class_name Spring

export (bool) var locked = false

func _ready():
	connect("body_entered", self, "_on_body_entered")
	
	if locked:
		lock()

func _on_body_entered(body) -> void:
	if locked:
		return
		
	if body.name == Utils.PLAYER_NAME:
		var player = body as Player
		
		var is_player_above = body.position.y < self.position.y
		if is_player_above and !player.is_on_floor():
			player.jump()

func lock() -> void:
	$On.visible = false
	$Off.visible = true

func unlock() -> void:
	locked = false
	$On.visible = true
	$Off.visible = false

func _on_Pressure_Plate_activated():
	unlock()
