extends Node

const SHORT_PRESS_DURATION = .116		# Below how many seconds is a "short" press?
const COLLISION_MASK_CARD = 1	# Bitmask for the card collider. Cards have a collision mask of 1, as opposed to other things like containers. Should always be 1
const COLLISION_MASK_CARD_CONTAINER = 2	# Bitmask for the cardContainer collider. CardContainers have a collision mask of 2, as opposed to other things like cards. Should always be 2
@onready var mousePos: Vector2 = Vector2(0, 0)			# Used for card movement. Updates with UpdateMousePos
@onready var clampedLastMousePos: Vector2 = Vector2(0, 0)		# Lags behind one frame, to be able to calculate a movement delta. Is clamped to bounds of the screen
var mousePressTime: float			# Time, in sec, since the mouse started being pressed
@onready var CardManager: Node = $"../GameManager/CardManager"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mousePressTime = mousePressTime + delta

# Called every frame for card moving
func UpdateMousePos():
	clampedLastMousePos = Vector2(clamp(mousePos.x, 0, GameVariables.screenSize.x),
							clamp(mousePos.y, 0, GameVariables.screenSize.y))
	mousePos = get_viewport().get_mouse_position()
		
# Handles mouse events specifically
func HandleMouseEvents(event):
	if !event is InputEventMouseButton:
		return
	if event.button_index == MOUSE_BUTTON_LEFT:
		var card = RaycastCheck(COLLISION_MASK_CARD)
		if event.is_pressed():
			CardManager.OnMousePress(card)
		elif event.is_released():
			CardManager.OnMouseRelease(card)
	elif event.button_index == MOUSE_BUTTON_MIDDLE && event.is_pressed():
		var cardBelowMouse = RaycastCheck(COLLISION_MASK_CARD)
		if cardBelowMouse:
			CardManager.FlipCard(cardBelowMouse)
			print("[DEBUG] Flipping card " + cardBelowMouse.name)

# Returns the first card the mouse is over, by z axis
func RaycastCheck(mask):
	var space_state = get_viewport().world_2d.direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_viewport().get_mouse_position()
	parameters.collide_with_areas = true;
	parameters.collision_mask = mask
	
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
