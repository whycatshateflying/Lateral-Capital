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
	playerHand.name = "Player Hand"
	CardManager.add_child(playerHand)
	playerHand.position = Vector2(GameVariables.screenSize.x/2, GameVariables.screenSize.y - playerHand.GetHeight()/2)
	playerHand.SetMaxCards(handCount)

	for i in range(handCount):
		var card = CardManager.CreateCard()
		playerHand.TryAddCard(card)

	playerHand.AddScale(true, .3)

	var enemyHand = CARD_CONTAINER_SCENE.instantiate()
	enemyHand.name = "Enemy Hand"
	CardManager.add_child(enemyHand)
	enemyHand.position = Vector2(GameVariables.screenSize.x/2, enemyHand.GetHeight()/2)
	enemyHand.SetMaxCards(handCount)
	enemyHand.rotate(PI)
	enemyHand.canSelectCardsIn = false
	
	for i in range(handCount):
		var card = CardManager.CreateCard()
		enemyHand.TryAddCard(card)
		CardManager.FlipCard(card)
	
	discardPile = CARD_CONTAINER_SCENE.instantiate()
	discardPile.scale.x = 1
	discardPile.name = "Discard Pile"
	CardManager.add_child(discardPile)
	discardPile.position = Vector2(GameVariables.screenSize.x/2, GameVariables.screenSize.y/1.65 - playerHand.GetHeight()/2)
	discardPile.SetMaxCards(handCount)
	discardPile.canSelectCardsIn = false
	discardPile.pile = true
	discardPile.AddScale(false, .1)

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

func CheckViableHand(cards):
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
