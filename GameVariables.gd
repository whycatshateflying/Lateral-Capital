extends Node


const GAME_SCALE = Vector2(.3, .3)
const SELECTION_MOTION = Vector2(0, -50) * GAME_SCALE
@onready var screenSize = get_viewport().get_visible_rect().size
enum SUITS {SPADE, HEART, CLUB, DIAMOND}


func _ready() -> void:
	pass
