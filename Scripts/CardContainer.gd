extends Node2D

var padding = .05				# Percentage of a card width that should be used as spacing between cards 
var cardsInContainer = []
var maxCardsInSelf: int = 1
var originalScale: Vector2
var canPullCardsFrom = false
var canPutCardsInto = true

# When first instantiated
func _ready():
	originalScale = scale * GameVariables.GAME_SCALE
	SetMaxCardsAndScaleSelf(maxCardsInSelf)

func _process(_delta: float) -> void:
	pass

func SetMaxCardsAndScaleSelf(numCards):
	maxCardsInSelf = numCards
	scale = Vector2((originalScale.x+(2*padding)) * maxCardsInSelf, originalScale.y+padding)

# Add a card to the container
func TryAddCard(card):
	if cardsInContainer.size() >= maxCardsInSelf:
		return
	if card in cardsInContainer:
		return
	cardsInContainer.append(card)
	card.inContainer = self
	SnapCardToSelf(card)
	# card.get_node("Area2D/CollisionShape2D").disabled = !canPullCardsFrom
	UpdatePositions()

func TryRemoveCard(card):
	if card in cardsInContainer:
		card.inContainer = null
		cardsInContainer.erase(card)
		UpdatePositions()

# Make every card in the container spaced evenly
func UpdatePositions():
	for i in range(cardsInContainer.size()):
		var cardSprite = cardsInContainer[i].get_node("CardImage")
		var cardWidth = (cardSprite.get_rect().size.x)*cardSprite.global_scale.x
		cardsInContainer[i].position = self.position + Vector2((i+.5-cardsInContainer.size()/2.0)*(cardWidth+(2*padding*cardWidth)),0)

func SnapCardToSelf(card):
	card.position = self.position
