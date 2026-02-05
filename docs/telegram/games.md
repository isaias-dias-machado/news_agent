### [](#games)Games

Your bot can offer users **HTML5 games** to play solo or to compete against each other in groups and one-on-one chats. Create games via [@BotFather](https://t.me/botfather) using the */newgame* command. Please note that this kind of power requires responsibility: you will need to accept the terms for each game that your bots will be offering.

-   Games are a new type of content on Telegram, represented by the [Game](#game) and [InlineQueryResultGame](#inlinequeryresultgame) objects.
-   Once you've created a game via [BotFather](https://t.me/botfather), you can send games to chats as regular messages using the [sendGame](#sendgame) method, or use [inline mode](#inline-mode) with [InlineQueryResultGame](#inlinequeryresultgame).
-   If you send the game message without any buttons, it will automatically have a 'Play *GameName*' button. When this button is pressed, your bot gets a [CallbackQuery](#callbackquery) with the *game\_short\_name* of the requested game. You provide the correct URL for this particular user and the app opens the game in the in-app browser.
-   You can manually add multiple buttons to your game message. Please note that the first button in the first row **must always** launch the game, using the field *callback\_game* in [InlineKeyboardButton](#inlinekeyboardbutton). You can add extra buttons according to taste: e.g., for a description of the rules, or to open the game's official community.
-   To make your game more attractive, you can upload a GIF animation that demonstrates the game to the users via [BotFather](https://t.me/botfather) (see [Lumberjack](https://t.me/gamebot?game=lumberjack) for example).
-   A game message will also display high scores for the current chat. Use [setGameScore](#setgamescore) to post high scores to the chat with the game, add the *disable\_edit\_message* parameter to disable automatic update of the message with the current scoreboard.
-   Use [getGameHighScores](#getgamehighscores) to get data for in-game high score tables.
-   You can also add an extra [sharing button](/bots/games#sharing-your-game-to-telegram-chats) for users to share their best score to different chats.
-   For examples of what can be done using this new stuff, check the [@gamebot](https://t.me/gamebot) and [@gamee](https://t.me/gamee) bots.

#### [](#sendgame)sendGame

Use this method to send a game. On success, the sent [Message](#message) is returned.

Parameter

Type

Required

Description

business\_connection\_id

String

Optional

Unique identifier of the business connection on behalf of which the message will be sent

chat\_id

Integer

Yes

Unique identifier for the target chat. Games can't be sent to channel direct messages chats and channel chats.

message\_thread\_id

Integer

Optional

Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only

game\_short\_name

String

Yes

Short name of the game, serves as the unique identifier for the game. Set up your games via [@BotFather](https://t.me/botfather).

disable\_notification

Boolean

Optional

Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.

protect\_content

Boolean

Optional

Protects the contents of the sent message from forwarding and saving

allow\_paid\_broadcast

Boolean

Optional

Pass *True* to allow up to 1000 messages per second, ignoring [broadcasting limits](https://core.telegram.org/bots/faq#how-can-i-message-all-of-my-bot-39s-subscribers-at-once) for a fee of 0.1 Telegram Stars per message. The relevant Stars will be withdrawn from the bot's balance

message\_effect\_id

String

Optional

Unique identifier of the message effect to be added to the message; for private chats only

reply\_parameters

[ReplyParameters](#replyparameters)

Optional

Description of the message to reply to

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

Optional

A JSON-serialized object for an [inline keyboard](/bots/features#inline-keyboards). If empty, one 'Play game\_title' button will be shown. If not empty, the first button must launch the game.

#### [](#game)Game

This object represents a game. Use BotFather to create and edit games, their short names will act as unique identifiers.

Field

Type

Description

title

String

Title of the game

description

String

Description of the game

photo

Array of [PhotoSize](#photosize)

Photo that will be displayed in the game message in chats.

text

String

*Optional*. Brief description of the game or high scores included in the game message. Can be automatically edited to include current high scores for the game when the bot calls [setGameScore](#setgamescore), or manually edited using [editMessageText](#editmessagetext). 0-4096 characters.

text\_entities

Array of [MessageEntity](#messageentity)

*Optional*. Special entities that appear in *text*, such as usernames, URLs, bot commands, etc.

animation

[Animation](#animation)

*Optional*. Animation that will be displayed in the game message in chats. Upload via [BotFather](https://t.me/botfather)

#### [](#callbackgame)CallbackGame

A placeholder, currently holds no information. Use [BotFather](https://t.me/botfather) to set up your game.

#### [](#setgamescore)setGameScore

Use this method to set the score of the specified user in a game message. On success, if the message is not an inline message, the [Message](#message) is returned, otherwise *True* is returned. Returns an error, if the new score is not greater than the user's current score in the chat and *force* is *False*.

Parameter

Type

Required

Description

user\_id

Integer

Yes

User identifier

score

Integer

Yes

New score, must be non-negative

force

Boolean

Optional

Pass *True* if the high score is allowed to decrease. This can be useful when fixing mistakes or banning cheaters

disable\_edit\_message

Boolean

Optional

Pass *True* if the game message should not be automatically edited to include the current scoreboard

chat\_id

Integer

Optional

Required if *inline\_message\_id* is not specified. Unique identifier for the target chat

message\_id

Integer

Optional

Required if *inline\_message\_id* is not specified. Identifier of the sent message

inline\_message\_id

String

Optional

Required if *chat\_id* and *message\_id* are not specified. Identifier of the inline message

#### [](#getgamehighscores)getGameHighScores

Use this method to get data for high score tables. Will return the score of the specified user and several of their neighbors in a game. Returns an Array of [GameHighScore](#gamehighscore) objects.

> This method will currently return scores for the target user, plus two of their closest neighbors on each side. Will also return the top three users if the user and their neighbors are not among them. Please note that this behavior is subject to change.

Parameter

Type

Required

Description

user\_id

Integer

Yes

Target user id

chat\_id

Integer

Optional

Required if *inline\_message\_id* is not specified. Unique identifier for the target chat

message\_id

Integer

Optional

Required if *inline\_message\_id* is not specified. Identifier of the sent message

inline\_message\_id

String

Optional

Required if *chat\_id* and *message\_id* are not specified. Identifier of the inline message

#### [](#gamehighscore)GameHighScore

This object represents one row of the high scores table for a game.

Field

Type

Description

position

Integer

Position in high score table for the game

user

[User](#user)

User

score

Integer

Score

---

And that's about all we've got for now.  
If you've got any questions, please check out our [**Bot FAQ »**](/bots/faq)

##### Telegram

Telegram is a cloud-based mobile and desktop messaging app with a focus on security and speed.

##### [About](//telegram.org/faq)

-   [FAQ](//telegram.org/faq)
-   [Privacy](//telegram.org/privacy)
-   [Press](//telegram.org/press)

##### [Mobile Apps](//telegram.org/apps#mobile-apps)

-   [iPhone/iPad](//telegram.org/dl/ios)
-   [Android](//telegram.org/android)
-   [Mobile Web](//telegram.org/dl/web)

##### [Desktop Apps](//telegram.org/apps#desktop-apps)

-   [PC/Mac/Linux](//desktop.telegram.org/)
-   [macOS](//macos.telegram.org/)
-   [Web-browser](//telegram.org/dl/web)

##### [Platform](/)

-   [API](/api)
-   [Translations](//translations.telegram.org/)
-   [Instant View](//instantview.telegram.org/)

##### [About](//telegram.org/faq)

##### [Blog](//telegram.org/blog)

##### [Press](//telegram.org/press)

##### [Moderation](//telegram.org/moderation)
