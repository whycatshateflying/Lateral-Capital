extends Node


const GAME_SCALE = Vector2(.3, .3)
var screenSize: Vector2			# Set when first instatiated

func _ready() -> void:
	screenSize = get_viewport().get_visible_rect().size
