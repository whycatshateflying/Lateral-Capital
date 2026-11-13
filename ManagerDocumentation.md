# Architecture of the managers
This guide aims to explain every function of the Manager nodes (at least at the time of writing, 11/12), and give a general gist of what the role of each manager is
## GameManager
GameManager is the main node that controls the flow of the game. Main menu, starting/stopping turns, telling the other systems where and when to do their thing is its whole job
So far the functions are pretty barebones
### "Normal" functions
These functions are what you'd expect a GameManager to do. Largest in scope and deals with talking to the other parts of the codebase
- _ready()
	- This is inherited from Node
		- At the start of the scene (think when the game boots up from the exe or debug project or whatever), this code runs
		- Currently it just sets up the main menu
- SetupCards()
	- This function is what's called when the game starts for the first time. Create the player and enemy hands, cards in decks, piles, etc
	- Currently for debugging purpose, it creates the player hand and fills it with cards
- Cleanup()
	- Removes all cards, containers, from the game, and hides all buttons and labels used for the menus
	- Used when the menu buttons are pressed or the pause menu is pressed
- CleanupGame()
	- Called by the Cleanup function, but will probably also be called when a game is stopped/started
	- Removes all cards, containers from the game
### "Group" functions
These functions are groups of visibility toggles used by the buttons for ease of grouping and consistency (say a button was added to the main menu. Instead of updating the code of everything that goes to the main menu, the GoToMainMenu function can be updated, and everything just works™)
- GoToMainMenu()
	- Cleans up everything
	- Toggles the visibility of everything contained in the main menu
		- MainButtons
		- Title
- GoToPlay()
	- Cleans up everything
	- Toggles the "to menu" button visibility
	- Calls SetupCards
- GoToCredits()
	- Cleans up everything
	- Toggles credits visibility
- QuitGame()
	- Doesn't actually group any other functions, but it quits the game, much like the other functions here transition to different scenes
	- If there is ever more that needs to happen to "properly" close the game, then it should go here
### "Nugget" functions
###### I'm doing this documentation I can name it what I want shutup
These functions are not really meant to be used on their own, and are only there so multiple places in the code don't have to worry about what individual paths to buttons and other components are
- MainButtonsVisibility(visible)
- ToMenuButtonVisibity(visible)
- CreditsVisibility(visible)
- TitleVisibility(visible)
## InputManager
InputManager was made to simplify the code in CardManager by handling the raw mouse input and how they interact with the cards/containers. Button signals also go here
### The "Big" functions
These directly handle the main two purposes of InputManager, which are taking in mouse/keyboard inputs and updating the mouse position
- _input(event)
	- Inherited by Node. Runs when a mouse event is fired, and calls HandleMouseEvents on it
	- Eventually if there's going to be keyboard input, there would be a seperate function for those events
- HandleMouseEvents(event)
	- Called every time a mouse event is fired, and calls the respective left/right/middle click functions
- UpdateMousePosition
	- CardManager calls this every frame to update the mouse position for card dragging
### "Helper" functions
While all of InputManager's functions are just helping elsewhere, these are more in the middle of the "function call tree", and called by the Big functions/used to help the Big functions do their job
- _process(delta)
	- Inherited from Node. Runs every frame, with delta being the time since last frame, in seconds
	- Currently just adds the time since the last mousedown for short/long press calculation
- HandleLeftClick(event)
	- Raycasts for a card and gives it to CardManager to handle (either in OnMousePress or OnMouseRelease)
- HandleMiddleClick(event)
	- DEBUG FUNCTION primarily to test facedown cards and for insight for ai. Not intended to stay in the final release
	- Raycasts for a card and flips it over via CardManager
- RaycastCheck(mask)
	- Gotta be so fr, I do not know how this function works. Copied from the card tutorial and have never had a problem with it
	- Raycasts from the mouse position to find any scenes beneath it matching the mask
	- Masks are declared at the top of InputManager and are different for cards, containers, and other things that need to be interacted with
