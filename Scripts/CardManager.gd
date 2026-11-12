extends Node2D

const SCALE_FOR_HOVER = Vector2(1.05, 1.05)	# Scale as a percentage of the og scale (stored in the GAME_SCALE const)
var numCards: int				# Increases when a new card is made. Used for designating ids
var cardBeingDragged			# When a card is being dragged, it's stored here
var isHoveringCard: bool		# If a card is being hovered, this is true
var allCards = []				# Holds every card for z index calculations
@onready var InputManager: Node = $"../InputManager"

#region Startup, every frame and input/event handling
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	UpdateMousePosAndMoveCards()


# Handle all inputs (Mouse pressed/unpress, etc)
func _input(event) -> void:
	InputManager.HandleMouseEvents(event)

# Called by a card when it spawns. Assigns the ids and increases the number of total cards in existence
# Should change to include an array/list of all cards to properly z order and the like
func OnCardSpawn(card):
	ConnectCardSignals(card)
	numCards += 1
	card.scale = GameVariables.GAME_SCALE
	allCards.append(card)
	UpdateZIndex(card)
	card.position = Vector2(numCards*10, 450)
	card.faceup = true

# Called on a card when it spawns to properly set up the hover/unhover signals
func ConnectCardSignals(card):
	card.connect("hovered", OnHoveredOverCard)
	card.connect("hovered_off", OnHoveredOffCard)

# Called every frame for card moving
func UpdateMousePosAndMoveCards():
	InputManager.UpdateMousePos()
	if (cardBeingDragged):
		UpdateCardPosition(cardBeingDragged, InputManager.mousePos-InputManager.clampedLastMousePos)

#endregion

#region Do something to a card
# Move a card based on a delta
func UpdateCardPosition(card, delta):
	assert(card, "UpdateCardPosition not called on a card!")
	card.position = Vector2(clamp(card.position.x + delta.x, 0, GameVariables.screenSize.x),
							 clamp(card.position.y + delta.y, 0, GameVariables.screenSize.y))

func AnimateCardToPosition(card, cardPosition, speed = .1):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", cardPosition, speed)

# Handles highlighting and unhighlighting of cards
func HighlightCard(card, hovered):
	if (hovered):
		ScaleCard(card, SCALE_FOR_HOVER)
		UpdateZIndex(card, 2)
	else:
		if !(cardBeingDragged):
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

func ScaleCard(card, newScale):
	card.scale = newScale * GameVariables.GAME_SCALE

#endregion

#region Other functions
# Called any time the mouse is pressed. Does nothing if card is null
func OnMousePress(card):
	InputManager.mousePressTime = 0
	if (!card):
		return
	ScaleCard(card, Vector2(1, 1))
	if (!cardBeingDragged):
		StartDrag(card)
	else:
		EndDrag()

# Called any time the mouse button is released.
func OnMouseRelease(_card):
	var cardThatWasBeingDragged = cardBeingDragged
	if (InputManager.mousePressTime > InputManager.SHORT_PRESS_DURATION):
		EndDrag()
	if (cardThatWasBeingDragged):
		ScaleCard(cardThatWasBeingDragged, SCALE_FOR_HOVER)

# Called to start dragging a card
func StartDrag(card):
	if card.inContainer && !card.inContainer.canPullCardsFrom:
		return
	allCards.erase(card)
	allCards.insert(0, card)
	UpdateAllZIndexes()
	if card.inContainer && card.inContainer.canPullCardsFrom:
		card.inContainer.TryRemoveCard(card)
		cardBeingDragged = card
	elif !card.inContainer:
		cardBeingDragged = card

# Called to end dragging any card
func EndDrag():
	var cardContainerBelow = InputManager.RaycastCheck(InputManager.COLLISION_MASK_CARD_CONTAINER)
	if cardBeingDragged and cardContainerBelow and cardContainerBelow.canPutCardsInto:
		cardContainerBelow.TryAddCard(cardBeingDragged)
	var cardThatWasBeingDragged = cardBeingDragged
	cardBeingDragged = null
	return cardThatWasBeingDragged

# When the mouse hovers a card
func OnHoveredOverCard(card):
	if isHoveringCard:
		return
	isHoveringCard = true
	HighlightCard(card, true)

# When the mouse stops hovering a card
func OnHoveredOffCard(card):
	if cardBeingDragged:
		return
	HighlightCard(card, false)
	# Extra logic to check whether a card is being hovered directly from one to another
	var CardBeingHoveredMaybe = InputManager.RaycastCheck(InputManager.COLLISION_MASK_CARD)
	if CardBeingHoveredMaybe:
		HighlightCard(CardBeingHoveredMaybe, true)
	else:
		isHoveringCard = false
	
#endregion
