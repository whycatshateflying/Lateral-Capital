extends Node

@onready var CardManager: Node = $CardManager
@onready var MainMenu: Node2D = $MainMenu
@onready var MainButtons: VBoxContainer = $MainMenu/MainButtons
@onready var Credits: VBoxContainer = $MainMenu/Credits
@onready var OpenMenuButton: TextureButton = $OpenMenuButton
@onready var Title: Label = $MainMenu/Title

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
	CleanupCards()
	TitleVisibility(false)
	MainButtonsVisibility(false)
	CreditsVisibility(false)
	ToMenuButtonVisibility(false)

func CleanupCards():
	for i in CardManager.get_children():
		CardManager.remove_child(i)

func GoToMainMenu():
	Cleanup()
	MainButtonsVisibility(true)
	TitleVisibility(true)

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
	Cleanup()
	ToMenuButtonVisibility(true)
	SetupCards()

func _on_exit_pressed() -> void:
	QuitGame()

func _on_credits_button_pressed() -> void:
	Cleanup()
	CreditsVisibility(true)

func _on_back_from_credits_pressed() -> void:
	GoToMainMenu()

func _on_open_menu_button_pressed() -> void:
	GoToMainMenu()

#endregion
