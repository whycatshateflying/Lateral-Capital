extends Node

@onready var CardManager: Node = $CardManager
@onready var MainMenu: Node2D = $MainMenu
@onready var MainButtons: VBoxContainer = $MainMenu/MainButtons
@onready var Credits: VBoxContainer = $MainMenu/Credits
@onready var OpenMenuButton: TextureButton = $OpenMenuButton
@onready var PlayCardsButton: TextureButton = $PlayCardsButton
@onready var Title: TextureRect = $MainMenu/Title
const CARD_SCENE = preload("uid://cgqekym10df1u")
const CARD_CONTAINER_SCENE = preload("uid://vmpq4admagaw")
var handCount = 6 # Number of cards in hand
var playerHand
var discardPile

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GoToMainMenu()

# Instantiate cards and add them to a cardContainer acting as the player hand
func SetupCards():
	playerHand = CARD_CONTAINER_SCENE.instantiate()
	CardManager.add_child(playerHand)
	playerHand.Setup({"name" = "Player Hand", 
					"position" = Vector2(GameVariables.screenSize.x/2, GameVariables.screenSize.y - playerHand.GetHeight()/2),
					"maxCardsInSelf" = handCount,
					"preStock" = 6,
					"scaleSelfX" = true,
					"scale" = .3,})

	var enemyHand1 = CARD_CONTAINER_SCENE.instantiate()
	CardManager.add_child(enemyHand1)
	enemyHand1.Setup({"name" = "Enemy Hand 1",
					"position" = Vector2(GameVariables.screenSize.x/2, enemyHand1.GetHeight()/2),
					"maxCardsInSelf" = handCount,
					"rotation" = PI,
					"canSelectCardsIn" = false,
					"preStock" = handCount,
					"faceDown" = true})
	
	var enemyHand2 = CARD_CONTAINER_SCENE.instantiate()
	CardManager.add_child(enemyHand2)
	enemyHand2.Setup({"name" = "Enemy Hand 2",
					"position" = Vector2(enemyHand2.GetHeight()/2, GameVariables.screenSize.y/2),
					"maxCardsInSelf" = handCount,
					"rotation" = PI/2,
					"canSelectCardsIn" = false,
					"preStock" = handCount,
					"faceDown" = true})
	
	var enemyHand3 = CARD_CONTAINER_SCENE.instantiate()
	CardManager.add_child(enemyHand3)
	enemyHand3.Setup({"name" = "Enemy Hand 3",
					"position" = Vector2(GameVariables.screenSize.x - enemyHand3.GetHeight()/2, GameVariables.screenSize.y/2),
					"maxCardsInSelf" = handCount,
					"rotation" = 3*PI/2,
					"canSelectCardsIn" = false,
					"preStock" = handCount,
					"faceDown" = true})
	
	discardPile = CARD_CONTAINER_SCENE.instantiate()
	discardPile.scale.x = 1
	CardManager.add_child(discardPile)
	discardPile.Setup({"name" = "Discard Pile",
					"position" = Vector2(GameVariables.screenSize.x/2, GameVariables.screenSize.y/2 - discardPile.GetHeight()/2),
					"maxCardsInSelf" = 52,
					"canSelectCardsIn" = false,
					"pile" = true,
					"scaleSelfX" = false,
					"scale" = .1,})

# Hide everything, remove cards/cardContainers from existence
func Cleanup():
	CleanupGame()
	TitleVisibility(false)
	MainButtonsVisibility(false)
	CreditsVisibility(false)
	ToMenuButtonVisibility(false)
	PlayCardsButtonVisibility(false)

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
	playerHand = null
	discardPile = null

func GoToMainMenu():
	Cleanup()
	MainButtonsVisibility(true)
	TitleVisibility(true)

func GoToPlay():
	Cleanup()
	ToMenuButtonVisibility(true)
	PlayCardsButtonVisibility(true)
	SetupCards()

func GoToCredits():
	Cleanup()
	CreditsVisibility(true)

func QuitGame():
	get_tree().quit()
	
func PlaceCards():
	var cardsSelectedCopy = CardManager.cardsSelected.duplicate()
	if !CheckViableHand(cardsSelectedCopy):
		for card in cardsSelectedCopy:
			CardManager.SelectCard(card, false)
		return
	for card in cardsSelectedCopy:
		CardManager.SelectCard(card, false)
		playerHand.DrawCardToContainer(discardPile, card)

func CheckViableHand(_cards):
	return true

func MainButtonsVisibility(visible):
	MainButtons.visible = visible

func ToMenuButtonVisibility(visible):
	OpenMenuButton.visible = visible

func CreditsVisibility(visible):
	Credits.visible = visible

func TitleVisibility(visible):
	Title.visible = visible

func PlayCardsButtonVisibility(visible):
	PlayCardsButton.visible = visible
