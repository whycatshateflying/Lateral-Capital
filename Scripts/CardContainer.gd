extends Node2D

const PADDING = .1				# Percentage of a card width that should be used as spacing between cards 
var cardsInContainer = []
var maxCardsInSelf: int = 4
var originalScale: Vector2
var canPullCardsFrom = true

# When first instantiated
func _ready():
	originalScale = scale
	SetMaxCardsAndScaleSelf(maxCardsInSelf)

func SetMaxCardsAndScaleSelf(numCards):
	maxCardsInSelf = numCards
	scale = Vector2((originalScale.x+PADDING) * maxCardsInSelf, originalScale.y)

# Add a card to the container
func TryAddCard(card):
	print("TryAddCard called!")
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
	print("TryRemoveCard called!")
	cardsInContainer.erase(card)
	UpdatePositions()

# Make every card in the container spaced evenly
func UpdatePositions():
	for i in range(cardsInContainer.size()):
		var cardSprite = cardsInContainer[i].get_node("CardImage")
		var cardWidth = (cardSprite.get_rect().size.x)*cardSprite.global_scale.x
		cardsInContainer[i].position = self.position + Vector2((i+.5-cardsInContainer.size()/2.0)*(cardWidth+(PADDING*cardWidth)),0)

func SnapCardToSelf(card):
	card.position = self.position
