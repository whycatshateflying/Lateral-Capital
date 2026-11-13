extends Node

@onready var CardManager: Node = $CardManager
@onready var MainMenu: Node2D = $MainMenu
@onready var MainButtons: VBoxContainer = $MainMenu/MainButtons
@onready var Credits: VBoxContainer = $MainMenu/Credits
@onready var OpenMenuButton: TextureButton = $OpenMenuButton
@onready var Title: TextureRect = $MainMenu/Title
const cardScenePath = "res://Scenes/Card.tscn" 
const cardContainerScenePath = "res://Scenes/CardContainer.tscn"
var handCount = 6 # Number of cards in hand

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GoToMainMenu()

# Instantiate cards and add them to a cardContainer acting as the player hand
func SetupCards():
	var cardScene = preload(cardScenePath)
	var container = preload(cardContainerScenePath)

	var playerHand = container.instantiate()
	CardManager.add_child(playerHand)
	playerHand.position = Vector2(GameVariables.screenSize.x/2, GameVariables.screenSize.y - playerHand.GetHeight()/2)
	playerHand.SetMaxCards(handCount)

	for i in range(handCount):
		var newCard = cardScene.instantiate()
		CardManager.add_child(newCard)
		newCard.name = "Card " + str(i)
		playerHand.TryAddCard(newCard)


# Hide everything, remove cards/cardContainers from existence
func Cleanup():
	CleanupGame()
	TitleVisibility(false)
	MainButtonsVisibility(false)
	CreditsVisibility(false)
	ToMenuButtonVisibility(false)

func CleanupGame():
	var allCardsCopy = CardManager.allCards
	var count = allCardsCopy.size()
	while allCardsCopy.size() > 0 && count > 0:
		CardManager.UnloadCard(allCardsCopy[0])
		count -= 1
	for card in CardManager.allCards:
		push_error("Could not unload " + card.name + "!")
	
	var allCardContainersCopy = CardManager.allCardContainers
	count = allCardContainersCopy.size()
	while allCardContainersCopy.size() > 0 && count>0:
		CardManager.UnloadCardContainer(allCardContainersCopy[0])
		count -= 1
	for container in CardManager.allCardContainers:
		push_error("Could not unload " + container.name + "!")

func GoToMainMenu():
	Cleanup()
	MainButtonsVisibility(true)
	TitleVisibility(true)

func GoToPlay():
	Cleanup()
	ToMenuButtonVisibility(true)
	SetupCards()

func GoToCredits():
	Cleanup()
	CreditsVisibility(true)

func QuitGame():
	get_tree().quit()

func MainButtonsVisibility(visible):
	MainButtons.visible = visible

func ToMenuButtonVisibility(visible):
	OpenMenuButton.visible = visible

func CreditsVisibility(visible):
	Credits.visible = visible

func TitleVisibility(visible):
	Title.visible = visible
