extends Node2D

var cardsInContainer = []
var maxCardsInSelf: int = 1
var originalScale: Vector2
var canPullCardsFrom = true
var canPutCardsInto = true
@onready var CardManager = get_parent()

# When first instantiated
func _ready():
	CardManager.allCardContainers.append(self)
	originalScale = scale * GameVariables.GAME_SCALE
	scale = originalScale

func _process(_delta: float) -> void:
	pass

func GetHeight() -> float:
	var containerSprite = self.get_node("CardContainerImage")
	var containerHeight = (containerSprite.get_rect().size.y)*containerSprite.global_scale.y
	return containerHeight;

func SetMaxCards(numCards):
	maxCardsInSelf = numCards

# Add a card to the container
func TryAddCard(card):
	if cardsInContainer.size() >= maxCardsInSelf:
		return
	if card in cardsInContainer:
		return
	cardsInContainer.append(card)
	card.inContainer = self
	CardManager.UpdateCardPosition(card, position)
	UpdatePositions()

func TryRemoveCard(card):
	if card in cardsInContainer:
		card.inContainer = null
		cardsInContainer.erase(card)
		UpdatePositions()

# Make every card in the container spaced evenly along the x, retaining their y
func UpdatePositions():
	var containerSprite = self.get_node("CardContainerImage")
	var containerWidth = (containerSprite.get_rect().size.x)*containerSprite.global_scale.x
	for i in range(cardsInContainer.size()):
		CardManager.AnimateCardToPosition(cardsInContainer[i], Vector2(self.position.x + containerWidth/cardsInContainer.size()*(i+.5) - containerWidth/2, cardsInContainer[i].position.y))
		CardManager.UpdateZIndex(cardsInContainer[i])
