extends Node

const SCALE_FOR_HOVER = Vector2(1.05, 1.05)	# Scale as a percentage of the og scale (stored in the GAME_SCALE const)
var isHoveringCard: bool		# If a card is being hovered, this is true
var allCards = []				# Holds every card
var allCardContainers = []		# Holds every CardContainer
@onready var InputManager: Node = $"../../InputManager"
@onready var GameManager: Node = $".."
var cardsSelected = []

#region Startup, every frame and input/event handling
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# Called by a card when it spawns. Assigns the ids and increases the number of total cards in existence
# Should change to include an array/list of all cards to properly z order and the like
func OnCardSpawn(card):
	ConnectCardSignals(card)
	allCards.append(card)
	ScaleCard(card, 1)
	UpdateZIndex(card)
	var random = RandomNumberGenerator.new()
	SetCard(card, random.randi_range(1, 14), random.randi_range(0, 3))
	card.name = "Card " + str(allCards.size())
	card.canBeSelected = true
	FlipCard(card, true)

# Called on a card when it spawns to properly set up the hover/unhover signals
func ConnectCardSignals(card):
	card.connect("hovered", OnHoveredOverCard)
	card.connect("hovered_off", OnHoveredOffCard)

#endregion

#region Do something to a card
func UpdateCardPosition(card, pos):
	card.position = pos

func AnimateCardToPosition(card, cardPosition, speed = .1):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", cardPosition, speed)

# Handles highlighting and unhighlighting of cards
func HighlightCard(card, hovered):
	if (hovered):
		ScaleCard(card, SCALE_FOR_HOVER)
		UpdateZIndex(card, 2)
	else:
		ScaleCard(card, Vector2(1, 1))
		UpdateZIndex(card)

func UpdateAllZIndexes():
	for card in allCards:
		UpdateZIndex(card)

func UpdateZIndex(card, index = null):
	if index:
		card.z_index = index
		return
	card.z_index = -(1+allCards.find(card))

# Flip this card. True for face up, false for face down
func FlipCard(card, up = !card.faceup):
	card.faceup = up
	card.get_node("CardBack").visible = !card.faceup
	card.get_node("CardImage").visible = card.faceup

func SetCard(card, value = 1, suit = GameVariables.SUITS.SPADE):
	card.value = value
	card.suit = suit
	card.get_node("CardImage/TEMPORARY s+v container/TEMPORARY value").text = str(value)
	card.get_node("CardImage/TEMPORARY s+v container/TEMPORARY suit").text = ["Spade", "Heart", "Club", "Diamond"][suit]

func ScaleCard(card, newScale):
	card.scale = newScale * GameVariables.GAME_SCALE

func SelectCard(card, selected = !card.selected):
	if !card.canBeSelected:
		return
	card.selected = selected
	if card.selected:
		cardsSelected.append(card)
		AnimateCardToPosition(card, card.position + Vector2(0, -30))
	else:
		cardsSelected.erase(card)
		AnimateCardToPosition(card, card.position + Vector2(0, 30))

func CreateCard(pos = Vector2(0, 0), value = null, suit = null):
	var card = GameManager.CARD_SCENE.instantiate()
	add_child(card)
	UpdateCardPosition(card, pos)
	var random = RandomNumberGenerator.new()
	if value == null:
		value = random.randi_range(1,14)
	if suit == null:
		suit = random.randi_range(0,3)
	SetCard(card, value, suit)
	print("Creating " + card.name + "!")
	return card

func UnloadCard(card):
	print("Unloading " + card.name + "!")
	allCards.erase(card)
	UpdateAllZIndexes()
	if card.inContainer:
		card.inContainer.TryRemoveCard(card)
	card.queue_free()

func UnloadCardContainer(container):
	print("Unloading " + container.name + "!")
	allCardContainers.erase(container)
	for card in container.cardsInContainer:
		container.TryRemoveCard(card)
	container.queue_free()

#endregion

#region Other functions

func OnMousePress(card):
	InputManager.mousePressTime = 0
	if (!card):
		return
	ScaleCard(card, Vector2(1, 1))
	SelectCard(card)

# Called any time the mouse button is released.
func OnMouseRelease(_card):
	pass

# When the mouse hovers a card
func OnHoveredOverCard(card):
	if isHoveringCard:
		return
	isHoveringCard = true
	HighlightCard(card, true)

# When the mouse stops hovering a card
func OnHoveredOffCard(card):
	HighlightCard(card, false)
	# Extra logic to check whether a card is being hovered directly from one to another
	var mousePos = get_viewport().get_mouse_position()
	var cardBeingHoveredMaybe = InputManager.RaycastCheck(mousePos, InputManager.COLLISION_MASK_CARD)
	isHoveringCard = false
	if cardBeingHoveredMaybe:
		OnHoveredOverCard(cardBeingHoveredMaybe)
	
#endregion
