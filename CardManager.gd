extends Node2D

const COLLISION_MASK_CARD = 1
var cardBeingDragged
var screenSize
var mousePos
enum cardDragModes { TOGGLE, HOLD }
var cardDragMode = cardDragModes.TOGGLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screenSize = get_viewport_rect().size
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	mousePos = get_global_mouse_position()
	UpdateCardPosition(cardBeingDragged, mousePos)

func UpdateCardPosition(card: Node2D, location: Vector2) -> int:
	if not card:
		return -1
	card.position = Vector2(clamp(location.x, 0, screenSize.x), clamp(location.y, 0, screenSize.y))
	return 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var card = RaycastCheckForCard(event)
		if event.is_pressed():
			OnMousePress(card)
		elif event.is_released():
			OnMouseRelease(card)

func OnMousePress(card: Node2D):
	if cardDragMode == cardDragModes.HOLD:
		cardBeingDragged = card
	if cardDragMode == cardDragModes.TOGGLE:
		if cardBeingDragged:
			cardBeingDragged = null
		else:
			cardBeingDragged = card

func OnMouseRelease(_card: Node2D):
	if cardDragMode == cardDragModes.HOLD:
		cardBeingDragged = null

# Returns the "first" card the mouse is over
func RaycastCheckForCard(event: InputEvent) -> Node2D:
	assert(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT, "RaycastCheckForCard takes an InputEventMouseButton")
	
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = mousePos
	parameters.collide_with_areas = true;
	parameters.collision_mask = COLLISION_MASK_CARD
	
	var result = space_state.intersect_point(parameters)
	result.sort_custom(SortByColliderParentZIndex)
	if (result.size() > 0):
		return(result[0].collider.get_parent())
	return null

func SortByColliderParentZIndex(a, b) -> bool:
	if a.collider.get_parent().get_z_index() > b.collider.get_parent().get_z_index():
		return true
	return false