- GetCardWithHighestZ(cards)
	- Raycast finds a list of Card scenes underneath the mouse, but from there it's annoying to get the highest Z card, which is the expected behavior, so that's what this function does
### Signals
The rest of the functions in here are for incoming signals. Whenever a button on the menu is pressed, that function is called. These run the Group functions from GameManager
- _on_play_button_pressed()
- _on_exit_button_pressed()
- _on_credits_button_pressed()
- _on_back_from_credits_button_pressed()
- _on_open_menu_button_pressed()
## CardManager
Anything to do with a card probably lives in CardManager, as opposed to the cards. The tutorial we used initially recommended this as it would lead to less spaghetti to have everything in one place. The spaghetti is only mildly contained.

### "Handling" functions
These function just handle being hovered, clicked, or spawned, calling the other base functions as needed
- OnCardSpawn(card)
	- When a card is spawned, it calls this function to set up the variables and make sure it's added to allCards and the Z indexes are correct
	- In its entirety, it
		- Connects the signals of hovering cards
		- Adds the card to allCards
		- Sets the scale of the card
		- Updates the Z indexes
		- Sets the value and suit (currently just random)
- OnMousePress(card)
	- card is whatever the mouse press was over
	- I debating a long time whether or not this goes in InputManager but I think I'm sure
	- Deals with picking up/putting down cards, and rescales the card to be normal size
	- Also sets the MousePress time to 0, for later checking by OnMouseRelease
- OnMouseRelease(_card)
	- Based on the duration of the mouse press, decide whether to put down a card or toggle grab it
	- Also rehover any card that would normally have been unhovered
- OnHoverOverCard
	- When a card is being hovered over, this function is called, which highlights a card
- OnHoveredOffCard
	- When a card is being hovered off, this function is called, which ends the highlight, and maybe hovers another card directly after
### The "Boring" functions
I call them the boring functions because they just do their thing and aren't ever interesting or very widely applicable
- _process(_delta)
	- Inherited from Node and run every frame. Currently the only thing that happens every frame here is updating the mouse position (held in InputManager) and moving cards in UpdateMousePosAndMoveCards
- ConnectCardSignals(card)
	- Sets up the custom signals for being hovered and unhovered of the card
- UpdateMousePosAndMoveCards()
	- Called every frame by _process
	- It uhh.... Updates the mouse position in InputManager and moves any cards that need to be moved
### Do something to a card
These functions directly modify something about a card, like moving it or scaling it or setting a value
- UpdateCardPosition(card, delta)
	- Snap a card based on a delta
	- Used for card dragging cause otherwise a card would snap to the mouse position when you picked it up
- AnimateCardToPosition(card, cardPosition, speed = .1)
	- Smoothly moves a card to position for speed seconds
- UpdateZIndex(card, index = null)
	- Sets a card to the appropriate index, or if none is given, instead to the position in the allCards array (resetting the index)
- UpdateAllZIndexes()
	- Calls UpdateZIndex on all cards in allCards
- FlipCard(card, up = !card.faceup)
	- Flips a card such that a certain face is up, or if no side is given, the opposite to how it is right now
- SetCard(card, value = 1, suit = GameVariables.suits.SPADE)
	- Sets a card's suit and value to either the default (Ace of Spades) or whatever value is given
- ScaleCard(card, newScale)
	- Scales a card, taking into account GameVariables.GAME_SCALE
- UnloadCard(card)
	- Removes the card from the game, which involves removing it from allCards, any containers it might be in, and calling queue_free() on it
- UnloadCardContainer(container)
	- Removes the cardContainer from the game, which is basically the same process as cards
### The other functions
These functions don't have a unifying theme, but they feel like they go together and they're the only ones left
- StartDrag(card)
	- Sets cardBeingDragged to card and make sure it's first in the Z index
- EndDrag()
	- Stops dragging whatever card is being dragged, placing it in an open cardContainer below, if applicable
- HighlightCard(card, hovered)
	- Handles highlighting and unhighlighting a card when its hovered
	- "Highlighting" being the slight increase in size when you hover it