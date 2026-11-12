extends Node

@onready var CardManager: Node = $CardManager
@onready var MainMenu: Node2D = $MainMenu
@onready var MainButtons: VBoxContainer = $MainMenu/MainButtons
@onready var Credits: VBoxContainer = $MainMenu/Credits
@onready var OpenMenuButton: TextureButton = $OpenMenuButton
@onready var Title: TextureRect = $MainMenu/Title

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GoToMainMenu()

func SetupCards():
	var cardScene = preload("res://Scenes/Card.tscn")
	var cardContainerScene = preload("res://Scenes/CardContainer.tscn")
	for i in range(10):
		var newCard = cardScene.instantiate()
		CardManager.add_child(newCard)
		newCard.name = str(i)
	var playerHand = cardContainerScene.instantiate()
	CardManager.add_child(playerHand)
	playerHand.position = Vector2(GameVariables.screenSize.x/2, GameVariables.screenSize.y/2)

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

func MainButtonsVisibility(visible):
	MainButtons.visible = visible

func ToMenuButtonVisibility(visible):
	OpenMenuButton.visible = visible

func CreditsVisibility(visible):
	Credits.visible = visible

func TitleVisibility(visible):
	Title.visible = visible

func QuitGame():
	get_tree().quit()

#region Incoming button signals 
func _on_play_button_pressed() -> void:
	GoToPlay()

func _on_exit_pressed() -> void:
	QuitGame()

func _on_credits_button_pressed() -> void:
	GoToCredits()

func _on_back_from_credits_pressed() -> void:
	GoToMainMenu()

func _on_open_menu_button_pressed() -> void:
	GoToMainMenu()

#endregion
