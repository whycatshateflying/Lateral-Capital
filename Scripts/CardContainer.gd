extends Node2D

var cardsInContainer = []
var maxCardsInSelf: int = 1
var canPutCardsInto = true
var canSelectCardsIn = true
var pile: bool = false
@onready var CardManager = get_parent()
@onready var DistributeCards: HBoxContainer = $DistributeCards
var slots = []
var queueUpdatePos: bool = false

# When first instantiated
func _ready():
	CardManager.allCardContainers.append(self)
	scale = scale * GameVariables.GAME_SCALE
	DistributeCards.position = -DistributeCards.size / 2.0

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
	AddSlot()
	cardsInContainer.insert(0, card)
	card.inContainer = self
	card.canBeSelected = canSelectCardsIn
	UpdatePositions()

func AddSlot():
	var slot = Control.new()
	slot.custom_minimum_size = Vector2(1, 1)
	slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	DistributeCards.add_child(slot)
	slots.append(slot)
	return slot

func Shuffle():
	cardsInContainer.shuffle()
	if pile:
		for card in cardsInContainer:
			var random = RandomNumberGenerator.new()
			CardManager.AnimateCardToPosition(card, card.position + Vector2(50, 0).rotated(random.randf_range(0, TAU)), .05)	# Push the cards out in random directions so we can see that it shuffles
			await get_tree().process_frame
	UpdatePositions()

func DrawCardToContainer(container, card = cardsInContainer[0]):
	TryRemoveCard(card)
	container.TryAddCard(card)

func AddScale(newScale = 0):
	scale = scale+Vector2(newScale, newScale)
	print("container is " + str(scale))
	for card in cardsInContainer:
		CardManager.AddScaleToCard(card, "container", newScale)
		print(card.name + " is " + str(card.scale))

func TryRemoveCard(card):
	if card in cardsInContainer:
		RemoveSlot()
		card.rotation = 0
		card.inContainer = null
		cardsInContainer.erase(card)
		UpdatePositions()

func RemoveSlot(slot = slots[0]):
	DistributeCards.remove_child(slot)
	slots.erase(slot)
	slot.queue_free()
	
# Make every card in the container spaced evenly along the x of the container
func UpdatePositions():
	if queueUpdatePos:
		return
	queueUpdatePos = true
	await get_tree().process_frame
	if pile:
		var cardsInContainerCopy = cardsInContainer
		cardsInContainerCopy.reverse()
		for card in cardsInContainerCopy:
			CardManager.AnimateCardToPosition(card, position)
			CardManager.AnimateCardToRotation(card, rotation)
			CardManager.MoveCardToTop(card)
		queueUpdatePos = false
		return

	for i in range(cardsInContainer.size()):
		var newPosition = slots[i].get_global_transform() * (slots[i].size / 2.0)
		var newRotation = slots[i].get_global_transform().get_rotation()
		if cardsInContainer[i].selected:
			newPosition += GameVariables.SELECTION_MOTION
		CardManager.AnimateCardToPosition(cardsInContainer[i], newPosition)
		CardManager.AnimateCardToRotation(cardsInContainer[i], newRotation)
	queueUpdatePos = false
