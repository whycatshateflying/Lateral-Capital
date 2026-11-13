extends Node


const GAME_SCALE = Vector2(.3, .3)
@onready var screenSize = get_viewport().get_visible_rect().size
enum suits {SPADE, HEART, CLUB, DIAMOND}


func _ready() -> void:
	screenSize = get_viewport().get_visible_rect().size
