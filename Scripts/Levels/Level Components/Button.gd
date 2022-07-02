extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const PLAYER_NAME = "Player1"

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered",self, "_on_body_entered")
	pass # Replace with function body.

func _on_body_entered(body):
	print(body.name)
	if body.name == PLAYER_NAME:
		print("Found player")
		$Sprite.modulate = Color(1,1,1,1)
