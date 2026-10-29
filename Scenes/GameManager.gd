extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var cardScene = preload("res://Scenes/Card.tscn")
	for i in range(10):
		var newCard = cardScene.instantiate()
		$"../CardManager".add_child(newCard)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
