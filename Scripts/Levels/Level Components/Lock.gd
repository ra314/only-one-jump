extends Area2D
class_name Lock

func _ready():
	connect("body_entered", self, "_on_body_entered")

signal unlocking
func _on_body_entered(body) -> void:
	if body.name == Utils.KEY_NAME:
		emit_signal("unlocking")

func _on_Key_unlocking():
	get_tree().queue_delete(self)
