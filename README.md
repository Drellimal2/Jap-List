# Jap-Lists

Jap-Lists is an application that allows Japanese learners create decks of study cards which they can set kanji, kana and english translations. It is a mobile versionn of traditional flash cards with the added benefit of accessing other learners public lists. It is a great way to learn and share new study material.

### Features
A cool feature of JapList is some functionality can be used without even logging in/ signing up.

Without an account a user can:
  - Create NEW decks and store them on the device.
  - Add NEW cards to a created deck.
  - Take a deck review (self-quiz)
  - Delete already created decks.
   
Though you can do SO MUCH without an account, the real funn is when you are logged in. When you are logged in you can do all of the above plus:
  - Access all your saved public decks
  - Access all public decks
  - Save a public deck to your decks.
  - Make a deck public for others to use.


> JapLists is almost as fun to use as it was to make.
> It replaces stacks of flash cards previously used for self study,
> saving paper and the environment.
> It's also very easy for me to get new lists without creating them 
> through the discover tab.
> \- Dane Miller (JapLists Developer / User)


### How to Use

##### 1 . Running the app
1. After installing the app simply tap the icon with the label JapLists to start the app
2. On first launch you should be presented with a dialog welcoming you and suggesting you to create a deck.
##### 2 . Creating a deck
1. Click the '+' icon at the top-right corner of the screen. This should pop up a new deck screen after which a hint should be displayed.
2. Click on the App logo under the title cover to change the image. This will open an image picker which you will use to choose the new icon.
3. After an image is picked or if you are satisfied with the default image, enter a title for the deck.
4. (Optional) After the title you can replace the text in the description box.
5. Click 'Save'
6. Done. We should now be back at 'My Decks' with the new deck shown in the list.

##### 3. Viewing a Deck
1. In 'My Decks' when you click on any deck you will be taken to a new screen which shows a more detailed view of the deck.
2. In that view you will see the cover at the top-left under the navbar. With the title and description to the right of it.
3. Under the cover and details you will have several buttons to Review, Delete or Save(when we log in)
4. Under the Buttons you will see a title 'Cards List' and a '+' followed by a list of cards(Kanji - TOP, Kana - MIDDLE, translation - BOTTOM) N.B If kanji or kana value is empty then it will not be shown in the list.
5. Clicking the '+' will take you to the add card page.
##### 4. Adding a Card
1. Clicking the '+' will take you to the add card page.
2. On this page you will have to fill the kana and/or kanji field AND the translation. i.e. Atleast one Japanese field and the translation field.
3. When you are satisfied with the information you are free to click 'Save'.
4. Saving the card will take you back to the Deck page.
##### 5. Reviewing a Deck
1. After we added a few cards it's time to review our deck.
2. On a deck page there is a review button which should be right below the cover image.
3. Clicking that button will take you to the review page.
4. Note if you have no saved cards in that deck, an alert will pop up that will redirect you back to the deck page.
5. If you have cards saved they you will see one card at a time with the Japanese on one side and the translation on the next.
6. To flip a card just simply tap it.
7. NB: You can see your progress via the progress bar at the top
8. When you are done reviewing tap the 'X' at the top to exit.
##### 6. Deleting a card
1. In the deck view simply swipe left on the desired card row will initiate the deletion process.
2. A dialog should be shown asking if you are sure. 
3. Clicking 'Yes, I'm Sure' will delete the card.
4. NB: This is a local feature only
##### 7. Deleting a deck
1. In the deck view click the delete button to start the process.
2. You will then be prompted if you are sure.
3. Confirming will delete the deck and redirect you back to 'My Decks'
##### 8. Editting a deck
Maybe you don't want to delete a deck. Maybe you just want to edit the title.
1. In the deck view click the edit button to start the process.
2. It will carry you to the edit deck screen where you modify the values
3. When you are finished click save and the changes will save.
4. After the deck is updated we will be redirected back to the deck view.

### Logged in Functionality
Up until this point everything we were doing we were not logged in. It was fun and we can still do it after we are logged in.
##### 1. Logging in
1. If you are not logged in and you click on the discover tab you will be presented with a button within a red dot on the screen.
2. Click the button and 2 options will be presented : Login with Google or Login with email
3. Choosing either option will take you through the appropriate process then return to the discover screen where you will see all public decks.
##### 2. Viewing Public Decks
1. After logging in the discover screen will show you all the publicly available decks.
2. Clicking on a deck will take you to a familiar screen the Deck View Screen.
3. Here you can see the title, description and Cover as well as a list of cards
##### 3. Reviewing a Public Deck
This is the same process as before you were logged in.
##### 4. Saving a public deck
Saving a public deck will add the deck to your 'My Decks' page.
1. On the deck view page of a public deck you will see a button labelled 'Save' beside the 'Review' button.
2. Clicking it will start the save process and when it is completed you will see the button change to 'Unsave'
3. Going to 'My Decks' will now have the newly saved deck under 'Public Decks'
##### 5. Unsaving a deck
Unsaving a public deck will remove the deck from your 'My Decks' page.
1. On the deck view page of a public deck that you have saved you will see a button labelled 'Unsave' beside the 'Review' button.
2. Clicking it will prompt you warning the consequences
3. Accepting the consequences will lead to the removal of the selected deck from your saved decks.
##### 6. Uploading a deck
1. Once we are logged in the new/edit deck screens provide us with an option to save and upload.
2. This should automatically update changes like addition of cards etc.
##### 7. Logging Out
Logging out will remove all the saved public decks as well as remove the ability to discover new lists
1. Once logged in, on the main screen (either 'My Decks' or 'Discover') at the top left corner you will see a red 'Logout' button.
2. Clicking the button will prompt the user asking if they are sure.
3. Accepting this will log us out and return to the not logged in state.

### What's New
Since the first submitted version the following features have been added :-
- Logout
- Connectivity Checks
- Network Activity Indicators
- Minor bug fixes and code improvements.

















