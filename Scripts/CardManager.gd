extends Node2D

const COLLISION_MASK_CARD = 1	# Bitmask for the card collider. Cards have a collision mask of 1, as opposed to other things like containers. Should always be 1
const COLLISION_MASK_CARD_CONTAINER = 2	# Bitmask for the cardContainer collider. CardContainers have a collision mask of 2, as opposed to other things like cards. Should always be 2
var numCards: int				# Increases when a new card is made. Used for designating ids
var cardBeingDragged			# When a card is being dragged, it's stored here
var isHoveringCard: bool		# If a card is being hovered, this is true
var screenSize: Vector2			# Set when first instatiated
var mousePos: Vector2			# Used for card movement. Updates with UpdateMousePos
var clampedLastMousePos: Vector2		# Lags behind one frame, to be able to calculate a movement delta. Is clamped to bounds of the screen
enum cardDragModes { TOGGLE, HOLD }
var cardDragMode = cardDragModes.HOLD
								# HOLD: click and drag for moving cards
								# TOGGLE: click to pick up a card, and click to put it back down
								# Goal is to make this obsolete, and automatically detect a "long" press
var scaleForHover = Vector2(1.05, 1.05)	# Scale as a percentage of the og scale (stored in the GAME_SCALE const)

#region Startup, every frame and input/event handling
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screenSize = get_viewport_rect().size
	mousePos = Vector2(0, 0)
	clampedLastMousePos = Vector2(0, 0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	UpdateMousePosAndMoveCards()

# Called every frame for card moving
func UpdateMousePosAndMoveCards():
	clampedLastMousePos = Vector2(clamp(mousePos.x, 0, screenSize.x),
							clamp(mousePos.y, 0, screenSize.y))
	mousePos = get_global_mouse_position()
	if (cardBeingDragged):
		UpdateCardPosition(cardBeingDragged, mousePos-clampedLastMousePos)

# Handle all inputs (Mouse pressed/unpress, etc)
func _input(event) -> void:
	HandleMouseEvents(event)

# Handles mouse events specifically
func HandleMouseEvents(event):
	if !event is InputEventMouseButton:
		return
	if event.button_index == MOUSE_BUTTON_LEFT:
		var card = RaycastCheckForCard()
		if event.is_pressed():
			OnMousePress(card)
		elif event.is_released():
			OnMouseRelease(card)
	elif event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed():
		if cardDragMode == cardDragModes.TOGGLE:
			cardDragMode = cardDragModes.HOLD
		elif cardDragMode == cardDragModes.HOLD:
			cardDragMode = cardDragModes.TOGGLE
		print("[DEBUG] Grab mode is now " + str(["TOGGLE", "HOLD"][cardDragMode]))
	elif event.button_index == MOUSE_BUTTON_MIDDLE && event.is_pressed():
		var cardContainerBelow = RaycastCheckForCardContainer()
		if cardContainerBelow:
			cardContainerBelow.SetMaxCardsAndScaleSelf(cardContainerBelow.maxCardsInSelf + 1)

# Called by a card when it spawns. Assigns the ids and increases the number of total cards in existence
# Should change to include an array/list of all cards to properly z order and the like
func OnCardSpawn(card):
	ConnectCardSignals(card)
	numCards += 1
	card.scale = GameVariables.GAME_SCALE
	card.id = numCards
	card.z_index = -numCards
	card.position = Vector2(numCards, 450)

# Called on a card when it spawns to properly set up the hover/unhover signals
func ConnectCardSignals(card):
	card.connect("hovered", OnHoveredOverCard)
	card.connect("hovered_off", OnHoveredOffCard)

#endregion

#region Other functions
# Move a card based on a delta
func UpdateCardPosition(card, delta):
	assert(card, "UpdateCardPosition not called on a card!")
	card.position = Vector2(clamp(card.position.x + delta.x, 0, screenSize.x),
							 clamp(card.position.y + delta.y, 0, screenSize.y))

func ScaleCard(card, newScale):
	card.scale = newScale * GameVariables.GAME_SCALE

# Called any time the mouse is pressed. Does nothing if card is null
func OnMousePress(card):
	if (!card):
		return
	ScaleCard(card, Vector2(1, 1))
	if cardDragMode == cardDragModes.HOLD:
		StartDrag(card)
	if cardDragMode == cardDragModes.TOGGLE:
		if !cardBeingDragged:
			StartDrag(card)
		else:
			EndDrag()

# Called any time the mouse button is released.
func OnMouseRelease(_card):
	var cardThatWasBeingDragged = cardBeingDragged
	if cardDragMode == cardDragModes.HOLD:
		EndDrag()
	if (cardThatWasBeingDragged):
		ScaleCard(cardThatWasBeingDragged, scaleForHover)

# Called to start dragging a card
func StartDrag(card = null):
	if card.inContainer && card.inContainer.canPullCardsFrom:
		card.inContainer.TryRemoveCard(card)
		cardBeingDragged = card
	elif !card.inContainer:
		cardBeingDragged = card

# Called to end dragging any card
func EndDrag():
	var cardContainerBelow = RaycastCheckForCardContainer()
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
	var CardBeingHoveredMaybe = RaycastCheckForCard()
	if CardBeingHoveredMaybe:
		HighlightCard(CardBeingHoveredMaybe, true)
	else:
		isHoveringCard = false

# Handles highlighting and unhighlighting of cards
func HighlightCard(card, hovered):
	print(("Yes" if hovered else "No") + " hovering card " + card.name)
	if (hovered):
		ScaleCard(card, scaleForHover)
		card.z_index = 2
	else:
		if !(cardBeingDragged):
			ScaleCard(card, Vector2(1, 1))
		card.z_index = -card.id

# Returns the first cardContainer the mouse is over, by z axis
func RaycastCheckForCardContainer():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true;
	parameters.collision_mask = COLLISION_MASK_CARD_CONTAINER
	
	var result = space_state.intersect_point(parameters)
	# While the structure of a CardContainer is still CardContainer/Area2D/CollisionShape2D
	# If that changes, reimplement this though
	return GetCardWithHighestZ(result)

# Returns the first card the mouse is over, by z axis
func RaycastCheckForCard():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true;
	parameters.collision_mask = COLLISION_MASK_CARD
	
	var result = space_state.intersect_point(parameters)
	return GetCardWithHighestZ(result)

# Given a list of Area2Ds (of cards), return the ->card<- containing it with the highest Z index. Returns null if the list is empty
func GetCardWithHighestZ(cards):
	if (!cards or cards.size() == 0):
		return null
	var highest = cards[0]
	for card in cards:
		if card.collider.get_parent().z_index > highest.collider.get_parent().z_index:
			highest = card
	return highest.collider.get_parent()

#endregion
