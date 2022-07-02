extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var enemies 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

const DEATH_RESET_TIME = 4

func reset_stage():
	$Player1.reset()
