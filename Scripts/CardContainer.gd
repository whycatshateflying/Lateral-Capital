extends Node2D

var cardsInContainer = []
var maxCardsInSelf: int = 1
var canPutCardsInto = true
var canSelectCardsIn = true
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
	cardsInContainer.append(card)
	card.inContainer = self
	card.canBeSelected = canSelectCardsIn
	CardManager.UpdateCardPosition(card, position)
	UpdatePositions()

func AddSlot():
	var slot = Control.new()
	slot.custom_minimum_size = Vector2(1, 1)
	slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	DistributeCards.add_child(slot)
	slots.append(slot)
	return slot

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
	if (queueUpdatePos):
		return
	queueUpdatePos = true
	await get_tree().process_frame
	if (DistributeCards):
		print("Position of DistributeCards is " + str(DistributeCards.position))
	for i in range(cardsInContainer.size()):
		cardsInContainer[i].position = slots[i].get_global_transform() * (slots[i].size / 2.0)
		cardsInContainer[i].rotation = slots[i].get_global_transform().get_rotation()
		if cardsInContainer[i].selected:
			CardManager.UpdateCardPosition(cardsInContainer[i], cardsInContainer[i].position + Vector2(0, -30))
	queueUpdatePos = false
