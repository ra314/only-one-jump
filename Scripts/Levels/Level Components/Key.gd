extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

signal unlocking
func _on_Lock_unlocking():
	emit_signal("unlocking")
	get_tree().queue_delete(self)
