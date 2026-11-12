extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var cardScene = preload("res://Scenes/Card.tscn")
	var cardContainerScene = preload("res://Scenes/CardContainer.tscn")
	for i in range(10):
		var newCard = cardScene.instantiate()
		$"../CardManager".add_child(newCard)
		newCard.name = str(i)
	var playerHand = cardContainerScene.instantiate()
	$"../CardManager".add_child(playerHand)
	playerHand.position = Vector2(GameVariables.screenSize.x/2, GameVariables.screenSize.y/2)
