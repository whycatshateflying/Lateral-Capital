extends Node2D

var inContainer			# References the container the card is in
var faceup: bool		# true: face UP false: face DOWN
signal hovered
signal hovered_off

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().OnCardSpawn(self)
	Flip(faceup)

# Flip this card. True for face up, false for face down
func Flip(up = !faceup):
	faceup = up
	get_node("CardBack").visible = !faceup
	get_node("CardImage").visible = faceup

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
