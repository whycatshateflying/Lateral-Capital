extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var cardScene = preload("res://Scenes/Card.tscn")
	var cardContainerScene = preload("res://Scenes/CardContainer.tscn")
	for i in range(10):
		var newCard = cardScene.instantiate()
		$"../CardManager".add_child(newCard)
		newCard.name = str(newCard.id)
	var playerHand = cardContainerScene.instantiate()
	$"../CardManager".add_child(playerHand)
	playerHand.position = Vector2(playerHand.get_parent().screenSize.x/2, playerHand.get_parent().screenSize.y/2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
