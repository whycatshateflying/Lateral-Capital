extends Node

const handCount = 6 # Number of cards in hand
const cardScenePath = "res://Scenes/Card.tscn" 
const cardContainerScene = "res://Scenes/CardContainer.tscn"
const cardWidth = 100 # Space between cards in hand
const handPosY = 600 # Vertical position for player hand
var playerHand = [] # Array containing cards in player hand
var screenCenterX # Position to place the hand in the center of the screen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screenCenterX = get_viewport().size.x / 2
	
	var cardScene = preload(cardScenePath)
	var container = preload(cardContainerScene)
	for i in range(handCount):
		var newCard = cardScene.instantiate()
		$"../CardManager".add_child(newCard)
		newCard.name = "Card"
		addToHand(newCard)
		
	var playerContainer = container.instantiate()
	$"../CardManager".add_child(playerContainer)
	playerContainer.position = Vector2(playerContainer.get_parent().screenSize.x/2, playerContainer.get_parent().screenSize.y/2)

func addToHand(card):
	playerHand.insert(0, card)
	updateHandPos()

func updateHandPos():
	for i in range(playerHand.size()):
		# Gets position of new card based on index number
		var newCardPos = Vector2(findCardPos(i), handPosY)
		var card = playerHand[i]
		moveCard(card, newCardPos)

func findCardPos(index):
	var xOffset = (playerHand.size() - 1) * cardWidth
	var handWidth = screenCenterX + index * cardWidth - xOffset / 2
	return handWidth

func moveCard(card, newCardPos):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", newCardPos, .15)
