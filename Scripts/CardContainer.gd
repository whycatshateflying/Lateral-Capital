extends Node2D

var cardsInContainer = []
var maxCardsInSelf: int
var originalScale: Vector2
var canPullCardsFrom = true
var canPutCardsInto = true

# When first instantiated
func _ready():
	originalScale = scale * GameVariables.GAME_SCALE
	scale = originalScale
	SetMaxCards(14)

func _process(_delta: float) -> void:
	pass

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
	UpdatePositions()

func TryRemoveCard(card):
	if card in cardsInContainer:
		card.inContainer = null
		cardsInContainer.erase(card)
		UpdatePositions()

# Make every card in the container spaced evenly
func UpdatePositions():
	var containerSprite = self.get_node("CardContainerImage")
	var containerWidth = (containerSprite.get_rect().size.x)*containerSprite.global_scale.x
	for i in range(cardsInContainer.size()):
		cardsInContainer[i].get_parent().AnimateCardToPosition(cardsInContainer[i], 
												self.position + Vector2(containerWidth/cardsInContainer.size()*(i+.5), 0) - Vector2(containerWidth/2,0))
		cardsInContainer[i].get_parent().UpdateZIndex(cardsInContainer[i])
		
func UpdatePositionsOld():
	var padding = .05
	for i in range(cardsInContainer.size()):
		var cardSprite = cardsInContainer[i].get_node("CardImage")
		var cardWidth = (cardSprite.get_rect().size.x)*cardSprite.global_scale.x
		cardsInContainer[i].position = self.position + Vector2((i+.5-cardsInContainer.size()/2.0)*(cardWidth+(2*padding*cardWidth)),0)
