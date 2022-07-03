extends Area2D
class_name Pressure_Plate

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("activated", self, "switch_state")

signal activated
func _on_body_entered(body) -> void:
	if not body is PhysicsBody2D:
		return
		
	body = body as PhysicsBody2D
	if body.is_in_group("bodies"):
		var is_body_above = body.position.y < self.position.y
		if is_body_above:
			emit_signal("activated")
	# if body.name == Utils.PLAYER_NAME:
	#	var player = body as Player
	#	
	#	var is_player_above = body.position.y < self.position.y
	#	if is_player_above:
	#		emit_signal("activated")
			
func switch_state() -> void:
	$On.visible = false
	$Off.visible = true
