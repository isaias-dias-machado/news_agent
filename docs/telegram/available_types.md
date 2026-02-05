### [](#available-types)Available types

All types used in the Bot API responses are represented as JSON-objects.

It is safe to use 32-bit signed integers for storing all **Integer** fields unless otherwise noted.

> **Optional** fields may be not returned when irrelevant.

#### [](#user)User

This object represents a Telegram user or bot.

Field

Type

Description

id

Integer

Unique identifier for this user or bot. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier.

is\_bot

Boolean

*True*, if this user is a bot

first\_name

String

User's or bot's first name

last\_name

String

*Optional*. User's or bot's last name

username

String

*Optional*. User's or bot's username

language\_code

String

*Optional*. [IETF language tag](https://en.wikipedia.org/wiki/IETF_language_tag) of the user's language

is\_premium

True

*Optional*. *True*, if this user is a Telegram Premium user

added\_to\_attachment\_menu

True

*Optional*. *True*, if this user added the bot to the attachment menu

can\_join\_groups

Boolean

*Optional*. *True*, if the bot can be invited to groups. Returned only in [getMe](#getme).

can\_read\_all\_group\_messages

Boolean

*Optional*. *True*, if [privacy mode](/bots/features#privacy-mode) is disabled for the bot. Returned only in [getMe](#getme).

supports\_inline\_queries

Boolean

*Optional*. *True*, if the bot supports inline queries. Returned only in [getMe](#getme).

can\_connect\_to\_business

Boolean

*Optional*. *True*, if the bot can be connected to a Telegram Business account to receive its messages. Returned only in [getMe](#getme).

has\_main\_web\_app

Boolean

*Optional*. *True*, if the bot has a main Web App. Returned only in [getMe](#getme).

has\_topics\_enabled

Boolean

*Optional*. *True*, if the bot has forum topic mode enabled in private chats. Returned only in [getMe](#getme).

#### [](#chat)Chat

This object represents a chat.

Field

Type

Description

id

Integer

Unique identifier for this chat. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this identifier.

type

String

Type of the chat, can be either “private”, “group”, “supergroup” or “channel”

title

String

*Optional*. Title, for supergroups, channels and group chats

username

String

*Optional*. Username, for private chats, supergroups and channels if available

first\_name

String

*Optional*. First name of the other party in a private chat

last\_name

String

*Optional*. Last name of the other party in a private chat

is\_forum

True

*Optional*. *True*, if the supergroup chat is a forum (has [topics](https://telegram.org/blog/topics-in-groups-collectible-usernames#topics-in-groups) enabled)

is\_direct\_messages

True

*Optional*. *True*, if the chat is the direct messages chat of a channel

#### [](#chatfullinfo)ChatFullInfo

This object contains full information about a chat.

Field

Type

Description

id

Integer

Unique identifier for this chat. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this identifier.

type

String

Type of the chat, can be either “private”, “group”, “supergroup” or “channel”

title

String

*Optional*. Title, for supergroups, channels and group chats

username

String

*Optional*. Username, for private chats, supergroups and channels if available

first\_name

String

*Optional*. First name of the other party in a private chat

last\_name

String

*Optional*. Last name of the other party in a private chat

is\_forum

True

*Optional*. *True*, if the supergroup chat is a forum (has [topics](https://telegram.org/blog/topics-in-groups-collectible-usernames#topics-in-groups) enabled)

is\_direct\_messages

True

*Optional*. *True*, if the chat is the direct messages chat of a channel

accent\_color\_id

Integer

Identifier of the accent color for the chat name and backgrounds of the chat photo, reply header, and link preview. See [accent colors](#accent-colors) for more details.

max\_reaction\_count

Integer

The maximum number of reactions that can be set on a message in the chat

photo

[ChatPhoto](#chatphoto)

*Optional*. Chat photo

active\_usernames

Array of String

*Optional*. If non-empty, the list of all [active chat usernames](https://telegram.org/blog/topics-in-groups-collectible-usernames#collectible-usernames); for private chats, supergroups and channels

birthdate

[Birthdate](#birthdate)

*Optional*. For private chats, the date of birth of the user

business\_intro

[BusinessIntro](#businessintro)

*Optional*. For private chats with business accounts, the intro of the business

business\_location

[BusinessLocation](#businesslocation)

*Optional*. For private chats with business accounts, the location of the business

business\_opening\_hours

[BusinessOpeningHours](#businessopeninghours)

*Optional*. For private chats with business accounts, the opening hours of the business

personal\_chat

[Chat](#chat)

*Optional*. For private chats, the personal channel of the user

parent\_chat

[Chat](#chat)

*Optional*. Information about the corresponding channel chat; for direct messages chats only

available\_reactions

Array of [ReactionType](#reactiontype)

*Optional*. List of available reactions allowed in the chat. If omitted, then all [emoji reactions](#reactiontypeemoji) are allowed.

background\_custom\_emoji\_id

String

*Optional*. Custom emoji identifier of the emoji chosen by the chat for the reply header and link preview background

profile\_accent\_color\_id

Integer

*Optional*. Identifier of the accent color for the chat's profile background. See [profile accent colors](#profile-accent-colors) for more details.

profile\_background\_custom\_emoji\_id

String

*Optional*. Custom emoji identifier of the emoji chosen by the chat for its profile background

emoji\_status\_custom\_emoji\_id

String

*Optional*. Custom emoji identifier of the emoji status of the chat or the other party in a private chat

emoji\_status\_expiration\_date

Integer

*Optional*. Expiration date of the emoji status of the chat or the other party in a private chat, in Unix time, if any

bio

String

*Optional*. Bio of the other party in a private chat

has\_private\_forwards

True

*Optional*. *True*, if privacy settings of the other party in the private chat allows to use `tg://user?id=<user_id>` links only in chats with the user

has\_restricted\_voice\_and\_video\_messages

True

*Optional*. *True*, if the privacy settings of the other party restrict sending voice and video note messages in the private chat

join\_to\_send\_messages

True

*Optional*. *True*, if users need to join the supergroup before they can send messages

join\_by\_request

True

*Optional*. *True*, if all users directly joining the supergroup without using an invite link need to be approved by supergroup administrators

description

String

*Optional*. Description, for groups, supergroups and channel chats

invite\_link

String

*Optional*. Primary invite link, for groups, supergroups and channel chats

pinned\_message

[Message](#message)

*Optional*. The most recent pinned message (by sending date)

permissions

[ChatPermissions](#chatpermissions)

*Optional*. Default chat member permissions, for groups and supergroups

accepted\_gift\_types

[AcceptedGiftTypes](#acceptedgifttypes)

Information about types of gifts that are accepted by the chat or by the corresponding user for private chats

can\_send\_paid\_media

True

*Optional*. *True*, if paid media messages can be sent or forwarded to the channel chat. The field is available only for channel chats.

slow\_mode\_delay

Integer

*Optional*. For supergroups, the minimum allowed delay between consecutive messages sent by each unprivileged user; in seconds

unrestrict\_boost\_count

Integer

*Optional*. For supergroups, the minimum number of boosts that a non-administrator user needs to add in order to ignore slow mode and chat permissions

message\_auto\_delete\_time

Integer

*Optional*. The time after which all messages sent to the chat will be automatically deleted; in seconds

has\_aggressive\_anti\_spam\_enabled

True

*Optional*. *True*, if aggressive anti-spam checks are enabled in the supergroup. The field is only available to chat administrators.

has\_hidden\_members

True

*Optional*. *True*, if non-administrators can only get the list of bots and administrators in the chat

has\_protected\_content

True

*Optional*. *True*, if messages from the chat can't be forwarded to other chats

has\_visible\_history

True

*Optional*. *True*, if new chat members will have access to old messages; available only to chat administrators

sticker\_set\_name

String

*Optional*. For supergroups, name of the group sticker set

can\_set\_sticker\_set

True

*Optional*. *True*, if the bot can change the group sticker set

custom\_emoji\_sticker\_set\_name

String

*Optional*. For supergroups, the name of the group's custom emoji sticker set. Custom emoji from this set can be used by all users and bots in the group.

linked\_chat\_id

Integer

*Optional*. Unique identifier for the linked chat, i.e. the discussion group identifier for a channel and vice versa; for supergroups and channel chats. This identifier may be greater than 32 bits and some programming languages may have difficulty/silent defects in interpreting it. But it is smaller than 52 bits, so a signed 64 bit integer or double-precision float type are safe for storing this identifier.

location

[ChatLocation](#chatlocation)

*Optional*. For supergroups, the location to which the supergroup is connected

rating

[UserRating](#userrating)

*Optional*. For private chats, the rating of the user if any

unique\_gift\_colors

[UniqueGiftColors](#uniquegiftcolors)

*Optional*. The color scheme based on a unique gift that must be used for the chat's name, message replies and link previews

paid\_message\_star\_count

Integer

*Optional*. The number of Telegram Stars a general user have to pay to send a message to the chat

#### [](#message)Message

This object represents a message.

Field

Type

Description

message\_id

Integer

Unique message identifier inside this chat. In specific instances (e.g., message containing a video sent to a big chat), the server might automatically schedule a message instead of sending it immediately. In such cases, this field will be 0 and the relevant message will be unusable until it is actually sent

message\_thread\_id

Integer

*Optional*. Unique identifier of a message thread or forum topic to which the message belongs; for supergroups and private chats only

direct\_messages\_topic

[DirectMessagesTopic](#directmessagestopic)

*Optional*. Information about the direct messages chat topic that contains the message

from

[User](#user)

*Optional*. Sender of the message; may be empty for messages sent to channels. For backward compatibility, if the message was sent on behalf of a chat, the field contains a fake sender user in non-channel chats

sender\_chat

[Chat](#chat)

*Optional*. Sender of the message when sent on behalf of a chat. For example, the supergroup itself for messages sent by its anonymous administrators or a linked channel for messages automatically forwarded to the channel's discussion group. For backward compatibility, if the message was sent on behalf of a chat, the field *from* contains a fake sender user in non-channel chats.

sender\_boost\_count

Integer

*Optional*. If the sender of the message boosted the chat, the number of boosts added by the user

sender\_business\_bot

[User](#user)

*Optional*. The bot that actually sent the message on behalf of the business account. Available only for outgoing messages sent on behalf of the connected business account.

date

Integer

Date the message was sent in Unix time. It is always a positive number, representing a valid date.

business\_connection\_id

String

*Optional*. Unique identifier of the business connection from which the message was received. If non-empty, the message belongs to a chat of the corresponding business account that is independent from any potential bot chat which might share the same identifier.

chat

[Chat](#chat)

Chat the message belongs to

forward\_origin

[MessageOrigin](#messageorigin)

*Optional*. Information about the original message for forwarded messages

is\_topic\_message

True

*Optional*. *True*, if the message is sent to a topic in a forum supergroup or a private chat with the bot

is\_automatic\_forward

True

*Optional*. *True*, if the message is a channel post that was automatically forwarded to the connected discussion group

reply\_to\_message

[Message](#message)

*Optional*. For replies in the same chat and message thread, the original message. Note that the [Message](#message) object in this field will not contain further *reply\_to\_message* fields even if it itself is a reply.

external\_reply

[ExternalReplyInfo](#externalreplyinfo)

*Optional*. Information about the message that is being replied to, which may come from another chat or forum topic

quote

[TextQuote](#textquote)

*Optional*. For replies that quote part of the original message, the quoted part of the message

reply\_to\_story

[Story](#story)

*Optional*. For replies to a story, the original story

reply\_to\_checklist\_task\_id

Integer

*Optional*. Identifier of the specific checklist task that is being replied to

via\_bot

[User](#user)

*Optional*. Bot through which the message was sent

edit\_date

Integer

*Optional*. Date the message was last edited in Unix time

has\_protected\_content

True

*Optional*. *True*, if the message can't be forwarded

is\_from\_offline

True

*Optional*. *True*, if the message was sent by an implicit action, for example, as an away or a greeting business message, or as a scheduled message

is\_paid\_post

True

*Optional*. *True*, if the message is a paid post. Note that such posts must not be deleted for 24 hours to receive the payment and can't be edited.

media\_group\_id

String

*Optional*. The unique identifier of a media message group this message belongs to

author\_signature

String

*Optional*. Signature of the post author for messages in channels, or the custom title of an anonymous group administrator

paid\_star\_count

Integer

*Optional*. The number of Telegram Stars that were paid by the sender of the message to send it

text

String

*Optional*. For text messages, the actual UTF-8 text of the message

entities

Array of [MessageEntity](#messageentity)

*Optional*. For text messages, special entities like usernames, URLs, bot commands, etc. that appear in the text

link\_preview\_options

[LinkPreviewOptions](#linkpreviewoptions)

*Optional*. Options used for link preview generation for the message, if it is a text message and link preview options were changed

suggested\_post\_info

[SuggestedPostInfo](#suggestedpostinfo)

*Optional*. Information about suggested post parameters if the message is a suggested post in a channel direct messages chat. If the message is an approved or declined suggested post, then it can't be edited.

effect\_id

String

*Optional*. Unique identifier of the message effect added to the message

animation

[Animation](#animation)

*Optional*. Message is an animation, information about the animation. For backward compatibility, when this field is set, the *document* field will also be set

audio

[Audio](#audio)

*Optional*. Message is an audio file, information about the file

document

[Document](#document)

*Optional*. Message is a general file, information about the file

paid\_media

[PaidMediaInfo](#paidmediainfo)

*Optional*. Message contains paid media; information about the paid media

photo

Array of [PhotoSize](#photosize)

*Optional*. Message is a photo, available sizes of the photo

sticker

[Sticker](#sticker)

*Optional*. Message is a sticker, information about the sticker

story

[Story](#story)

*Optional*. Message is a forwarded story

video

[Video](#video)

*Optional*. Message is a video, information about the video

video\_note

[VideoNote](#videonote)

*Optional*. Message is a [video note](https://telegram.org/blog/video-messages-and-telescope), information about the video message

voice

[Voice](#voice)

*Optional*. Message is a voice message, information about the file

caption

String

*Optional*. Caption for the animation, audio, document, paid media, photo, video or voice

caption\_entities

Array of [MessageEntity](#messageentity)

*Optional*. For messages with a caption, special entities like usernames, URLs, bot commands, etc. that appear in the caption

show\_caption\_above\_media

True

*Optional*. *True*, if the caption must be shown above the message media

has\_media\_spoiler

True

*Optional*. *True*, if the message media is covered by a spoiler animation

checklist

[Checklist](#checklist)

*Optional*. Message is a checklist

contact

[Contact](#contact)

*Optional*. Message is a shared contact, information about the contact

dice

[Dice](#dice)

*Optional*. Message is a dice with random value

game

[Game](#game)

*Optional*. Message is a game, information about the game. [More about games »](#games)

poll

[Poll](#poll)

*Optional*. Message is a native poll, information about the poll

venue

[Venue](#venue)

*Optional*. Message is a venue, information about the venue. For backward compatibility, when this field is set, the *location* field will also be set

location

[Location](#location)

*Optional*. Message is a shared location, information about the location

new\_chat\_members

Array of [User](#user)

*Optional*. New members that were added to the group or supergroup and information about them (the bot itself may be one of these members)

left\_chat\_member

[User](#user)

*Optional*. A member was removed from the group, information about them (this member may be the bot itself)

new\_chat\_title

String

*Optional*. A chat title was changed to this value

new\_chat\_photo

Array of [PhotoSize](#photosize)

*Optional*. A chat photo was change to this value

delete\_chat\_photo

True

*Optional*. Service message: the chat photo was deleted

group\_chat\_created

True

*Optional*. Service message: the group has been created

supergroup\_chat\_created

True

*Optional*. Service message: the supergroup has been created. This field can't be received in a message coming through updates, because bot can't be a member of a supergroup when it is created. It can only be found in reply\_to\_message if someone replies to a very first message in a directly created supergroup.

channel\_chat\_created

True

*Optional*. Service message: the channel has been created. This field can't be received in a message coming through updates, because bot can't be a member of a channel when it is created. It can only be found in reply\_to\_message if someone replies to a very first message in a channel.

message\_auto\_delete\_timer\_changed

[MessageAutoDeleteTimerChanged](#messageautodeletetimerchanged)

*Optional*. Service message: auto-delete timer settings changed in the chat

migrate\_to\_chat\_id

Integer

*Optional*. The group has been migrated to a supergroup with the specified identifier. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this identifier.

migrate\_from\_chat\_id

Integer

*Optional*. The supergroup has been migrated from a group with the specified identifier. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this identifier.

pinned\_message

[MaybeInaccessibleMessage](#maybeinaccessiblemessage)

*Optional*. Specified message was pinned. Note that the [Message](#message) object in this field will not contain further *reply\_to\_message* fields even if it itself is a reply.

invoice

[Invoice](#invoice)

*Optional*. Message is an invoice for a [payment](#payments), information about the invoice. [More about payments »](#payments)

successful\_payment

[SuccessfulPayment](#successfulpayment)

*Optional*. Message is a service message about a successful payment, information about the payment. [More about payments »](#payments)

refunded\_payment

[RefundedPayment](#refundedpayment)

*Optional*. Message is a service message about a refunded payment, information about the payment. [More about payments »](#payments)

users\_shared

[UsersShared](#usersshared)

*Optional*. Service message: users were shared with the bot

chat\_shared

[ChatShared](#chatshared)

*Optional*. Service message: a chat was shared with the bot

gift

[GiftInfo](#giftinfo)

*Optional*. Service message: a regular gift was sent or received

unique\_gift

[UniqueGiftInfo](#uniquegiftinfo)

*Optional*. Service message: a unique gift was sent or received

gift\_upgrade\_sent

[GiftInfo](#giftinfo)

*Optional*. Service message: upgrade of a gift was purchased after the gift was sent

connected\_website

String

*Optional*. The domain name of the website on which the user has logged in. [More about Telegram Login »](/widgets/login)

write\_access\_allowed

[WriteAccessAllowed](#writeaccessallowed)

*Optional*. Service message: the user allowed the bot to write messages after adding it to the attachment or side menu, launching a Web App from a link, or accepting an explicit request from a Web App sent by the method [requestWriteAccess](/bots/webapps#initializing-mini-apps)

passport\_data

[PassportData](#passportdata)

*Optional*. Telegram Passport data

proximity\_alert\_triggered

[ProximityAlertTriggered](#proximityalerttriggered)

*Optional*. Service message. A user in the chat triggered another user's proximity alert while sharing Live Location.

boost\_added

[ChatBoostAdded](#chatboostadded)

*Optional*. Service message: user boosted the chat

chat\_background\_set

[ChatBackground](#chatbackground)

*Optional*. Service message: chat background set

checklist\_tasks\_done

[ChecklistTasksDone](#checklisttasksdone)

*Optional*. Service message: some tasks in a checklist were marked as done or not done

checklist\_tasks\_added

[ChecklistTasksAdded](#checklisttasksadded)

*Optional*. Service message: tasks were added to a checklist

direct\_message\_price\_changed

[DirectMessagePriceChanged](#directmessagepricechanged)

*Optional*. Service message: the price for paid messages in the corresponding direct messages chat of a channel has changed

forum\_topic\_created

[ForumTopicCreated](#forumtopiccreated)

*Optional*. Service message: forum topic created

forum\_topic\_edited

[ForumTopicEdited](#forumtopicedited)

*Optional*. Service message: forum topic edited

forum\_topic\_closed

[ForumTopicClosed](#forumtopicclosed)

*Optional*. Service message: forum topic closed

forum\_topic\_reopened

[ForumTopicReopened](#forumtopicreopened)

*Optional*. Service message: forum topic reopened

general\_forum\_topic\_hidden

[GeneralForumTopicHidden](#generalforumtopichidden)

*Optional*. Service message: the 'General' forum topic hidden

general\_forum\_topic\_unhidden

[GeneralForumTopicUnhidden](#generalforumtopicunhidden)

*Optional*. Service message: the 'General' forum topic unhidden

giveaway\_created

[GiveawayCreated](#giveawaycreated)

*Optional*. Service message: a scheduled giveaway was created

giveaway

[Giveaway](#giveaway)

*Optional*. The message is a scheduled giveaway message

giveaway\_winners

[GiveawayWinners](#giveawaywinners)

*Optional*. A giveaway with public winners was completed

giveaway\_completed

[GiveawayCompleted](#giveawaycompleted)

*Optional*. Service message: a giveaway without public winners was completed

paid\_message\_price\_changed

[PaidMessagePriceChanged](#paidmessagepricechanged)

*Optional*. Service message: the price for paid messages has changed in the chat

suggested\_post\_approved

[SuggestedPostApproved](#suggestedpostapproved)

*Optional*. Service message: a suggested post was approved

suggested\_post\_approval\_failed

[SuggestedPostApprovalFailed](#suggestedpostapprovalfailed)

*Optional*. Service message: approval of a suggested post has failed

suggested\_post\_declined

[SuggestedPostDeclined](#suggestedpostdeclined)

*Optional*. Service message: a suggested post was declined

suggested\_post\_paid

[SuggestedPostPaid](#suggestedpostpaid)

*Optional*. Service message: payment for a suggested post was received

suggested\_post\_refunded

[SuggestedPostRefunded](#suggestedpostrefunded)

*Optional*. Service message: payment for a suggested post was refunded

video\_chat\_scheduled

[VideoChatScheduled](#videochatscheduled)

*Optional*. Service message: video chat scheduled

video\_chat\_started

[VideoChatStarted](#videochatstarted)

*Optional*. Service message: video chat started

video\_chat\_ended

[VideoChatEnded](#videochatended)

*Optional*. Service message: video chat ended

video\_chat\_participants\_invited

[VideoChatParticipantsInvited](#videochatparticipantsinvited)

*Optional*. Service message: new participants invited to a video chat

web\_app\_data

[WebAppData](#webappdata)

*Optional*. Service message: data sent by a Web App

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. Inline keyboard attached to the message. `login_url` buttons are represented as ordinary `url` buttons.

#### [](#messageid)MessageId

This object represents a unique message identifier.

Field

Type

Description

message\_id

Integer

Unique message identifier. In specific instances (e.g., message containing a video sent to a big chat), the server might automatically schedule a message instead of sending it immediately. In such cases, this field will be 0 and the relevant message will be unusable until it is actually sent

#### [](#inaccessiblemessage)InaccessibleMessage

This object describes a message that was deleted or is otherwise inaccessible to the bot.

Field

Type

Description

chat

[Chat](#chat)

Chat the message belonged to

message\_id

Integer

Unique message identifier inside the chat

date

Integer

Always 0. The field can be used to differentiate regular and inaccessible messages.

#### [](#maybeinaccessiblemessage)MaybeInaccessibleMessage

This object describes a message that can be inaccessible to the bot. It can be one of

-   [Message](#message)
-   [InaccessibleMessage](#inaccessiblemessage)

#### [](#messageentity)MessageEntity

This object represents one special entity in a text message. For example, hashtags, usernames, URLs, etc.

Field

Type

Description

type

String

Type of the entity. Currently, can be “mention” (`@username`), “hashtag” (`#hashtag` or `#hashtag@chatusername`), “cashtag” (`$USD` or `$USD@chatusername`), “bot\_command” (`/start@jobs_bot`), “url” (`https://telegram.org`), “email” (`do-not-reply@telegram.org`), “phone\_number” (`+1-212-555-0123`), “bold” (**bold text**), “italic” (*italic text*), “underline” (underlined text), “strikethrough” (strikethrough text), “spoiler” (spoiler message), “blockquote” (block quotation), “expandable\_blockquote” (collapsed-by-default block quotation), “code” (monowidth string), “pre” (monowidth block), “text\_link” (for clickable text URLs), “text\_mention” (for users [without usernames](https://telegram.org/blog/edit#new-mentions)), “custom\_emoji” (for inline custom emoji stickers)

offset

Integer

Offset in [UTF-16 code units](/api/entities#entity-length) to the start of the entity

length

Integer

Length of the entity in [UTF-16 code units](/api/entities#entity-length)

url

String

*Optional*. For “text\_link” only, URL that will be opened after user taps on the text

user

[User](#user)

*Optional*. For “text\_mention” only, the mentioned user

language

String

*Optional*. For “pre” only, the programming language of the entity text

custom\_emoji\_id

String

*Optional*. For “custom\_emoji” only, unique identifier of the custom emoji. Use [getCustomEmojiStickers](#getcustomemojistickers) to get full information about the sticker

#### [](#textquote)TextQuote

This object contains information about the quoted part of a message that is replied to by the given message.

Field

Type

Description

text

String

Text of the quoted part of a message that is replied to by the given message

entities

Array of [MessageEntity](#messageentity)

*Optional*. Special entities that appear in the quote. Currently, only *bold*, *italic*, *underline*, *strikethrough*, *spoiler*, and *custom\_emoji* entities are kept in quotes.

position

Integer

Approximate quote position in the original message in UTF-16 code units as specified by the sender

is\_manual

True

*Optional*. *True*, if the quote was chosen manually by the message sender. Otherwise, the quote was added automatically by the server.

#### [](#externalreplyinfo)ExternalReplyInfo

This object contains information about a message that is being replied to, which may come from another chat or forum topic.

Field

Type

Description

origin

[MessageOrigin](#messageorigin)

Origin of the message replied to by the given message

chat

[Chat](#chat)

*Optional*. Chat the original message belongs to. Available only if the chat is a supergroup or a channel.

message\_id

Integer

*Optional*. Unique message identifier inside the original chat. Available only if the original chat is a supergroup or a channel.

link\_preview\_options

[LinkPreviewOptions](#linkpreviewoptions)

*Optional*. Options used for link preview generation for the original message, if it is a text message

animation

[Animation](#animation)

*Optional*. Message is an animation, information about the animation

audio

[Audio](#audio)

*Optional*. Message is an audio file, information about the file

document

[Document](#document)

*Optional*. Message is a general file, information about the file

paid\_media

[PaidMediaInfo](#paidmediainfo)

*Optional*. Message contains paid media; information about the paid media

photo

Array of [PhotoSize](#photosize)

*Optional*. Message is a photo, available sizes of the photo

sticker

[Sticker](#sticker)

*Optional*. Message is a sticker, information about the sticker

story

[Story](#story)

*Optional*. Message is a forwarded story

video

[Video](#video)

*Optional*. Message is a video, information about the video

video\_note

[VideoNote](#videonote)

*Optional*. Message is a [video note](https://telegram.org/blog/video-messages-and-telescope), information about the video message

voice

[Voice](#voice)

*Optional*. Message is a voice message, information about the file

has\_media\_spoiler

True

*Optional*. *True*, if the message media is covered by a spoiler animation

checklist

[Checklist](#checklist)

*Optional*. Message is a checklist

contact

[Contact](#contact)

*Optional*. Message is a shared contact, information about the contact

dice

[Dice](#dice)

*Optional*. Message is a dice with random value

game

[Game](#game)

*Optional*. Message is a game, information about the game. [More about games »](#games)

giveaway

[Giveaway](#giveaway)

*Optional*. Message is a scheduled giveaway, information about the giveaway

giveaway\_winners

[GiveawayWinners](#giveawaywinners)

*Optional*. A giveaway with public winners was completed

invoice

[Invoice](#invoice)

*Optional*. Message is an invoice for a [payment](#payments), information about the invoice. [More about payments »](#payments)

location

[Location](#location)

*Optional*. Message is a shared location, information about the location

poll

[Poll](#poll)

*Optional*. Message is a native poll, information about the poll

venue

[Venue](#venue)

*Optional*. Message is a venue, information about the venue

#### [](#replyparameters)ReplyParameters

Describes reply parameters for the message that is being sent.

Field

Type

Description

message\_id

Integer

Identifier of the message that will be replied to in the current chat, or in the chat *chat\_id* if it is specified

chat\_id

Integer or String

*Optional*. If the message to be replied to is from a different chat, unique identifier for the chat or username of the channel (in the format `@channelusername`). Not supported for messages sent on behalf of a business account and messages from channel direct messages chats.

allow\_sending\_without\_reply

Boolean

*Optional*. Pass *True* if the message should be sent even if the specified message to be replied to is not found. Always *False* for replies in another chat or forum topic. Always *True* for messages sent on behalf of a business account.

quote

String

*Optional*. Quoted part of the message to be replied to; 0-1024 characters after entities parsing. The quote must be an exact substring of the message to be replied to, including *bold*, *italic*, *underline*, *strikethrough*, *spoiler*, and *custom\_emoji* entities. The message will fail to send if the quote isn't found in the original message.

quote\_parse\_mode

String

*Optional*. Mode for parsing entities in the quote. See [formatting options](#formatting-options) for more details.

quote\_entities

Array of [MessageEntity](#messageentity)

*Optional*. A JSON-serialized list of special entities that appear in the quote. It can be specified instead of *quote\_parse\_mode*.

quote\_position

Integer

*Optional*. Position of the quote in the original message in UTF-16 code units

checklist\_task\_id

Integer

*Optional*. Identifier of the specific checklist task to be replied to

#### [](#messageorigin)MessageOrigin

This object describes the origin of a message. It can be one of

-   [MessageOriginUser](#messageoriginuser)
-   [MessageOriginHiddenUser](#messageoriginhiddenuser)
-   [MessageOriginChat](#messageoriginchat)
-   [MessageOriginChannel](#messageoriginchannel)

#### [](#messageoriginuser)MessageOriginUser

The message was originally sent by a known user.

Field

Type

Description

type

String

Type of the message origin, always “user”

date

Integer

Date the message was sent originally in Unix time

sender\_user

[User](#user)

User that sent the message originally

#### [](#messageoriginhiddenuser)MessageOriginHiddenUser

The message was originally sent by an unknown user.

Field

Type

Description

type

String

Type of the message origin, always “hidden\_user”

date

Integer

Date the message was sent originally in Unix time

sender\_user\_name

String

Name of the user that sent the message originally

#### [](#messageoriginchat)MessageOriginChat

The message was originally sent on behalf of a chat to a group chat.

Field

Type

Description

type

String

Type of the message origin, always “chat”

date

Integer

Date the message was sent originally in Unix time

sender\_chat

[Chat](#chat)

Chat that sent the message originally

author\_signature

String

*Optional*. For messages originally sent by an anonymous chat administrator, original message author signature

#### [](#messageoriginchannel)MessageOriginChannel

The message was originally sent to a channel chat.

Field

Type

Description

type

String

Type of the message origin, always “channel”

date

Integer

Date the message was sent originally in Unix time

chat

[Chat](#chat)

Channel chat to which the message was originally sent

message\_id

Integer

Unique message identifier inside the chat

author\_signature

String

*Optional*. Signature of the original post author

#### [](#photosize)PhotoSize

This object represents one size of a photo or a [file](#document) / [sticker](#sticker) thumbnail.

Field

Type

Description

file\_id

String

Identifier for this file, which can be used to download or reuse the file

file\_unique\_id

String

Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.

width

Integer

Photo width

height

Integer

Photo height

file\_size

Integer

*Optional*. File size in bytes

#### [](#animation)Animation

This object represents an animation file (GIF or H.264/MPEG-4 AVC video without sound).

Field

Type

Description

file\_id

String

Identifier for this file, which can be used to download or reuse the file

file\_unique\_id

String

Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.

width

Integer

Video width as defined by the sender

height

Integer

Video height as defined by the sender

duration

Integer

Duration of the video in seconds as defined by the sender

thumbnail

[PhotoSize](#photosize)

*Optional*. Animation thumbnail as defined by the sender

file\_name

String

*Optional*. Original animation filename as defined by the sender

mime\_type

String

*Optional*. MIME type of the file as defined by the sender

file\_size

Integer

*Optional*. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.

#### [](#audio)Audio

This object represents an audio file to be treated as music by the Telegram clients.

Field

Type

Description

file\_id

String

Identifier for this file, which can be used to download or reuse the file

file\_unique\_id

String

Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.

duration

Integer

Duration of the audio in seconds as defined by the sender

performer

String

*Optional*. Performer of the audio as defined by the sender or by audio tags

title

String

*Optional*. Title of the audio as defined by the sender or by audio tags

file\_name

String

*Optional*. Original filename as defined by the sender

mime\_type

String

*Optional*. MIME type of the file as defined by the sender

file\_size

Integer

*Optional*. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.

thumbnail

[PhotoSize](#photosize)

*Optional*. Thumbnail of the album cover to which the music file belongs

#### [](#document)Document

This object represents a general file (as opposed to [photos](#photosize), [voice messages](#voice) and [audio files](#audio)).

Field

Type

Description

file\_id

String

Identifier for this file, which can be used to download or reuse the file

file\_unique\_id

String

Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.

thumbnail

[PhotoSize](#photosize)

*Optional*. Document thumbnail as defined by the sender

file\_name

String

*Optional*. Original filename as defined by the sender

mime\_type

String

*Optional*. MIME type of the file as defined by the sender

file\_size

Integer

*Optional*. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.

#### [](#story)Story

This object represents a story.

Field

Type

Description

chat

[Chat](#chat)

Chat that posted the story

id

Integer

Unique identifier for the story in the chat

#### [](#video)Video

This object represents a video file.

Field

Type

Description

file\_id

String

Identifier for this file, which can be used to download or reuse the file

file\_unique\_id

String

Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.

width

Integer

Video width as defined by the sender

height

Integer

Video height as defined by the sender

duration

Integer

Duration of the video in seconds as defined by the sender

thumbnail

[PhotoSize](#photosize)

*Optional*. Video thumbnail

cover

Array of [PhotoSize](#photosize)

*Optional*. Available sizes of the cover of the video in the message

start\_timestamp

Integer

*Optional*. Timestamp in seconds from which the video will play in the message

file\_name

String

*Optional*. Original filename as defined by the sender

mime\_type

String

*Optional*. MIME type of the file as defined by the sender

file\_size

Integer

*Optional*. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.

#### [](#videonote)VideoNote

This object represents a [video message](https://telegram.org/blog/video-messages-and-telescope) (available in Telegram apps as of [v.4.0](https://telegram.org/blog/video-messages-and-telescope)).

Field

Type

Description

file\_id

String

Identifier for this file, which can be used to download or reuse the file

file\_unique\_id

String

Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.

length

Integer

Video width and height (diameter of the video message) as defined by the sender

duration

Integer

Duration of the video in seconds as defined by the sender

thumbnail

[PhotoSize](#photosize)

*Optional*. Video thumbnail

file\_size

Integer

*Optional*. File size in bytes

#### [](#voice)Voice

This object represents a voice note.

Field

Type

Description

file\_id

String

Identifier for this file, which can be used to download or reuse the file

file\_unique\_id

String

Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.

duration

Integer

Duration of the audio in seconds as defined by the sender

mime\_type

String

*Optional*. MIME type of the file as defined by the sender

file\_size

Integer

*Optional*. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.

#### [](#paidmediainfo)PaidMediaInfo

Describes the paid media added to a message.

Field

Type

Description

star\_count

Integer

The number of Telegram Stars that must be paid to buy access to the media

paid\_media

Array of [PaidMedia](#paidmedia)

Information about the paid media

#### [](#paidmedia)PaidMedia

This object describes paid media. Currently, it can be one of

-   [PaidMediaPreview](#paidmediapreview)
-   [PaidMediaPhoto](#paidmediaphoto)
-   [PaidMediaVideo](#paidmediavideo)

#### [](#paidmediapreview)PaidMediaPreview

The paid media isn't available before the payment.

Field

Type

Description

type

String

Type of the paid media, always “preview”

width

Integer

*Optional*. Media width as defined by the sender

height

Integer

*Optional*. Media height as defined by the sender

duration

Integer

*Optional*. Duration of the media in seconds as defined by the sender

#### [](#paidmediaphoto)PaidMediaPhoto

The paid media is a photo.

Field

Type

Description

type

String

Type of the paid media, always “photo”

photo

Array of [PhotoSize](#photosize)

The photo

#### [](#paidmediavideo)PaidMediaVideo

The paid media is a video.

Field

Type

Description

type

String

Type of the paid media, always “video”

video

[Video](#video)

The video

#### [](#contact)Contact

This object represents a phone contact.

Field

Type

Description

phone\_number

String

Contact's phone number

first\_name

String

Contact's first name

last\_name

String

*Optional*. Contact's last name

user\_id

Integer

*Optional*. Contact's user identifier in Telegram. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier.

vcard

String

*Optional*. Additional data about the contact in the form of a [vCard](https://en.wikipedia.org/wiki/VCard)

#### [](#dice)Dice

This object represents an animated emoji that displays a random value.

Field

Type

Description

emoji

String

Emoji on which the dice throw animation is based

value

Integer

Value of the dice, 1-6 for “![🎲](//telegram.org/img/emoji/40/F09F8EB2.png)”, “![🎯](//telegram.org/img/emoji/40/F09F8EAF.png)” and “![🎳](//telegram.org/img/emoji/40/F09F8EB3.png)” base emoji, 1-5 for “![🏀](//telegram.org/img/emoji/40/F09F8F80.png)” and “![⚽](//telegram.org/img/emoji/40/E29ABD.png)” base emoji, 1-64 for “![🎰](//telegram.org/img/emoji/40/F09F8EB0.png)” base emoji

#### [](#polloption)PollOption

This object contains information about one answer option in a poll.

Field

Type

Description

text

String

Option text, 1-100 characters

text\_entities

Array of [MessageEntity](#messageentity)

*Optional*. Special entities that appear in the option *text*. Currently, only custom emoji entities are allowed in poll option texts

voter\_count

Integer

Number of users that voted for this option

#### [](#inputpolloption)InputPollOption

This object contains information about one answer option in a poll to be sent.

Field

Type

Description

text

String

Option text, 1-100 characters

text\_parse\_mode

String

*Optional*. Mode for parsing entities in the text. See [formatting options](#formatting-options) for more details. Currently, only custom emoji entities are allowed

text\_entities

Array of [MessageEntity](#messageentity)

*Optional*. A JSON-serialized list of special entities that appear in the poll option text. It can be specified instead of *text\_parse\_mode*

#### [](#pollanswer)PollAnswer

This object represents an answer of a user in a non-anonymous poll.

Field

Type

Description

poll\_id

String

Unique poll identifier

voter\_chat

[Chat](#chat)

*Optional*. The chat that changed the answer to the poll, if the voter is anonymous

user

[User](#user)

*Optional*. The user that changed the answer to the poll, if the voter isn't anonymous

option\_ids

Array of Integer

0-based identifiers of chosen answer options. May be empty if the vote was retracted.

#### [](#poll)Poll

This object contains information about a poll.

Field

Type

Description

id

String

Unique poll identifier

question

String

Poll question, 1-300 characters

question\_entities

Array of [MessageEntity](#messageentity)

*Optional*. Special entities that appear in the *question*. Currently, only custom emoji entities are allowed in poll questions

options

Array of [PollOption](#polloption)

List of poll options

total\_voter\_count

Integer

Total number of users that voted in the poll

is\_closed

Boolean

*True*, if the poll is closed

is\_anonymous

Boolean

*True*, if the poll is anonymous

type

String

Poll type, currently can be “regular” or “quiz”

allows\_multiple\_answers

Boolean

*True*, if the poll allows multiple answers

correct\_option\_id

Integer

*Optional*. 0-based identifier of the correct answer option. Available only for polls in the quiz mode, which are closed, or was sent (not forwarded) by the bot or to the private chat with the bot.

explanation

String

*Optional*. Text that is shown when a user chooses an incorrect answer or taps on the lamp icon in a quiz-style poll, 0-200 characters

explanation\_entities

Array of [MessageEntity](#messageentity)

*Optional*. Special entities like usernames, URLs, bot commands, etc. that appear in the *explanation*

open\_period

Integer

*Optional*. Amount of time in seconds the poll will be active after creation

close\_date

Integer

*Optional*. Point in time (Unix timestamp) when the poll will be automatically closed

#### [](#checklisttask)ChecklistTask

Describes a task in a checklist.

Field

Type

Description

id

Integer

Unique identifier of the task

text

String

Text of the task

text\_entities

Array of [MessageEntity](#messageentity)

*Optional*. Special entities that appear in the task text

completed\_by\_user

[User](#user)

*Optional*. User that completed the task; omitted if the task wasn't completed by a user

completed\_by\_chat

[Chat](#chat)

*Optional*. Chat that completed the task; omitted if the task wasn't completed by a chat

completion\_date

Integer

*Optional*. Point in time (Unix timestamp) when the task was completed; 0 if the task wasn't completed

#### [](#checklist)Checklist

Describes a checklist.

Field

Type

Description

title

String

Title of the checklist

title\_entities

Array of [MessageEntity](#messageentity)

*Optional*. Special entities that appear in the checklist title

tasks

Array of [ChecklistTask](#checklisttask)

List of tasks in the checklist

others\_can\_add\_tasks

True

*Optional*. *True*, if users other than the creator of the list can add tasks to the list

others\_can\_mark\_tasks\_as\_done

True

*Optional*. *True*, if users other than the creator of the list can mark tasks as done or not done

#### [](#inputchecklisttask)InputChecklistTask

Describes a task to add to a checklist.

Field

Type

Description

id

Integer

Unique identifier of the task; must be positive and unique among all task identifiers currently present in the checklist

text

String

Text of the task; 1-100 characters after entities parsing

parse\_mode

String

*Optional*. Mode for parsing entities in the text. See [formatting options](https://core.telegram.org/bots/api#formatting-options) for more details.

text\_entities

Array of [MessageEntity](#messageentity)

*Optional*. List of special entities that appear in the text, which can be specified instead of parse\_mode. Currently, only *bold*, *italic*, *underline*, *strikethrough*, *spoiler*, and *custom\_emoji* entities are allowed.

#### [](#inputchecklist)InputChecklist

Describes a checklist to create.

Field

Type

Description

title

String

Title of the checklist; 1-255 characters after entities parsing

parse\_mode

String

*Optional*. Mode for parsing entities in the title. See [formatting options](#formatting-options) for more details.

title\_entities

Array of [MessageEntity](#messageentity)

*Optional*. List of special entities that appear in the title, which can be specified instead of parse\_mode. Currently, only *bold*, *italic*, *underline*, *strikethrough*, *spoiler*, and *custom\_emoji* entities are allowed.

tasks

Array of [InputChecklistTask](#inputchecklisttask)

List of 1-30 tasks in the checklist

others\_can\_add\_tasks

Boolean

*Optional*. Pass *True* if other users can add tasks to the checklist

others\_can\_mark\_tasks\_as\_done

Boolean

*Optional*. Pass *True* if other users can mark tasks as done or not done in the checklist

#### [](#checklisttasksdone)ChecklistTasksDone

Describes a service message about checklist tasks marked as done or not done.

Field

Type

Description

checklist\_message

[Message](#message)

*Optional*. Message containing the checklist whose tasks were marked as done or not done. Note that the [Message](#message) object in this field will not contain the *reply\_to\_message* field even if it itself is a reply.

marked\_as\_done\_task\_ids

Array of Integer

*Optional*. Identifiers of the tasks that were marked as done

marked\_as\_not\_done\_task\_ids

Array of Integer

*Optional*. Identifiers of the tasks that were marked as not done

#### [](#checklisttasksadded)ChecklistTasksAdded

Describes a service message about tasks added to a checklist.

Field

Type

Description

checklist\_message

[Message](#message)

*Optional*. Message containing the checklist to which the tasks were added. Note that the [Message](#message) object in this field will not contain the *reply\_to\_message* field even if it itself is a reply.

tasks

Array of [ChecklistTask](#checklisttask)

List of tasks added to the checklist

#### [](#location)Location

This object represents a point on the map.

Field

Type

Description

latitude

Float

Latitude as defined by the sender

longitude

Float

Longitude as defined by the sender

horizontal\_accuracy

Float

*Optional*. The radius of uncertainty for the location, measured in meters; 0-1500

live\_period

Integer

*Optional*. Time relative to the message sending date, during which the location can be updated; in seconds. For active live locations only.

heading

Integer

*Optional*. The direction in which user is moving, in degrees; 1-360. For active live locations only.

proximity\_alert\_radius

Integer

*Optional*. The maximum distance for proximity alerts about approaching another chat member, in meters. For sent live locations only.

#### [](#venue)Venue

This object represents a venue.

Field

Type

Description

location

[Location](#location)

Venue location. Can't be a live location

title

String

Name of the venue

address

String

Address of the venue

foursquare\_id

String

*Optional*. Foursquare identifier of the venue

foursquare\_type

String

*Optional*. Foursquare type of the venue. (For example, “arts\_entertainment/default”, “arts\_entertainment/aquarium” or “food/icecream”.)

google\_place\_id

String

*Optional*. Google Places identifier of the venue

google\_place\_type

String

*Optional*. Google Places type of the venue. (See [supported types](https://developers.google.com/places/web-service/supported_types).)

#### [](#webappdata)WebAppData

Describes data sent from a [Web App](/bots/webapps) to the bot.

Field

Type

Description

data

String

The data. Be aware that a bad client can send arbitrary data in this field.

button\_text

String

Text of the *web\_app* keyboard button from which the Web App was opened. Be aware that a bad client can send arbitrary data in this field.

#### [](#proximityalerttriggered)ProximityAlertTriggered

This object represents the content of a service message, sent whenever a user in the chat triggers a proximity alert set by another user.

Field

Type

Description

traveler

[User](#user)

User that triggered the alert

watcher

[User](#user)

User that set the alert

distance

Integer

The distance between the users

#### [](#messageautodeletetimerchanged)MessageAutoDeleteTimerChanged

This object represents a service message about a change in auto-delete timer settings.

Field

Type

Description

message\_auto\_delete\_time

Integer

New auto-delete time for messages in the chat; in seconds

#### [](#chatboostadded)ChatBoostAdded

This object represents a service message about a user boosting a chat.

Field

Type

Description

boost\_count

Integer

Number of boosts added by the user

#### [](#backgroundfill)BackgroundFill

This object describes the way a background is filled based on the selected colors. Currently, it can be one of

-   [BackgroundFillSolid](#backgroundfillsolid)
-   [BackgroundFillGradient](#backgroundfillgradient)
-   [BackgroundFillFreeformGradient](#backgroundfillfreeformgradient)

#### [](#backgroundfillsolid)BackgroundFillSolid

The background is filled using the selected color.

Field

Type

Description

type

String

Type of the background fill, always “solid”

color

Integer

The color of the background fill in the RGB24 format

#### [](#backgroundfillgradient)BackgroundFillGradient

The background is a gradient fill.

Field

Type

Description

type

String

Type of the background fill, always “gradient”

top\_color

Integer

Top color of the gradient in the RGB24 format

bottom\_color

Integer

Bottom color of the gradient in the RGB24 format

rotation\_angle

Integer

Clockwise rotation angle of the background fill in degrees; 0-359

#### [](#backgroundfillfreeformgradient)BackgroundFillFreeformGradient

The background is a freeform gradient that rotates after every message in the chat.

Field

Type

Description

type

String

Type of the background fill, always “freeform\_gradient”

colors

Array of Integer

A list of the 3 or 4 base colors that are used to generate the freeform gradient in the RGB24 format

#### [](#backgroundtype)BackgroundType

This object describes the type of a background. Currently, it can be one of

-   [BackgroundTypeFill](#backgroundtypefill)
-   [BackgroundTypeWallpaper](#backgroundtypewallpaper)
-   [BackgroundTypePattern](#backgroundtypepattern)
-   [BackgroundTypeChatTheme](#backgroundtypechattheme)

#### [](#backgroundtypefill)BackgroundTypeFill

The background is automatically filled based on the selected colors.

Field

Type

Description

type

String

Type of the background, always “fill”

fill

[BackgroundFill](#backgroundfill)

The background fill

dark\_theme\_dimming

Integer

Dimming of the background in dark themes, as a percentage; 0-100

#### [](#backgroundtypewallpaper)BackgroundTypeWallpaper

The background is a wallpaper in the JPEG format.

Field

Type

Description

type

String

Type of the background, always “wallpaper”

document

[Document](#document)

Document with the wallpaper

dark\_theme\_dimming

Integer

Dimming of the background in dark themes, as a percentage; 0-100

is\_blurred

True

*Optional*. *True*, if the wallpaper is downscaled to fit in a 450x450 square and then box-blurred with radius 12

is\_moving

True

*Optional*. *True*, if the background moves slightly when the device is tilted

#### [](#backgroundtypepattern)BackgroundTypePattern

The background is a .PNG or .TGV (gzipped subset of SVG with MIME type “application/x-tgwallpattern”) pattern to be combined with the background fill chosen by the user.

Field

Type

Description

type

String

Type of the background, always “pattern”

document

[Document](#document)

Document with the pattern

fill

[BackgroundFill](#backgroundfill)

The background fill that is combined with the pattern

intensity

Integer

Intensity of the pattern when it is shown above the filled background; 0-100

is\_inverted

True

*Optional*. *True*, if the background fill must be applied only to the pattern itself. All other pixels are black in this case. For dark themes only

is\_moving

True

*Optional*. *True*, if the background moves slightly when the device is tilted

#### [](#backgroundtypechattheme)BackgroundTypeChatTheme

The background is taken directly from a built-in chat theme.

Field

Type

Description

type

String

Type of the background, always “chat\_theme”

theme\_name

String

Name of the chat theme, which is usually an emoji

#### [](#chatbackground)ChatBackground

This object represents a chat background.

Field

Type

Description

type

[BackgroundType](#backgroundtype)

Type of the background

#### [](#forumtopiccreated)ForumTopicCreated

This object represents a service message about a new forum topic created in the chat.

Field

Type

Description

name

String

Name of the topic

icon\_color

Integer

Color of the topic icon in RGB format

icon\_custom\_emoji\_id

String

*Optional*. Unique identifier of the custom emoji shown as the topic icon

is\_name\_implicit

True

*Optional*. *True*, if the name of the topic wasn't specified explicitly by its creator and likely needs to be changed by the bot

#### [](#forumtopicclosed)ForumTopicClosed

This object represents a service message about a forum topic closed in the chat. Currently holds no information.

#### [](#forumtopicedited)ForumTopicEdited

This object represents a service message about an edited forum topic.

Field

Type

Description

name

String

*Optional*. New name of the topic, if it was edited

icon\_custom\_emoji\_id

String

*Optional*. New identifier of the custom emoji shown as the topic icon, if it was edited; an empty string if the icon was removed

#### [](#forumtopicreopened)ForumTopicReopened

This object represents a service message about a forum topic reopened in the chat. Currently holds no information.

#### [](#generalforumtopichidden)GeneralForumTopicHidden

This object represents a service message about General forum topic hidden in the chat. Currently holds no information.

#### [](#generalforumtopicunhidden)GeneralForumTopicUnhidden

This object represents a service message about General forum topic unhidden in the chat. Currently holds no information.

#### [](#shareduser)SharedUser

This object contains information about a user that was shared with the bot using a [KeyboardButtonRequestUsers](#keyboardbuttonrequestusers) button.

Field

Type

Description

user\_id

Integer

Identifier of the shared user. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so 64-bit integers or double-precision float types are safe for storing these identifiers. The bot may not have access to the user and could be unable to use this identifier, unless the user is already known to the bot by some other means.

first\_name

String

*Optional*. First name of the user, if the name was requested by the bot

last\_name

String

*Optional*. Last name of the user, if the name was requested by the bot

username

String

*Optional*. Username of the user, if the username was requested by the bot

photo

Array of [PhotoSize](#photosize)

*Optional*. Available sizes of the chat photo, if the photo was requested by the bot

#### [](#usersshared)UsersShared

This object contains information about the users whose identifiers were shared with the bot using a [KeyboardButtonRequestUsers](#keyboardbuttonrequestusers) button.

Field

Type

Description

request\_id

Integer

Identifier of the request

users

Array of [SharedUser](#shareduser)

Information about users shared with the bot.

#### [](#chatshared)ChatShared

This object contains information about a chat that was shared with the bot using a [KeyboardButtonRequestChat](#keyboardbuttonrequestchat) button.

Field

Type

Description

request\_id

Integer

Identifier of the request

chat\_id

Integer

Identifier of the shared chat. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier. The bot may not have access to the chat and could be unable to use this identifier, unless the chat is already known to the bot by some other means.

title

String

*Optional*. Title of the chat, if the title was requested by the bot.

username

String

*Optional*. Username of the chat, if the username was requested by the bot and available.

photo

Array of [PhotoSize](#photosize)

*Optional*. Available sizes of the chat photo, if the photo was requested by the bot

#### [](#writeaccessallowed)WriteAccessAllowed

This object represents a service message about a user allowing a bot to write messages after adding it to the attachment menu, launching a Web App from a link, or accepting an explicit request from a Web App sent by the method [requestWriteAccess](/bots/webapps#initializing-mini-apps).

Field

Type

Description

from\_request

Boolean

*Optional*. *True*, if the access was granted after the user accepted an explicit request from a Web App sent by the method [requestWriteAccess](/bots/webapps#initializing-mini-apps)

web\_app\_name

String

*Optional*. Name of the Web App, if the access was granted when the Web App was launched from a link

from\_attachment\_menu

Boolean

*Optional*. *True*, if the access was granted when the bot was added to the attachment or side menu

#### [](#videochatscheduled)VideoChatScheduled

This object represents a service message about a video chat scheduled in the chat.

Field

Type

Description

start\_date

Integer

Point in time (Unix timestamp) when the video chat is supposed to be started by a chat administrator

#### [](#videochatstarted)VideoChatStarted

This object represents a service message about a video chat started in the chat. Currently holds no information.

#### [](#videochatended)VideoChatEnded

This object represents a service message about a video chat ended in the chat.

Field

Type

Description

duration

Integer

Video chat duration in seconds

#### [](#videochatparticipantsinvited)VideoChatParticipantsInvited

This object represents a service message about new members invited to a video chat.

Field

Type

Description

users

Array of [User](#user)

New members that were invited to the video chat

#### [](#paidmessagepricechanged)PaidMessagePriceChanged

Describes a service message about a change in the price of paid messages within a chat.

Field

Type

Description

paid\_message\_star\_count

Integer

The new number of Telegram Stars that must be paid by non-administrator users of the supergroup chat for each sent message

#### [](#directmessagepricechanged)DirectMessagePriceChanged

Describes a service message about a change in the price of direct messages sent to a channel chat.

Field

Type

Description

are\_direct\_messages\_enabled

Boolean

*True*, if direct messages are enabled for the channel chat; false otherwise

direct\_message\_star\_count

Integer

*Optional*. The new number of Telegram Stars that must be paid by users for each direct message sent to the channel. Does not apply to users who have been exempted by administrators. Defaults to 0.

#### [](#suggestedpostapproved)SuggestedPostApproved

Describes a service message about the approval of a suggested post.

Field

Type

Description

suggested\_post\_message

[Message](#message)

*Optional*. Message containing the suggested post. Note that the [Message](#message) object in this field will not contain the *reply\_to\_message* field even if it itself is a reply.

price

[SuggestedPostPrice](#suggestedpostprice)

*Optional*. Amount paid for the post

send\_date

Integer

Date when the post will be published

#### [](#suggestedpostapprovalfailed)SuggestedPostApprovalFailed

Describes a service message about the failed approval of a suggested post. Currently, only caused by insufficient user funds at the time of approval.

Field

Type

Description

suggested\_post\_message

[Message](#message)

*Optional*. Message containing the suggested post whose approval has failed. Note that the [Message](#message) object in this field will not contain the *reply\_to\_message* field even if it itself is a reply.

price

[SuggestedPostPrice](#suggestedpostprice)

Expected price of the post

#### [](#suggestedpostdeclined)SuggestedPostDeclined

Describes a service message about the rejection of a suggested post.

Field

Type

Description

suggested\_post\_message

[Message](#message)

*Optional*. Message containing the suggested post. Note that the [Message](#message) object in this field will not contain the *reply\_to\_message* field even if it itself is a reply.

comment

String

*Optional*. Comment with which the post was declined

#### [](#suggestedpostpaid)SuggestedPostPaid

Describes a service message about a successful payment for a suggested post.

Field

Type

Description

suggested\_post\_message

[Message](#message)

*Optional*. Message containing the suggested post. Note that the [Message](#message) object in this field will not contain the *reply\_to\_message* field even if it itself is a reply.

currency

String

Currency in which the payment was made. Currently, one of “XTR” for Telegram Stars or “TON” for toncoins

amount

Integer

*Optional*. The amount of the currency that was received by the channel in nanotoncoins; for payments in toncoins only

star\_amount

[StarAmount](#staramount)

*Optional*. The amount of Telegram Stars that was received by the channel; for payments in Telegram Stars only

#### [](#suggestedpostrefunded)SuggestedPostRefunded

Describes a service message about a payment refund for a suggested post.

Field

Type

Description

suggested\_post\_message

[Message](#message)

*Optional*. Message containing the suggested post. Note that the [Message](#message) object in this field will not contain the *reply\_to\_message* field even if it itself is a reply.

reason

String

Reason for the refund. Currently, one of “post\_deleted” if the post was deleted within 24 hours of being posted or removed from scheduled messages without being posted, or “payment\_refunded” if the payer refunded their payment.

#### [](#giveawaycreated)GiveawayCreated

This object represents a service message about the creation of a scheduled giveaway.

Field

Type

Description

prize\_star\_count

Integer

*Optional*. The number of Telegram Stars to be split between giveaway winners; for Telegram Star giveaways only

#### [](#giveaway)Giveaway

This object represents a message about a scheduled giveaway.

Field

Type

Description

chats

Array of [Chat](#chat)

The list of chats which the user must join to participate in the giveaway

winners\_selection\_date

Integer

Point in time (Unix timestamp) when winners of the giveaway will be selected

winner\_count

Integer

The number of users which are supposed to be selected as winners of the giveaway

only\_new\_members

True

*Optional*. *True*, if only users who join the chats after the giveaway started should be eligible to win

has\_public\_winners

True

*Optional*. *True*, if the list of giveaway winners will be visible to everyone

prize\_description

String

*Optional*. Description of additional giveaway prize

country\_codes

Array of String

*Optional*. A list of two-letter [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country codes indicating the countries from which eligible users for the giveaway must come. If empty, then all users can participate in the giveaway. Users with a phone number that was bought on Fragment can always participate in giveaways.

prize\_star\_count

Integer

*Optional*. The number of Telegram Stars to be split between giveaway winners; for Telegram Star giveaways only

premium\_subscription\_month\_count

Integer

*Optional*. The number of months the Telegram Premium subscription won from the giveaway will be active for; for Telegram Premium giveaways only

#### [](#giveawaywinners)GiveawayWinners

This object represents a message about the completion of a giveaway with public winners.

Field

Type

Description

chat

[Chat](#chat)

The chat that created the giveaway

giveaway\_message\_id

Integer

Identifier of the message with the giveaway in the chat

winners\_selection\_date

Integer

Point in time (Unix timestamp) when winners of the giveaway were selected

winner\_count

Integer

Total number of winners in the giveaway

winners

Array of [User](#user)

List of up to 100 winners of the giveaway

additional\_chat\_count

Integer

*Optional*. The number of other chats the user had to join in order to be eligible for the giveaway

prize\_star\_count

Integer

*Optional*. The number of Telegram Stars that were split between giveaway winners; for Telegram Star giveaways only

premium\_subscription\_month\_count

Integer

*Optional*. The number of months the Telegram Premium subscription won from the giveaway will be active for; for Telegram Premium giveaways only

unclaimed\_prize\_count

Integer

*Optional*. Number of undistributed prizes

only\_new\_members

True

*Optional*. *True*, if only users who had joined the chats after the giveaway started were eligible to win

was\_refunded

True

*Optional*. *True*, if the giveaway was canceled because the payment for it was refunded

prize\_description

String

*Optional*. Description of additional giveaway prize

#### [](#giveawaycompleted)GiveawayCompleted

This object represents a service message about the completion of a giveaway without public winners.

Field

Type

Description

winner\_count

Integer

Number of winners in the giveaway

unclaimed\_prize\_count

Integer

*Optional*. Number of undistributed prizes

giveaway\_message

[Message](#message)

*Optional*. Message with the giveaway that was completed, if it wasn't deleted

is\_star\_giveaway

True

*Optional*. *True*, if the giveaway is a Telegram Star giveaway. Otherwise, currently, the giveaway is a Telegram Premium giveaway.

#### [](#linkpreviewoptions)LinkPreviewOptions

Describes the options used for link preview generation.

Field

Type

Description

is\_disabled

Boolean

*Optional*. *True*, if the link preview is disabled

url

String

*Optional*. URL to use for the link preview. If empty, then the first URL found in the message text will be used

prefer\_small\_media

Boolean

*Optional*. *True*, if the media in the link preview is supposed to be shrunk; ignored if the URL isn't explicitly specified or media size change isn't supported for the preview

prefer\_large\_media

Boolean

*Optional*. *True*, if the media in the link preview is supposed to be enlarged; ignored if the URL isn't explicitly specified or media size change isn't supported for the preview

show\_above\_text

Boolean

*Optional*. *True*, if the link preview must be shown above the message text; otherwise, the link preview will be shown below the message text

#### [](#suggestedpostprice)SuggestedPostPrice

Describes the price of a suggested post.

Field

Type

Description

currency

String

Currency in which the post will be paid. Currently, must be one of “XTR” for Telegram Stars or “TON” for toncoins

amount

Integer

The amount of the currency that will be paid for the post in the *smallest units* of the currency, i.e. Telegram Stars or nanotoncoins. Currently, price in Telegram Stars must be between 5 and 100000, and price in nanotoncoins must be between 10000000 and 10000000000000.

#### [](#suggestedpostinfo)SuggestedPostInfo

Contains information about a suggested post.

Field

Type

Description

state

String

State of the suggested post. Currently, it can be one of “pending”, “approved”, “declined”.

price

[SuggestedPostPrice](#suggestedpostprice)

*Optional*. Proposed price of the post. If the field is omitted, then the post is unpaid.

send\_date

Integer

*Optional*. Proposed send date of the post. If the field is omitted, then the post can be published at any time within 30 days at the sole discretion of the user or administrator who approves it.

#### [](#suggestedpostparameters)SuggestedPostParameters

Contains parameters of a post that is being suggested by the bot.

Field

Type

Description

price

[SuggestedPostPrice](#suggestedpostprice)

*Optional*. Proposed price for the post. If the field is omitted, then the post is unpaid.

send\_date

Integer

*Optional*. Proposed send date of the post. If specified, then the date must be between 300 second and 2678400 seconds (30 days) in the future. If the field is omitted, then the post can be published at any time within 30 days at the sole discretion of the user who approves it.

#### [](#directmessagestopic)DirectMessagesTopic

Describes a topic of a direct messages chat.

Field

Type

Description

topic\_id

Integer

Unique identifier of the topic. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier.

user

[User](#user)

*Optional*. Information about the user that created the topic. Currently, it is always present

#### [](#userprofilephotos)UserProfilePhotos

This object represent a user's profile pictures.

Field

Type

Description

total\_count

Integer

Total number of profile pictures the target user has

photos

Array of Array of [PhotoSize](#photosize)

Requested profile pictures (in up to 4 sizes each)

#### [](#file)File

This object represents a file ready to be downloaded. The file can be downloaded via the link `https://api.telegram.org/file/bot<token>/<file_path>`. It is guaranteed that the link will be valid for at least 1 hour. When the link expires, a new one can be requested by calling [getFile](#getfile).

> The maximum file size to download is 20 MB

Field

Type

Description

file\_id

String

Identifier for this file, which can be used to download or reuse the file

file\_unique\_id

String

Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.

file\_size

Integer

*Optional*. File size in bytes. It can be bigger than 2^31 and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this value.

file\_path

String

*Optional*. File path. Use `https://api.telegram.org/file/bot<token>/<file_path>` to get the file.

#### [](#webappinfo)WebAppInfo

Describes a [Web App](/bots/webapps).

Field

Type

Description

url

String

An HTTPS URL of a Web App to be opened with additional data as specified in [Initializing Web Apps](/bots/webapps#initializing-mini-apps)

#### [](#replykeyboardmarkup)ReplyKeyboardMarkup

This object represents a [custom keyboard](/bots/features#keyboards) with reply options (see [Introduction to bots](/bots/features#keyboards) for details and examples). Not supported in channels and for messages sent on behalf of a Telegram Business account.

Field

Type

Description

keyboard

Array of Array of [KeyboardButton](#keyboardbutton)

Array of button rows, each represented by an Array of [KeyboardButton](#keyboardbutton) objects

is\_persistent

Boolean

*Optional*. Requests clients to always show the keyboard when the regular keyboard is hidden. Defaults to *false*, in which case the custom keyboard can be hidden and opened with a keyboard icon.

resize\_keyboard

Boolean

*Optional*. Requests clients to resize the keyboard vertically for optimal fit (e.g., make the keyboard smaller if there are just two rows of buttons). Defaults to *false*, in which case the custom keyboard is always of the same height as the app's standard keyboard.

one\_time\_keyboard

Boolean

*Optional*. Requests clients to hide the keyboard as soon as it's been used. The keyboard will still be available, but clients will automatically display the usual letter-keyboard in the chat - the user can press a special button in the input field to see the custom keyboard again. Defaults to *false*.

input\_field\_placeholder

String

*Optional*. The placeholder to be shown in the input field when the keyboard is active; 1-64 characters

selective

Boolean

*Optional*. Use this parameter if you want to show the keyboard to specific users only. Targets: 1) users that are @mentioned in the *text* of the [Message](#message) object; 2) if the bot's message is a reply to a message in the same chat and forum topic, sender of the original message.  
  
*Example:* A user requests to change the bot's language, bot replies to the request with a keyboard to select the new language. Other users in the group don't see the keyboard.

#### [](#keyboardbutton)KeyboardButton

This object represents one button of the reply keyboard. At most one of the optional fields must be used to specify type of the button. For simple text buttons, *String* can be used instead of this object to specify the button text.

Field

Type

Description

text

String

Text of the button. If none of the optional fields are used, it will be sent as a message when the button is pressed

request\_users

[KeyboardButtonRequestUsers](#keyboardbuttonrequestusers)

*Optional*. If specified, pressing the button will open a list of suitable users. Identifiers of selected users will be sent to the bot in a “users\_shared” service message. Available in private chats only.

request\_chat

[KeyboardButtonRequestChat](#keyboardbuttonrequestchat)

*Optional*. If specified, pressing the button will open a list of suitable chats. Tapping on a chat will send its identifier to the bot in a “chat\_shared” service message. Available in private chats only.

request\_contact

Boolean

*Optional*. If *True*, the user's phone number will be sent as a contact when the button is pressed. Available in private chats only.

request\_location

Boolean

*Optional*. If *True*, the user's current location will be sent when the button is pressed. Available in private chats only.

request\_poll

[KeyboardButtonPollType](#keyboardbuttonpolltype)

*Optional*. If specified, the user will be asked to create a poll and send it to the bot when the button is pressed. Available in private chats only.

web\_app

[WebAppInfo](#webappinfo)

*Optional*. If specified, the described [Web App](/bots/webapps) will be launched when the button is pressed. The Web App will be able to send a “web\_app\_data” service message. Available in private chats only.

**Note:** *request\_users* and *request\_chat* options will only work in Telegram versions released after 3 February, 2023. Older clients will display *unsupported message*.

#### [](#keyboardbuttonrequestusers)KeyboardButtonRequestUsers

This object defines the criteria used to request suitable users. Information about the selected users will be shared with the bot when the corresponding button is pressed. [More about requesting users »](/bots/features#chat-and-user-selection)

Field

Type

Description

request\_id

Integer

Signed 32-bit identifier of the request that will be received back in the [UsersShared](#usersshared) object. Must be unique within the message

user\_is\_bot

Boolean

*Optional*. Pass *True* to request bots, pass *False* to request regular users. If not specified, no additional restrictions are applied.

user\_is\_premium

Boolean

*Optional*. Pass *True* to request premium users, pass *False* to request non-premium users. If not specified, no additional restrictions are applied.

max\_quantity

Integer

*Optional*. The maximum number of users to be selected; 1-10. Defaults to 1.

request\_name

Boolean

*Optional*. Pass *True* to request the users' first and last names

request\_username

Boolean

*Optional*. Pass *True* to request the users' usernames

request\_photo

Boolean

*Optional*. Pass *True* to request the users' photos

#### [](#keyboardbuttonrequestchat)KeyboardButtonRequestChat

This object defines the criteria used to request a suitable chat. Information about the selected chat will be shared with the bot when the corresponding button is pressed. The bot will be granted requested rights in the chat if appropriate. [More about requesting chats »](/bots/features#chat-and-user-selection).

Field

Type

Description

request\_id

Integer

Signed 32-bit identifier of the request, which will be received back in the [ChatShared](#chatshared) object. Must be unique within the message

chat\_is\_channel

Boolean

Pass *True* to request a channel chat, pass *False* to request a group or a supergroup chat.

chat\_is\_forum

Boolean

*Optional*. Pass *True* to request a forum supergroup, pass *False* to request a non-forum chat. If not specified, no additional restrictions are applied.

chat\_has\_username

Boolean

*Optional*. Pass *True* to request a supergroup or a channel with a username, pass *False* to request a chat without a username. If not specified, no additional restrictions are applied.

chat\_is\_created

Boolean

*Optional*. Pass *True* to request a chat owned by the user. Otherwise, no additional restrictions are applied.

user\_administrator\_rights

[ChatAdministratorRights](#chatadministratorrights)

*Optional*. A JSON-serialized object listing the required administrator rights of the user in the chat. The rights must be a superset of *bot\_administrator\_rights*. If not specified, no additional restrictions are applied.

bot\_administrator\_rights

[ChatAdministratorRights](#chatadministratorrights)

*Optional*. A JSON-serialized object listing the required administrator rights of the bot in the chat. The rights must be a subset of *user\_administrator\_rights*. If not specified, no additional restrictions are applied.

bot\_is\_member

Boolean

*Optional*. Pass *True* to request a chat with the bot as a member. Otherwise, no additional restrictions are applied.

request\_title

Boolean

*Optional*. Pass *True* to request the chat's title

request\_username

Boolean

*Optional*. Pass *True* to request the chat's username

request\_photo

Boolean

*Optional*. Pass *True* to request the chat's photo

#### [](#keyboardbuttonpolltype)KeyboardButtonPollType

This object represents type of a poll, which is allowed to be created and sent when the corresponding button is pressed.

Field

Type

Description

type

String

*Optional*. If *quiz* is passed, the user will be allowed to create only polls in the quiz mode. If *regular* is passed, only regular polls will be allowed. Otherwise, the user will be allowed to create a poll of any type.

#### [](#replykeyboardremove)ReplyKeyboardRemove

Upon receiving a message with this object, Telegram clients will remove the current custom keyboard and display the default letter-keyboard. By default, custom keyboards are displayed until a new keyboard is sent by a bot. An exception is made for one-time keyboards that are hidden immediately after the user presses a button (see [ReplyKeyboardMarkup](#replykeyboardmarkup)). Not supported in channels and for messages sent on behalf of a Telegram Business account.

Field

Type

Description

remove\_keyboard

True

Requests clients to remove the custom keyboard (user will not be able to summon this keyboard; if you want to hide the keyboard from sight but keep it accessible, use *one\_time\_keyboard* in [ReplyKeyboardMarkup](#replykeyboardmarkup))

selective

Boolean

*Optional*. Use this parameter if you want to remove the keyboard for specific users only. Targets: 1) users that are @mentioned in the *text* of the [Message](#message) object; 2) if the bot's message is a reply to a message in the same chat and forum topic, sender of the original message.  
  
*Example:* A user votes in a poll, bot returns confirmation message in reply to the vote and removes the keyboard for that user, while still showing the keyboard with poll options to users who haven't voted yet.

#### [](#inlinekeyboardmarkup)InlineKeyboardMarkup

This object represents an [inline keyboard](/bots/features#inline-keyboards) that appears right next to the message it belongs to.

Field

Type

Description

inline\_keyboard

Array of Array of [InlineKeyboardButton](#inlinekeyboardbutton)

Array of button rows, each represented by an Array of [InlineKeyboardButton](#inlinekeyboardbutton) objects

#### [](#inlinekeyboardbutton)InlineKeyboardButton

This object represents one button of an inline keyboard. Exactly one of the optional fields must be used to specify type of the button.

Field

Type

Description

text

String

Label text on the button

url

String

*Optional*. HTTP or tg:// URL to be opened when the button is pressed. Links `tg://user?id=<user_id>` can be used to mention a user by their identifier without using a username, if this is allowed by their privacy settings.

callback\_data

String

*Optional*. Data to be sent in a [callback query](#callbackquery) to the bot when the button is pressed, 1-64 bytes

web\_app

[WebAppInfo](#webappinfo)

*Optional*. Description of the [Web App](/bots/webapps) that will be launched when the user presses the button. The Web App will be able to send an arbitrary message on behalf of the user using the method [answerWebAppQuery](#answerwebappquery). Available only in private chats between a user and the bot. Not supported for messages sent on behalf of a Telegram Business account.

login\_url

[LoginUrl](#loginurl)

*Optional*. An HTTPS URL used to automatically authorize the user. Can be used as a replacement for the [Telegram Login Widget](/widgets/login).

switch\_inline\_query

String

*Optional*. If set, pressing the button will prompt the user to select one of their chats, open that chat and insert the bot's username and the specified inline query in the input field. May be empty, in which case just the bot's username will be inserted. Not supported for messages sent in channel direct messages chats and on behalf of a Telegram Business account.

switch\_inline\_query\_current\_chat

String

*Optional*. If set, pressing the button will insert the bot's username and the specified inline query in the current chat's input field. May be empty, in which case only the bot's username will be inserted.  
  
This offers a quick way for the user to open your bot in inline mode in the same chat - good for selecting something from multiple options. Not supported in channels and for messages sent in channel direct messages chats and on behalf of a Telegram Business account.

switch\_inline\_query\_chosen\_chat

[SwitchInlineQueryChosenChat](#switchinlinequerychosenchat)

*Optional*. If set, pressing the button will prompt the user to select one of their chats of the specified type, open that chat and insert the bot's username and the specified inline query in the input field. Not supported for messages sent in channel direct messages chats and on behalf of a Telegram Business account.

copy\_text

[CopyTextButton](#copytextbutton)

*Optional*. Description of the button that copies the specified text to the clipboard.

callback\_game

[CallbackGame](#callbackgame)

*Optional*. Description of the game that will be launched when the user presses the button.  
  
**NOTE:** This type of button **must** always be the first button in the first row.

pay

Boolean

*Optional*. Specify *True*, to send a [Pay button](#payments). Substrings “![⭐](//telegram.org/img/emoji/40/E2AD90.png)” and “XTR” in the buttons's text will be replaced with a Telegram Star icon.  
  
**NOTE:** This type of button **must** always be the first button in the first row and can only be used in invoice messages.

#### [](#loginurl)LoginUrl

This object represents a parameter of the inline keyboard button used to automatically authorize a user. Serves as a great replacement for the [Telegram Login Widget](/widgets/login) when the user is coming from Telegram. All the user needs to do is tap/click a button and confirm that they want to log in:

[![TITLE](/file/811140909/1631/20k1Z53eiyY.23995/c541e89b74253623d9 "TITLE")](/file/811140015/1734/8VZFkwWXalM.97872/6127fa62d8a0bf2b3c)

Telegram apps support these buttons as of [version 5.7](https://telegram.org/blog/privacy-discussions-web-bots#meet-seamless-web-bots).

> Sample bot: [@discussbot](https://t.me/discussbot)

Field

Type

Description

url

String

An HTTPS URL to be opened with user authorization data added to the query string when the button is pressed. If the user refuses to provide authorization data, the original URL without information about the user will be opened. The data added is the same as described in [Receiving authorization data](/widgets/login#receiving-authorization-data).  
  
**NOTE:** You **must** always check the hash of the received data to verify the authentication and the integrity of the data as described in [Checking authorization](/widgets/login#checking-authorization).

forward\_text

String

*Optional*. New text of the button in forwarded messages.

bot\_username

String

*Optional*. Username of a bot, which will be used for user authorization. See [Setting up a bot](/widgets/login#setting-up-a-bot) for more details. If not specified, the current bot's username will be assumed. The *url*'s domain must be the same as the domain linked with the bot. See [Linking your domain to the bot](/widgets/login#linking-your-domain-to-the-bot) for more details.

request\_write\_access

Boolean

*Optional*. Pass *True* to request the permission for your bot to send messages to the user.

#### [](#switchinlinequerychosenchat)SwitchInlineQueryChosenChat

This object represents an inline button that switches the current user to inline mode in a chosen chat, with an optional default inline query.

Field

Type

Description

query

String

*Optional*. The default inline query to be inserted in the input field. If left empty, only the bot's username will be inserted

allow\_user\_chats

Boolean

*Optional*. *True*, if private chats with users can be chosen

allow\_bot\_chats

Boolean

*Optional*. *True*, if private chats with bots can be chosen

allow\_group\_chats

Boolean

*Optional*. *True*, if group and supergroup chats can be chosen

allow\_channel\_chats

Boolean

*Optional*. *True*, if channel chats can be chosen

#### [](#copytextbutton)CopyTextButton

This object represents an inline keyboard button that copies specified text to the clipboard.

Field

Type

Description

text

String

The text to be copied to the clipboard; 1-256 characters

#### [](#callbackquery)CallbackQuery

This object represents an incoming callback query from a callback button in an [inline keyboard](/bots/features#inline-keyboards). If the button that originated the query was attached to a message sent by the bot, the field *message* will be present. If the button was attached to a message sent via the bot (in [inline mode](#inline-mode)), the field *inline\_message\_id* will be present. Exactly one of the fields *data* or *game\_short\_name* will be present.

Field

Type

Description

id

String

Unique identifier for this query

from

[User](#user)

Sender

message

[MaybeInaccessibleMessage](#maybeinaccessiblemessage)

*Optional*. Message sent by the bot with the callback button that originated the query

inline\_message\_id

String

*Optional*. Identifier of the message sent via the bot in inline mode, that originated the query.

chat\_instance

String

Global identifier, uniquely corresponding to the chat to which the message with the callback button was sent. Useful for high scores in [games](#games).

data

String

*Optional*. Data associated with the callback button. Be aware that the message originated the query can contain no callback buttons with this data.

game\_short\_name

String

*Optional*. Short name of a [Game](#games) to be returned, serves as the unique identifier for the game

> **NOTE:** After the user presses a callback button, Telegram clients will display a progress bar until you call [answerCallbackQuery](#answercallbackquery). It is, therefore, necessary to react by calling [answerCallbackQuery](#answercallbackquery) even if no notification to the user is needed (e.g., without specifying any of the optional parameters).

#### [](#forcereply)ForceReply

Upon receiving a message with this object, Telegram clients will display a reply interface to the user (act as if the user has selected the bot's message and tapped 'Reply'). This can be extremely useful if you want to create user-friendly step-by-step interfaces without having to sacrifice [privacy mode](/bots/features#privacy-mode). Not supported in channels and for messages sent on behalf of a Telegram Business account.

Field

Type

Description

force\_reply

True

Shows reply interface to the user, as if they manually selected the bot's message and tapped 'Reply'

input\_field\_placeholder

String

*Optional*. The placeholder to be shown in the input field when the reply is active; 1-64 characters

selective

Boolean

*Optional*. Use this parameter if you want to force reply from specific users only. Targets: 1) users that are @mentioned in the *text* of the [Message](#message) object; 2) if the bot's message is a reply to a message in the same chat and forum topic, sender of the original message.

> **Example:** A [poll bot](https://t.me/PollBot) for groups runs in privacy mode (only receives commands, replies to its messages and mentions). There could be two ways to create a new poll:
> 
> -   Explain the user how to send a command with parameters (e.g. /newpoll question answer1 answer2). May be appealing for hardcore users but lacks modern day polish.
> -   Guide the user through a step-by-step process. 'Please send me your question', 'Cool, now let's add the first answer option', 'Great. Keep adding answer options, then send /done when you're ready'.
> 
> The last option is definitely more attractive. And if you use [ForceReply](#forcereply) in your bot's questions, it will receive the user's answers even if it only receives replies, commands and mentions - without any extra work for the user.

#### [](#chatphoto)ChatPhoto

This object represents a chat photo.

Field

Type

Description

small\_file\_id

String

File identifier of small (160x160) chat photo. This file\_id can be used only for photo download and only for as long as the photo is not changed.

small\_file\_unique\_id

String

Unique file identifier of small (160x160) chat photo, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.

big\_file\_id

String

File identifier of big (640x640) chat photo. This file\_id can be used only for photo download and only for as long as the photo is not changed.

big\_file\_unique\_id

String

Unique file identifier of big (640x640) chat photo, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.

#### [](#chatinvitelink)ChatInviteLink

Represents an invite link for a chat.

Field

Type

Description

invite\_link

String

The invite link. If the link was created by another chat administrator, then the second part of the link will be replaced with “…”.

creator

[User](#user)

Creator of the link

creates\_join\_request

Boolean

*True*, if users joining the chat via the link need to be approved by chat administrators

is\_primary

Boolean

*True*, if the link is primary

is\_revoked

Boolean

*True*, if the link is revoked

name

String

*Optional*. Invite link name

expire\_date

Integer

*Optional*. Point in time (Unix timestamp) when the link will expire or has been expired

member\_limit

Integer

*Optional*. The maximum number of users that can be members of the chat simultaneously after joining the chat via this invite link; 1-99999

pending\_join\_request\_count

Integer

*Optional*. Number of pending join requests created using this link

subscription\_period

Integer

*Optional*. The number of seconds the subscription will be active for before the next payment

subscription\_price

Integer

*Optional*. The amount of Telegram Stars a user must pay initially and after each subsequent subscription period to be a member of the chat using the link

#### [](#chatadministratorrights)ChatAdministratorRights

Represents the rights of an administrator in a chat.

Field

Type

Description

is\_anonymous

Boolean

*True*, if the user's presence in the chat is hidden

can\_manage\_chat

Boolean

*True*, if the administrator can access the chat event log, get boost list, see hidden supergroup and channel members, report spam messages, ignore slow mode, and send messages to the chat without paying Telegram Stars. Implied by any other administrator privilege.

can\_delete\_messages

Boolean

*True*, if the administrator can delete messages of other users

can\_manage\_video\_chats

Boolean

*True*, if the administrator can manage video chats

can\_restrict\_members

Boolean

*True*, if the administrator can restrict, ban or unban chat members, or access supergroup statistics

can\_promote\_members

Boolean

*True*, if the administrator can add new administrators with a subset of their own privileges or demote administrators that they have promoted, directly or indirectly (promoted by administrators that were appointed by the user)

can\_change\_info

Boolean

*True*, if the user is allowed to change the chat title, photo and other settings

can\_invite\_users

Boolean

*True*, if the user is allowed to invite new users to the chat

can\_post\_stories

Boolean

*True*, if the administrator can post stories to the chat

can\_edit\_stories

Boolean

*True*, if the administrator can edit stories posted by other users, post stories to the chat page, pin chat stories, and access the chat's story archive

can\_delete\_stories

Boolean

*True*, if the administrator can delete stories posted by other users

can\_post\_messages

Boolean

*Optional*. *True*, if the administrator can post messages in the channel, approve suggested posts, or access channel statistics; for channels only

can\_edit\_messages

Boolean

*Optional*. *True*, if the administrator can edit messages of other users and can pin messages; for channels only

can\_pin\_messages

Boolean

*Optional*. *True*, if the user is allowed to pin messages; for groups and supergroups only

can\_manage\_topics

Boolean

*Optional*. *True*, if the user is allowed to create, rename, close, and reopen forum topics; for supergroups only

can\_manage\_direct\_messages

Boolean

*Optional*. *True*, if the administrator can manage direct messages of the channel and decline suggested posts; for channels only

#### [](#chatmemberupdated)ChatMemberUpdated

This object represents changes in the status of a chat member.

Field

Type

Description

chat

[Chat](#chat)

Chat the user belongs to

from

[User](#user)

Performer of the action, which resulted in the change

date

Integer

Date the change was done in Unix time

old\_chat\_member

[ChatMember](#chatmember)

Previous information about the chat member

new\_chat\_member

[ChatMember](#chatmember)

New information about the chat member

invite\_link

[ChatInviteLink](#chatinvitelink)

*Optional*. Chat invite link, which was used by the user to join the chat; for joining by invite link events only.

via\_join\_request

Boolean

*Optional*. *True*, if the user joined the chat after sending a direct join request without using an invite link and being approved by an administrator

via\_chat\_folder\_invite\_link

Boolean

*Optional*. *True*, if the user joined the chat via a chat folder invite link

#### [](#chatmember)ChatMember

This object contains information about one member of a chat. Currently, the following 6 types of chat members are supported:

-   [ChatMemberOwner](#chatmemberowner)
-   [ChatMemberAdministrator](#chatmemberadministrator)
-   [ChatMemberMember](#chatmembermember)
-   [ChatMemberRestricted](#chatmemberrestricted)
-   [ChatMemberLeft](#chatmemberleft)
-   [ChatMemberBanned](#chatmemberbanned)

#### [](#chatmemberowner)ChatMemberOwner

Represents a [chat member](#chatmember) that owns the chat and has all administrator privileges.

Field

Type

Description

status

String

The member's status in the chat, always “creator”

user

[User](#user)

Information about the user

is\_anonymous

Boolean

*True*, if the user's presence in the chat is hidden

custom\_title

String

*Optional*. Custom title for this user

#### [](#chatmemberadministrator)ChatMemberAdministrator

Represents a [chat member](#chatmember) that has some additional privileges.

Field

Type

Description

status

String

The member's status in the chat, always “administrator”

user

[User](#user)

Information about the user

can\_be\_edited

Boolean

*True*, if the bot is allowed to edit administrator privileges of that user

is\_anonymous

Boolean

*True*, if the user's presence in the chat is hidden

can\_manage\_chat

Boolean

*True*, if the administrator can access the chat event log, get boost list, see hidden supergroup and channel members, report spam messages, ignore slow mode, and send messages to the chat without paying Telegram Stars. Implied by any other administrator privilege.

can\_delete\_messages

Boolean

*True*, if the administrator can delete messages of other users

can\_manage\_video\_chats

Boolean

*True*, if the administrator can manage video chats

can\_restrict\_members

Boolean

*True*, if the administrator can restrict, ban or unban chat members, or access supergroup statistics

can\_promote\_members

Boolean

*True*, if the administrator can add new administrators with a subset of their own privileges or demote administrators that they have promoted, directly or indirectly (promoted by administrators that were appointed by the user)

can\_change\_info

Boolean

*True*, if the user is allowed to change the chat title, photo and other settings

can\_invite\_users

Boolean

*True*, if the user is allowed to invite new users to the chat

can\_post\_stories

Boolean

*True*, if the administrator can post stories to the chat

can\_edit\_stories

Boolean

*True*, if the administrator can edit stories posted by other users, post stories to the chat page, pin chat stories, and access the chat's story archive

can\_delete\_stories

Boolean

*True*, if the administrator can delete stories posted by other users

can\_post\_messages

Boolean

*Optional*. *True*, if the administrator can post messages in the channel, approve suggested posts, or access channel statistics; for channels only

can\_edit\_messages

Boolean

*Optional*. *True*, if the administrator can edit messages of other users and can pin messages; for channels only

can\_pin\_messages

Boolean

*Optional*. *True*, if the user is allowed to pin messages; for groups and supergroups only

can\_manage\_topics

Boolean

*Optional*. *True*, if the user is allowed to create, rename, close, and reopen forum topics; for supergroups only

can\_manage\_direct\_messages

Boolean

*Optional*. *True*, if the administrator can manage direct messages of the channel and decline suggested posts; for channels only

custom\_title

String

*Optional*. Custom title for this user

#### [](#chatmembermember)ChatMemberMember

Represents a [chat member](#chatmember) that has no additional privileges or restrictions.

Field

Type

Description

status

String

The member's status in the chat, always “member”

user

[User](#user)

Information about the user

until\_date

Integer

*Optional*. Date when the user's subscription will expire; Unix time

#### [](#chatmemberrestricted)ChatMemberRestricted

Represents a [chat member](#chatmember) that is under certain restrictions in the chat. Supergroups only.

Field

Type

Description

status

String

The member's status in the chat, always “restricted”

user

[User](#user)

Information about the user

is\_member

Boolean

*True*, if the user is a member of the chat at the moment of the request

can\_send\_messages

Boolean

*True*, if the user is allowed to send text messages, contacts, giveaways, giveaway winners, invoices, locations and venues

can\_send\_audios

Boolean

*True*, if the user is allowed to send audios

can\_send\_documents

Boolean

*True*, if the user is allowed to send documents

can\_send\_photos

Boolean

*True*, if the user is allowed to send photos

can\_send\_videos

Boolean

*True*, if the user is allowed to send videos

can\_send\_video\_notes

Boolean

*True*, if the user is allowed to send video notes

can\_send\_voice\_notes

Boolean

*True*, if the user is allowed to send voice notes

can\_send\_polls

Boolean

*True*, if the user is allowed to send polls and checklists

can\_send\_other\_messages

Boolean

*True*, if the user is allowed to send animations, games, stickers and use inline bots

can\_add\_web\_page\_previews

Boolean

*True*, if the user is allowed to add web page previews to their messages

can\_change\_info

Boolean

*True*, if the user is allowed to change the chat title, photo and other settings

can\_invite\_users

Boolean

*True*, if the user is allowed to invite new users to the chat

can\_pin\_messages

Boolean

*True*, if the user is allowed to pin messages

can\_manage\_topics

Boolean

*True*, if the user is allowed to create forum topics

until\_date

Integer

Date when restrictions will be lifted for this user; Unix time. If 0, then the user is restricted forever

#### [](#chatmemberleft)ChatMemberLeft

Represents a [chat member](#chatmember) that isn't currently a member of the chat, but may join it themselves.

Field

Type

Description

status

String

The member's status in the chat, always “left”

user

[User](#user)

Information about the user

#### [](#chatmemberbanned)ChatMemberBanned

Represents a [chat member](#chatmember) that was banned in the chat and can't return to the chat or view chat messages.

Field

Type

Description

status

String

The member's status in the chat, always “kicked”

user

[User](#user)

Information about the user

until\_date

Integer

Date when restrictions will be lifted for this user; Unix time. If 0, then the user is banned forever

#### [](#chatjoinrequest)ChatJoinRequest

Represents a join request sent to a chat.

Field

Type

Description

chat

[Chat](#chat)

Chat to which the request was sent

from

[User](#user)

User that sent the join request

user\_chat\_id

Integer

Identifier of a private chat with the user who sent the join request. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier. The bot can use this identifier for 5 minutes to send messages until the join request is processed, assuming no other administrator contacted the user.

date

Integer

Date the request was sent in Unix time

bio

String

*Optional*. Bio of the user.

invite\_link

[ChatInviteLink](#chatinvitelink)

*Optional*. Chat invite link that was used by the user to send the join request

#### [](#chatpermissions)ChatPermissions

Describes actions that a non-administrator user is allowed to take in a chat.

Field

Type

Description

can\_send\_messages

Boolean

*Optional*. *True*, if the user is allowed to send text messages, contacts, giveaways, giveaway winners, invoices, locations and venues

can\_send\_audios

Boolean

*Optional*. *True*, if the user is allowed to send audios

can\_send\_documents

Boolean

*Optional*. *True*, if the user is allowed to send documents

can\_send\_photos

Boolean

*Optional*. *True*, if the user is allowed to send photos

can\_send\_videos

Boolean

*Optional*. *True*, if the user is allowed to send videos

can\_send\_video\_notes

Boolean

*Optional*. *True*, if the user is allowed to send video notes

can\_send\_voice\_notes

Boolean

*Optional*. *True*, if the user is allowed to send voice notes

can\_send\_polls

Boolean

*Optional*. *True*, if the user is allowed to send polls and checklists

can\_send\_other\_messages

Boolean

*Optional*. *True*, if the user is allowed to send animations, games, stickers and use inline bots

can\_add\_web\_page\_previews

Boolean

*Optional*. *True*, if the user is allowed to add web page previews to their messages

can\_change\_info

Boolean

*Optional*. *True*, if the user is allowed to change the chat title, photo and other settings. Ignored in public supergroups

can\_invite\_users

Boolean

*Optional*. *True*, if the user is allowed to invite new users to the chat

can\_pin\_messages

Boolean

*Optional*. *True*, if the user is allowed to pin messages. Ignored in public supergroups

can\_manage\_topics

Boolean

*Optional*. *True*, if the user is allowed to create forum topics. If omitted defaults to the value of can\_pin\_messages

#### [](#birthdate)Birthdate

Describes the birthdate of a user.

Field

Type

Description

day

Integer

Day of the user's birth; 1-31

month

Integer

Month of the user's birth; 1-12

year

Integer

*Optional*. Year of the user's birth

#### [](#businessintro)BusinessIntro

Contains information about the start page settings of a Telegram Business account.

Field

Type

Description

title

String

*Optional*. Title text of the business intro

message

String

*Optional*. Message text of the business intro

sticker

[Sticker](#sticker)

*Optional*. Sticker of the business intro

#### [](#businesslocation)BusinessLocation

Contains information about the location of a Telegram Business account.

Field

Type

Description

address

String

Address of the business

location

[Location](#location)

*Optional*. Location of the business

#### [](#businessopeninghoursinterval)BusinessOpeningHoursInterval

Describes an interval of time during which a business is open.

Field

Type

Description

opening\_minute

Integer

The minute's sequence number in a week, starting on Monday, marking the start of the time interval during which the business is open; 0 - 7 \* 24 \* 60

closing\_minute

Integer

The minute's sequence number in a week, starting on Monday, marking the end of the time interval during which the business is open; 0 - 8 \* 24 \* 60

#### [](#businessopeninghours)BusinessOpeningHours

Describes the opening hours of a business.

Field

Type

Description

time\_zone\_name

String

Unique name of the time zone for which the opening hours are defined

opening\_hours

Array of [BusinessOpeningHoursInterval](#businessopeninghoursinterval)

List of time intervals describing business opening hours

#### [](#userrating)UserRating

This object describes the rating of a user based on their Telegram Star spendings.

Field

Type

Description

level

Integer

Current level of the user, indicating their reliability when purchasing digital goods and services. A higher level suggests a more trustworthy customer; a negative level is likely reason for concern.

rating

Integer

Numerical value of the user's rating; the higher the rating, the better

current\_level\_rating

Integer

The rating value required to get the current level

next\_level\_rating

Integer

*Optional*. The rating value required to get to the next level; omitted if the maximum level was reached

#### [](#storyareaposition)StoryAreaPosition

Describes the position of a clickable area within a story.

Field

Type

Description

x\_percentage

Float

The abscissa of the area's center, as a percentage of the media width

y\_percentage

Float

The ordinate of the area's center, as a percentage of the media height

width\_percentage

Float

The width of the area's rectangle, as a percentage of the media width

height\_percentage

Float

The height of the area's rectangle, as a percentage of the media height

rotation\_angle

Float

The clockwise rotation angle of the rectangle, in degrees; 0-360

corner\_radius\_percentage

Float

The radius of the rectangle corner rounding, as a percentage of the media width

#### [](#locationaddress)LocationAddress

Describes the physical address of a location.

Field

Type

Description

country\_code

String

The two-letter ISO 3166-1 alpha-2 country code of the country where the location is located

state

String

*Optional*. State of the location

city

String

*Optional*. City of the location

street

String

*Optional*. Street address of the location

#### [](#storyareatype)StoryAreaType

Describes the type of a clickable area on a story. Currently, it can be one of

-   [StoryAreaTypeLocation](#storyareatypelocation)
-   [StoryAreaTypeSuggestedReaction](#storyareatypesuggestedreaction)
-   [StoryAreaTypeLink](#storyareatypelink)
-   [StoryAreaTypeWeather](#storyareatypeweather)
-   [StoryAreaTypeUniqueGift](#storyareatypeuniquegift)

#### [](#storyareatypelocation)StoryAreaTypeLocation

Describes a story area pointing to a location. Currently, a story can have up to 10 location areas.

Field

Type

Description

type

String

Type of the area, always “location”

latitude

Float

Location latitude in degrees

longitude

Float

Location longitude in degrees

address

[LocationAddress](#locationaddress)

*Optional*. Address of the location

#### [](#storyareatypesuggestedreaction)StoryAreaTypeSuggestedReaction

Describes a story area pointing to a suggested reaction. Currently, a story can have up to 5 suggested reaction areas.

Field

Type

Description

type

String

Type of the area, always “suggested\_reaction”

reaction\_type

[ReactionType](#reactiontype)

Type of the reaction

is\_dark

Boolean

*Optional*. Pass *True* if the reaction area has a dark background

is\_flipped

Boolean

*Optional*. Pass *True* if reaction area corner is flipped

#### [](#storyareatypelink)StoryAreaTypeLink

Describes a story area pointing to an HTTP or tg:// link. Currently, a story can have up to 3 link areas.

Field

Type

Description

type

String

Type of the area, always “link”

url

String

HTTP or tg:// URL to be opened when the area is clicked

#### [](#storyareatypeweather)StoryAreaTypeWeather

Describes a story area containing weather information. Currently, a story can have up to 3 weather areas.

Field

Type

Description

type

String

Type of the area, always “weather”

temperature

Float

Temperature, in degree Celsius

emoji

String

Emoji representing the weather

background\_color

Integer

A color of the area background in the ARGB format

#### [](#storyareatypeuniquegift)StoryAreaTypeUniqueGift

Describes a story area pointing to a unique gift. Currently, a story can have at most 1 unique gift area.

Field

Type

Description

type

String

Type of the area, always “unique\_gift”

name

String

Unique name of the gift

#### [](#storyarea)StoryArea

Describes a clickable area on a story media.

Field

Type

Description

position

[StoryAreaPosition](#storyareaposition)

Position of the area

type

[StoryAreaType](#storyareatype)

Type of the area

#### [](#chatlocation)ChatLocation

Represents a location to which a chat is connected.

Field

Type

Description

location

[Location](#location)

The location to which the supergroup is connected. Can't be a live location.

address

String

Location address; 1-64 characters, as defined by the chat owner

#### [](#reactiontype)ReactionType

This object describes the type of a reaction. Currently, it can be one of

-   [ReactionTypeEmoji](#reactiontypeemoji)
-   [ReactionTypeCustomEmoji](#reactiontypecustomemoji)
-   [ReactionTypePaid](#reactiontypepaid)

#### [](#reactiontypeemoji)ReactionTypeEmoji

The reaction is based on an emoji.

Field

Type

Description

type

String

Type of the reaction, always “emoji”

emoji

String

Reaction emoji. Currently, it can be one of "![❤](//telegram.org/img/emoji/40/E29DA4.png)", "![👍](//telegram.org/img/emoji/40/F09F918D.png)", "![👎](//telegram.org/img/emoji/40/F09F918E.png)", "![🔥](//telegram.org/img/emoji/40/F09F94A5.png)", "![🥰](//telegram.org/img/emoji/40/F09FA5B0.png)", "![👏](//telegram.org/img/emoji/40/F09F918F.png)", "![😁](//telegram.org/img/emoji/40/F09F9881.png)", "![🤔](//telegram.org/img/emoji/40/F09FA494.png)", "![🤯](//telegram.org/img/emoji/40/F09FA4AF.png)", "![😱](//telegram.org/img/emoji/40/F09F98B1.png)", "![🤬](//telegram.org/img/emoji/40/F09FA4AC.png)", "![😢](//telegram.org/img/emoji/40/F09F98A2.png)", "![🎉](//telegram.org/img/emoji/40/F09F8E89.png)", "![🤩](//telegram.org/img/emoji/40/F09FA4A9.png)", "![🤮](//telegram.org/img/emoji/40/F09FA4AE.png)", "![💩](//telegram.org/img/emoji/40/F09F92A9.png)", "![🙏](//telegram.org/img/emoji/40/F09F998F.png)", "![👌](//telegram.org/img/emoji/40/F09F918C.png)", "![🕊](//telegram.org/img/emoji/40/F09F958A.png)", "![🤡](//telegram.org/img/emoji/40/F09FA4A1.png)", "![🥱](//telegram.org/img/emoji/40/F09FA5B1.png)", "![🥴](//telegram.org/img/emoji/40/F09FA5B4.png)", "![😍](//telegram.org/img/emoji/40/F09F988D.png)", "![🐳](//telegram.org/img/emoji/40/F09F90B3.png)", "![❤‍🔥](//telegram.org/img/emoji/40/E29DA4E2808DF09F94A5.png)", "![🌚](//telegram.org/img/emoji/40/F09F8C9A.png)", "![🌭](//telegram.org/img/emoji/40/F09F8CAD.png)", "![💯](//telegram.org/img/emoji/40/F09F92AF.png)", "![🤣](//telegram.org/img/emoji/40/F09FA4A3.png)", "![⚡](//telegram.org/img/emoji/40/E29AA1.png)", "![🍌](//telegram.org/img/emoji/40/F09F8D8C.png)", "![🏆](//telegram.org/img/emoji/40/F09F8F86.png)", "![💔](//telegram.org/img/emoji/40/F09F9294.png)", "![🤨](//telegram.org/img/emoji/40/F09FA4A8.png)", "![😐](//telegram.org/img/emoji/40/F09F9890.png)", "![🍓](//telegram.org/img/emoji/40/F09F8D93.png)", "![🍾](//telegram.org/img/emoji/40/F09F8DBE.png)", "![💋](//telegram.org/img/emoji/40/F09F928B.png)", "![🖕](//telegram.org/img/emoji/40/F09F9695.png)", "![😈](//telegram.org/img/emoji/40/F09F9888.png)", "![😴](//telegram.org/img/emoji/40/F09F98B4.png)", "![😭](//telegram.org/img/emoji/40/F09F98AD.png)", "![🤓](//telegram.org/img/emoji/40/F09FA493.png)", "![👻](//telegram.org/img/emoji/40/F09F91BB.png)", "![👨‍💻](//telegram.org/img/emoji/40/F09F91A8E2808DF09F92BB.png)", "![👀](//telegram.org/img/emoji/40/F09F9180.png)", "![🎃](//telegram.org/img/emoji/40/F09F8E83.png)", "![🙈](//telegram.org/img/emoji/40/F09F9988.png)", "![😇](//telegram.org/img/emoji/40/F09F9887.png)", "![😨](//telegram.org/img/emoji/40/F09F98A8.png)", "![🤝](//telegram.org/img/emoji/40/F09FA49D.png)", "![✍](//telegram.org/img/emoji/40/E29C8D.png)", "![🤗](//telegram.org/img/emoji/40/F09FA497.png)", "![🫡](//telegram.org/img/emoji/40/F09FABA1.png)", "![🎅](//telegram.org/img/emoji/40/F09F8E85.png)", "![🎄](//telegram.org/img/emoji/40/F09F8E84.png)", "![☃](//telegram.org/img/emoji/40/E29883.png)", "![💅](//telegram.org/img/emoji/40/F09F9285.png)", "![🤪](//telegram.org/img/emoji/40/F09FA4AA.png)", "![🗿](//telegram.org/img/emoji/40/F09F97BF.png)", "![🆒](//telegram.org/img/emoji/40/F09F8692.png)", "![💘](//telegram.org/img/emoji/40/F09F9298.png)", "![🙉](//telegram.org/img/emoji/40/F09F9989.png)", "![🦄](//telegram.org/img/emoji/40/F09FA684.png)", "![😘](//telegram.org/img/emoji/40/F09F9898.png)", "![💊](//telegram.org/img/emoji/40/F09F928A.png)", "![🙊](//telegram.org/img/emoji/40/F09F998A.png)", "![😎](//telegram.org/img/emoji/40/F09F988E.png)", "![👾](//telegram.org/img/emoji/40/F09F91BE.png)", "![🤷‍♂](//telegram.org/img/emoji/40/F09FA4B7E2808DE29982.png)", "![🤷](//telegram.org/img/emoji/40/F09FA4B7.png)", "![🤷‍♀](//telegram.org/img/emoji/40/F09FA4B7E2808DE29980.png)", "![😡](//telegram.org/img/emoji/40/F09F98A1.png)"

#### [](#reactiontypecustomemoji)ReactionTypeCustomEmoji

The reaction is based on a custom emoji.

Field

Type

Description

type

String

Type of the reaction, always “custom\_emoji”

custom\_emoji\_id

String

Custom emoji identifier

#### [](#reactiontypepaid)ReactionTypePaid

The reaction is paid.

Field

Type

Description

type

String

Type of the reaction, always “paid”

#### [](#reactioncount)ReactionCount

Represents a reaction added to a message along with the number of times it was added.

Field

Type

Description

type

[ReactionType](#reactiontype)

Type of the reaction

total\_count

Integer

Number of times the reaction was added

#### [](#messagereactionupdated)MessageReactionUpdated

This object represents a change of a reaction on a message performed by a user.

Field

Type

Description

chat

[Chat](#chat)

The chat containing the message the user reacted to

message\_id

Integer

Unique identifier of the message inside the chat

user

[User](#user)

*Optional*. The user that changed the reaction, if the user isn't anonymous

actor\_chat

[Chat](#chat)

*Optional*. The chat on behalf of which the reaction was changed, if the user is anonymous

date

Integer

Date of the change in Unix time

old\_reaction

Array of [ReactionType](#reactiontype)

Previous list of reaction types that were set by the user

new\_reaction

Array of [ReactionType](#reactiontype)

New list of reaction types that have been set by the user

#### [](#messagereactioncountupdated)MessageReactionCountUpdated

This object represents reaction changes on a message with anonymous reactions.

Field

Type

Description

chat

[Chat](#chat)

The chat containing the message

message\_id

Integer

Unique message identifier inside the chat

date

Integer

Date of the change in Unix time

reactions

Array of [ReactionCount](#reactioncount)

List of reactions that are present on the message

#### [](#forumtopic)ForumTopic

This object represents a forum topic.

Field

Type

Description

message\_thread\_id

Integer

Unique identifier of the forum topic

name

String

Name of the topic

icon\_color

Integer

Color of the topic icon in RGB format

icon\_custom\_emoji\_id

String

*Optional*. Unique identifier of the custom emoji shown as the topic icon

is\_name\_implicit

True

*Optional*. *True*, if the name of the topic wasn't specified explicitly by its creator and likely needs to be changed by the bot

#### [](#giftbackground)GiftBackground

This object describes the background of a gift.

Field

Type

Description

center\_color

Integer

Center color of the background in RGB format

edge\_color

Integer

Edge color of the background in RGB format

text\_color

Integer

Text color of the background in RGB format

#### [](#gift)Gift

This object represents a gift that can be sent by the bot.

Field

Type

Description

id

String

Unique identifier of the gift

sticker

[Sticker](#sticker)

The sticker that represents the gift

star\_count

Integer

The number of Telegram Stars that must be paid to send the sticker

upgrade\_star\_count

Integer

*Optional*. The number of Telegram Stars that must be paid to upgrade the gift to a unique one

is\_premium

True

*Optional*. *True*, if the gift can only be purchased by Telegram Premium subscribers

has\_colors

True

*Optional*. *True*, if the gift can be used (after being upgraded) to customize a user's appearance

total\_count

Integer

*Optional*. The total number of gifts of this type that can be sent by all users; for limited gifts only

remaining\_count

Integer

*Optional*. The number of remaining gifts of this type that can be sent by all users; for limited gifts only

personal\_total\_count

Integer

*Optional*. The total number of gifts of this type that can be sent by the bot; for limited gifts only

personal\_remaining\_count

Integer

*Optional*. The number of remaining gifts of this type that can be sent by the bot; for limited gifts only

background

[GiftBackground](#giftbackground)

*Optional*. Background of the gift

unique\_gift\_variant\_count

Integer

*Optional*. The total number of different unique gifts that can be obtained by upgrading the gift

publisher\_chat

[Chat](#chat)

*Optional*. Information about the chat that published the gift

#### [](#gifts)Gifts

This object represent a list of gifts.

Field

Type

Description

gifts

Array of [Gift](#gift)

The list of gifts

#### [](#uniquegiftmodel)UniqueGiftModel

This object describes the model of a unique gift.

Field

Type

Description

name

String

Name of the model

sticker

[Sticker](#sticker)

The sticker that represents the unique gift

rarity\_per\_mille

Integer

The number of unique gifts that receive this model for every 1000 gifts upgraded

#### [](#uniquegiftsymbol)UniqueGiftSymbol

This object describes the symbol shown on the pattern of a unique gift.

Field

Type

Description

name

String

Name of the symbol

sticker

[Sticker](#sticker)

The sticker that represents the unique gift

rarity\_per\_mille

Integer

The number of unique gifts that receive this model for every 1000 gifts upgraded

#### [](#uniquegiftbackdropcolors)UniqueGiftBackdropColors

This object describes the colors of the backdrop of a unique gift.

Field

Type

Description

center\_color

Integer

The color in the center of the backdrop in RGB format

edge\_color

Integer

The color on the edges of the backdrop in RGB format

symbol\_color

Integer

The color to be applied to the symbol in RGB format

text\_color

Integer

The color for the text on the backdrop in RGB format

#### [](#uniquegiftbackdrop)UniqueGiftBackdrop

This object describes the backdrop of a unique gift.

Field

Type

Description

name

String

Name of the backdrop

colors

[UniqueGiftBackdropColors](#uniquegiftbackdropcolors)

Colors of the backdrop

rarity\_per\_mille

Integer

The number of unique gifts that receive this backdrop for every 1000 gifts upgraded

#### [](#uniquegiftcolors)UniqueGiftColors

This object contains information about the color scheme for a user's name, message replies and link previews based on a unique gift.

Field

Type

Description

model\_custom\_emoji\_id

String

Custom emoji identifier of the unique gift's model

symbol\_custom\_emoji\_id

String

Custom emoji identifier of the unique gift's symbol

light\_theme\_main\_color

Integer

Main color used in light themes; RGB format

light\_theme\_other\_colors

Array of Integer

List of 1-3 additional colors used in light themes; RGB format

dark\_theme\_main\_color

Integer

Main color used in dark themes; RGB format

dark\_theme\_other\_colors

Array of Integer

List of 1-3 additional colors used in dark themes; RGB format

#### [](#uniquegift)UniqueGift

This object describes a unique gift that was upgraded from a regular gift.

Field

Type

Description

gift\_id

String

Identifier of the regular gift from which the gift was upgraded

base\_name

String

Human-readable name of the regular gift from which this unique gift was upgraded

name

String

Unique name of the gift. This name can be used in `https://t.me/nft/...` links and story areas

number

Integer

Unique number of the upgraded gift among gifts upgraded from the same regular gift

model

[UniqueGiftModel](#uniquegiftmodel)

Model of the gift

symbol

[UniqueGiftSymbol](#uniquegiftsymbol)

Symbol of the gift

backdrop

[UniqueGiftBackdrop](#uniquegiftbackdrop)

Backdrop of the gift

is\_premium

True

*Optional*. *True*, if the original regular gift was exclusively purchaseable by Telegram Premium subscribers

is\_from\_blockchain

True

*Optional*. *True*, if the gift is assigned from the TON blockchain and can't be resold or transferred in Telegram

colors

[UniqueGiftColors](#uniquegiftcolors)

*Optional*. The color scheme that can be used by the gift's owner for the chat's name, replies to messages and link previews; for business account gifts and gifts that are currently on sale only

publisher\_chat

[Chat](#chat)

*Optional*. Information about the chat that published the gift

#### [](#giftinfo)GiftInfo

Describes a service message about a regular gift that was sent or received.

Field

Type

Description

gift

[Gift](#gift)

Information about the gift

owned\_gift\_id

String

*Optional*. Unique identifier of the received gift for the bot; only present for gifts received on behalf of business accounts

convert\_star\_count

Integer

*Optional*. Number of Telegram Stars that can be claimed by the receiver by converting the gift; omitted if conversion to Telegram Stars is impossible

prepaid\_upgrade\_star\_count

Integer

*Optional*. Number of Telegram Stars that were prepaid for the ability to upgrade the gift

is\_upgrade\_separate

True

*Optional*. *True*, if the gift's upgrade was purchased after the gift was sent

can\_be\_upgraded

True

*Optional*. *True*, if the gift can be upgraded to a unique gift

text

String

*Optional*. Text of the message that was added to the gift

entities

Array of [MessageEntity](#messageentity)

*Optional*. Special entities that appear in the text

is\_private

True

*Optional*. *True*, if the sender and gift text are shown only to the gift receiver; otherwise, everyone will be able to see them

unique\_gift\_number

Integer

*Optional*. Unique number reserved for this gift when upgraded. See the *number* field in [UniqueGift](#uniquegift)

#### [](#uniquegiftinfo)UniqueGiftInfo

Describes a service message about a unique gift that was sent or received.

Field

Type

Description

gift

[UniqueGift](#uniquegift)

Information about the gift

origin

String

Origin of the gift. Currently, either “upgrade” for gifts upgraded from regular gifts, “transfer” for gifts transferred from other users or channels, “resale” for gifts bought from other users, “gifted\_upgrade” for upgrades purchased after the gift was sent, or “offer” for gifts bought or sold through gift purchase offers

last\_resale\_currency

String

*Optional*. For gifts bought from other users, the currency in which the payment for the gift was done. Currently, one of “XTR” for Telegram Stars or “TON” for toncoins.

last\_resale\_amount

Integer

*Optional*. For gifts bought from other users, the price paid for the gift in either Telegram Stars or nanotoncoins

owned\_gift\_id

String

*Optional*. Unique identifier of the received gift for the bot; only present for gifts received on behalf of business accounts

transfer\_star\_count

Integer

*Optional*. Number of Telegram Stars that must be paid to transfer the gift; omitted if the bot cannot transfer the gift

next\_transfer\_date

Integer

*Optional*. Point in time (Unix timestamp) when the gift can be transferred. If it is in the past, then the gift can be transferred now

#### [](#ownedgift)OwnedGift

This object describes a gift received and owned by a user or a chat. Currently, it can be one of

-   [OwnedGiftRegular](#ownedgiftregular)
-   [OwnedGiftUnique](#ownedgiftunique)

#### [](#ownedgiftregular)OwnedGiftRegular

Describes a regular gift owned by a user or a chat.

Field

Type

Description

type

String

Type of the gift, always “regular”

gift

[Gift](#gift)

Information about the regular gift

owned\_gift\_id

String

*Optional*. Unique identifier of the gift for the bot; for gifts received on behalf of business accounts only

sender\_user

[User](#user)

*Optional*. Sender of the gift if it is a known user

send\_date

Integer

Date the gift was sent in Unix time

text

String

*Optional*. Text of the message that was added to the gift

entities

Array of [MessageEntity](#messageentity)

*Optional*. Special entities that appear in the text

is\_private

True

*Optional*. *True*, if the sender and gift text are shown only to the gift receiver; otherwise, everyone will be able to see them

is\_saved

True

*Optional*. *True*, if the gift is displayed on the account's profile page; for gifts received on behalf of business accounts only

can\_be\_upgraded

True

*Optional*. *True*, if the gift can be upgraded to a unique gift; for gifts received on behalf of business accounts only

was\_refunded

True

*Optional*. *True*, if the gift was refunded and isn't available anymore

convert\_star\_count

Integer

*Optional*. Number of Telegram Stars that can be claimed by the receiver instead of the gift; omitted if the gift cannot be converted to Telegram Stars; for gifts received on behalf of business accounts only

prepaid\_upgrade\_star\_count

Integer

*Optional*. Number of Telegram Stars that were paid for the ability to upgrade the gift

is\_upgrade\_separate

True

*Optional*. *True*, if the gift's upgrade was purchased after the gift was sent; for gifts received on behalf of business accounts only

unique\_gift\_number

Integer

*Optional*. Unique number reserved for this gift when upgraded. See the *number* field in [UniqueGift](#uniquegift)

#### [](#ownedgiftunique)OwnedGiftUnique

Describes a unique gift received and owned by a user or a chat.

Field

Type

Description

type

String

Type of the gift, always “unique”

gift

[UniqueGift](#uniquegift)

Information about the unique gift

owned\_gift\_id

String

*Optional*. Unique identifier of the received gift for the bot; for gifts received on behalf of business accounts only

sender\_user

[User](#user)

*Optional*. Sender of the gift if it is a known user

send\_date

Integer

Date the gift was sent in Unix time

is\_saved

True

*Optional*. *True*, if the gift is displayed on the account's profile page; for gifts received on behalf of business accounts only

can\_be\_transferred

True

*Optional*. *True*, if the gift can be transferred to another owner; for gifts received on behalf of business accounts only

transfer\_star\_count

Integer

*Optional*. Number of Telegram Stars that must be paid to transfer the gift; omitted if the bot cannot transfer the gift

next\_transfer\_date

Integer

*Optional*. Point in time (Unix timestamp) when the gift can be transferred. If it is in the past, then the gift can be transferred now

#### [](#ownedgifts)OwnedGifts

Contains the list of gifts received and owned by a user or a chat.

Field

Type

Description

total\_count

Integer

The total number of gifts owned by the user or the chat

gifts

Array of [OwnedGift](#ownedgift)

The list of gifts

next\_offset

String

*Optional*. Offset for the next request. If empty, then there are no more results

#### [](#acceptedgifttypes)AcceptedGiftTypes

This object describes the types of gifts that can be gifted to a user or a chat.

Field

Type

Description

unlimited\_gifts

Boolean

*True*, if unlimited regular gifts are accepted

limited\_gifts

Boolean

*True*, if limited regular gifts are accepted

unique\_gifts

Boolean

*True*, if unique gifts or gifts that can be upgraded to unique for free are accepted

premium\_subscription

Boolean

*True*, if a Telegram Premium subscription is accepted

gifts\_from\_channels

Boolean

*True*, if transfers of unique gifts from channels are accepted

#### [](#staramount)StarAmount

Describes an amount of Telegram Stars.

Field

Type

Description

amount

Integer

Integer amount of Telegram Stars, rounded to 0; can be negative

nanostar\_amount

Integer

*Optional*. The number of 1/1000000000 shares of Telegram Stars; from -999999999 to 999999999; can be negative if and only if *amount* is non-positive

#### [](#botcommand)BotCommand

This object represents a bot command.

Field

Type

Description

command

String

Text of the command; 1-32 characters. Can contain only lowercase English letters, digits and underscores.

description

String

Description of the command; 1-256 characters.

#### [](#botcommandscope)BotCommandScope

This object represents the scope to which bot commands are applied. Currently, the following 7 scopes are supported:

-   [BotCommandScopeDefault](#botcommandscopedefault)
-   [BotCommandScopeAllPrivateChats](#botcommandscopeallprivatechats)
-   [BotCommandScopeAllGroupChats](#botcommandscopeallgroupchats)
-   [BotCommandScopeAllChatAdministrators](#botcommandscopeallchatadministrators)
-   [BotCommandScopeChat](#botcommandscopechat)
-   [BotCommandScopeChatAdministrators](#botcommandscopechatadministrators)
-   [BotCommandScopeChatMember](#botcommandscopechatmember)

#### [](#determining-list-of-commands)Determining list of commands

The following algorithm is used to determine the list of commands for a particular user viewing the bot menu. The first list of commands which is set is returned:

**Commands in the chat with the bot**

-   botCommandScopeChat + language\_code
-   botCommandScopeChat
-   botCommandScopeAllPrivateChats + language\_code
-   botCommandScopeAllPrivateChats
-   botCommandScopeDefault + language\_code
-   botCommandScopeDefault

**Commands in group and supergroup chats**

-   botCommandScopeChatMember + language\_code
-   botCommandScopeChatMember
-   botCommandScopeChatAdministrators + language\_code (administrators only)
-   botCommandScopeChatAdministrators (administrators only)
-   botCommandScopeChat + language\_code
-   botCommandScopeChat
-   botCommandScopeAllChatAdministrators + language\_code (administrators only)
-   botCommandScopeAllChatAdministrators (administrators only)
-   botCommandScopeAllGroupChats + language\_code
-   botCommandScopeAllGroupChats
-   botCommandScopeDefault + language\_code
-   botCommandScopeDefault

#### [](#botcommandscopedefault)BotCommandScopeDefault

Represents the default [scope](#botcommandscope) of bot commands. Default commands are used if no commands with a [narrower scope](#determining-list-of-commands) are specified for the user.

Field

Type

Description

type

String

Scope type, must be *default*

#### [](#botcommandscopeallprivatechats)BotCommandScopeAllPrivateChats

Represents the [scope](#botcommandscope) of bot commands, covering all private chats.

Field

Type

Description

type

String

Scope type, must be *all\_private\_chats*

#### [](#botcommandscopeallgroupchats)BotCommandScopeAllGroupChats

Represents the [scope](#botcommandscope) of bot commands, covering all group and supergroup chats.

Field

Type

Description

type

String

Scope type, must be *all\_group\_chats*

#### [](#botcommandscopeallchatadministrators)BotCommandScopeAllChatAdministrators

Represents the [scope](#botcommandscope) of bot commands, covering all group and supergroup chat administrators.

Field

Type

Description

type

String

Scope type, must be *all\_chat\_administrators*

#### [](#botcommandscopechat)BotCommandScopeChat

Represents the [scope](#botcommandscope) of bot commands, covering a specific chat.

Field

Type

Description

type

String

Scope type, must be *chat*

chat\_id

Integer or String

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`). Channel direct messages chats and channel chats aren't supported.

#### [](#botcommandscopechatadministrators)BotCommandScopeChatAdministrators

Represents the [scope](#botcommandscope) of bot commands, covering all administrators of a specific group or supergroup chat.

Field

Type

Description

type

String

Scope type, must be *chat\_administrators*

chat\_id

Integer or String

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`). Channel direct messages chats and channel chats aren't supported.

#### [](#botcommandscopechatmember)BotCommandScopeChatMember

Represents the [scope](#botcommandscope) of bot commands, covering a specific member of a group or supergroup chat.

Field

Type

Description

type

String

Scope type, must be *chat\_member*

chat\_id

Integer or String

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`). Channel direct messages chats and channel chats aren't supported.

user\_id

Integer

Unique identifier of the target user

#### [](#botname)BotName

This object represents the bot's name.

Field

Type

Description

name

String

The bot's name

#### [](#botdescription)BotDescription

This object represents the bot's description.

Field

Type

Description

description

String

The bot's description

#### [](#botshortdescription)BotShortDescription

This object represents the bot's short description.

Field

Type

Description

short\_description

String

The bot's short description

#### [](#menubutton)MenuButton

This object describes the bot's menu button in a private chat. It should be one of

-   [MenuButtonCommands](#menubuttoncommands)
-   [MenuButtonWebApp](#menubuttonwebapp)
-   [MenuButtonDefault](#menubuttondefault)

If a menu button other than [MenuButtonDefault](#menubuttondefault) is set for a private chat, then it is applied in the chat. Otherwise the default menu button is applied. By default, the menu button opens the list of bot commands.

#### [](#menubuttoncommands)MenuButtonCommands

Represents a menu button, which opens the bot's list of commands.

Field

Type

Description

type

String

Type of the button, must be *commands*

#### [](#menubuttonwebapp)MenuButtonWebApp

Represents a menu button, which launches a [Web App](/bots/webapps).

Field

Type

Description

type

String

Type of the button, must be *web\_app*

text

String

Text on the button

web\_app

[WebAppInfo](#webappinfo)

Description of the Web App that will be launched when the user presses the button. The Web App will be able to send an arbitrary message on behalf of the user using the method [answerWebAppQuery](#answerwebappquery). Alternatively, a `t.me` link to a Web App of the bot can be specified in the object instead of the Web App's URL, in which case the Web App will be opened as if the user pressed the link.

#### [](#menubuttondefault)MenuButtonDefault

Describes that no specific value for the menu button was set.

Field

Type

Description

type

String

Type of the button, must be *default*

#### [](#chatboostsource)ChatBoostSource

This object describes the source of a chat boost. It can be one of

-   [ChatBoostSourcePremium](#chatboostsourcepremium)
-   [ChatBoostSourceGiftCode](#chatboostsourcegiftcode)
-   [ChatBoostSourceGiveaway](#chatboostsourcegiveaway)

#### [](#chatboostsourcepremium)ChatBoostSourcePremium

The boost was obtained by subscribing to Telegram Premium or by gifting a Telegram Premium subscription to another user.

Field

Type

Description

source

String

Source of the boost, always “premium”

user

[User](#user)

User that boosted the chat

#### [](#chatboostsourcegiftcode)ChatBoostSourceGiftCode

The boost was obtained by the creation of Telegram Premium gift codes to boost a chat. Each such code boosts the chat 4 times for the duration of the corresponding Telegram Premium subscription.

Field

Type

Description

source

String

Source of the boost, always “gift\_code”

user

[User](#user)

User for which the gift code was created

#### [](#chatboostsourcegiveaway)ChatBoostSourceGiveaway

The boost was obtained by the creation of a Telegram Premium or a Telegram Star giveaway. This boosts the chat 4 times for the duration of the corresponding Telegram Premium subscription for Telegram Premium giveaways and *prize\_star\_count* / 500 times for one year for Telegram Star giveaways.

Field

Type

Description

source

String

Source of the boost, always “giveaway”

giveaway\_message\_id

Integer

Identifier of a message in the chat with the giveaway; the message could have been deleted already. May be 0 if the message isn't sent yet.

user

[User](#user)

*Optional*. User that won the prize in the giveaway if any; for Telegram Premium giveaways only

prize\_star\_count

Integer

*Optional*. The number of Telegram Stars to be split between giveaway winners; for Telegram Star giveaways only

is\_unclaimed

True

*Optional*. *True*, if the giveaway was completed, but there was no user to win the prize

#### [](#chatboost)ChatBoost

This object contains information about a chat boost.

Field

Type

Description

boost\_id

String

Unique identifier of the boost

add\_date

Integer

Point in time (Unix timestamp) when the chat was boosted

expiration\_date

Integer

Point in time (Unix timestamp) when the boost will automatically expire, unless the booster's Telegram Premium subscription is prolonged

source

[ChatBoostSource](#chatboostsource)

Source of the added boost

#### [](#chatboostupdated)ChatBoostUpdated

This object represents a boost added to a chat or changed.

Field

Type

Description

chat

[Chat](#chat)

Chat which was boosted

boost

[ChatBoost](#chatboost)

Information about the chat boost

#### [](#chatboostremoved)ChatBoostRemoved

This object represents a boost removed from a chat.

Field

Type

Description

chat

[Chat](#chat)

Chat which was boosted

boost\_id

String

Unique identifier of the boost

remove\_date

Integer

Point in time (Unix timestamp) when the boost was removed

source

[ChatBoostSource](#chatboostsource)

Source of the removed boost

#### [](#userchatboosts)UserChatBoosts

This object represents a list of boosts added to a chat by a user.

Field

Type

Description

boosts

Array of [ChatBoost](#chatboost)

The list of boosts added to the chat by the user

#### [](#businessbotrights)BusinessBotRights

Represents the rights of a business bot.

Field

Type

Description

can\_reply

True

*Optional*. *True*, if the bot can send and edit messages in the private chats that had incoming messages in the last 24 hours

can\_read\_messages

True

*Optional*. *True*, if the bot can mark incoming private messages as read

can\_delete\_sent\_messages

True

*Optional*. *True*, if the bot can delete messages sent by the bot

can\_delete\_all\_messages

True

*Optional*. *True*, if the bot can delete all private messages in managed chats

can\_edit\_name

True

*Optional*. *True*, if the bot can edit the first and last name of the business account

can\_edit\_bio

True

*Optional*. *True*, if the bot can edit the bio of the business account

can\_edit\_profile\_photo

True

*Optional*. *True*, if the bot can edit the profile photo of the business account

can\_edit\_username

True

*Optional*. *True*, if the bot can edit the username of the business account

can\_change\_gift\_settings

True

*Optional*. *True*, if the bot can change the privacy settings pertaining to gifts for the business account

can\_view\_gifts\_and\_stars

True

*Optional*. *True*, if the bot can view gifts and the amount of Telegram Stars owned by the business account

can\_convert\_gifts\_to\_stars

True

*Optional*. *True*, if the bot can convert regular gifts owned by the business account to Telegram Stars

can\_transfer\_and\_upgrade\_gifts

True

*Optional*. *True*, if the bot can transfer and upgrade gifts owned by the business account

can\_transfer\_stars

True

*Optional*. *True*, if the bot can transfer Telegram Stars received by the business account to its own account, or use them to upgrade and transfer gifts

can\_manage\_stories

True

*Optional*. *True*, if the bot can post, edit and delete stories on behalf of the business account

#### [](#businessconnection)BusinessConnection

Describes the connection of the bot with a business account.

Field

Type

Description

id

String

Unique identifier of the business connection

user

[User](#user)

Business account user that created the business connection

user\_chat\_id

Integer

Identifier of a private chat with the user who created the business connection. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier.

date

Integer

Date the connection was established in Unix time

rights

[BusinessBotRights](#businessbotrights)

*Optional*. Rights of the business bot

is\_enabled

Boolean

*True*, if the connection is active

#### [](#businessmessagesdeleted)BusinessMessagesDeleted

This object is received when messages are deleted from a connected business account.

Field

Type

Description

business\_connection\_id

String

Unique identifier of the business connection

chat

[Chat](#chat)

Information about a chat in the business account. The bot may not have access to the chat or the corresponding user.

message\_ids

Array of Integer

The list of identifiers of deleted messages in the chat of the business account

#### [](#responseparameters)ResponseParameters

Describes why a request was unsuccessful.

Field

Type

Description

migrate\_to\_chat\_id

Integer

*Optional*. The group has been migrated to a supergroup with the specified identifier. This number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it. But it has at most 52 significant bits, so a signed 64-bit integer or double-precision float type are safe for storing this identifier.

retry\_after

Integer

*Optional*. In case of exceeding flood control, the number of seconds left to wait before the request can be repeated

#### [](#inputmedia)InputMedia

This object represents the content of a media message to be sent. It should be one of

-   [InputMediaAnimation](#inputmediaanimation)
-   [InputMediaDocument](#inputmediadocument)
-   [InputMediaAudio](#inputmediaaudio)
-   [InputMediaPhoto](#inputmediaphoto)
-   [InputMediaVideo](#inputmediavideo)

#### [](#inputmediaphoto)InputMediaPhoto

Represents a photo to be sent.

Field

Type

Description

type

String

Type of the result, must be *photo*

media

String

File to send. Pass a file\_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://<file\_attach\_name>” to upload a new one using multipart/form-data under <file\_attach\_name> name. [More information on Sending Files »](#sending-files)

caption

String

*Optional*. Caption of the photo to be sent, 0-1024 characters after entities parsing

parse\_mode

String

*Optional*. Mode for parsing entities in the photo caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

*Optional*. List of special entities that appear in the caption, which can be specified instead of *parse\_mode*

show\_caption\_above\_media

Boolean

*Optional*. Pass *True*, if the caption must be shown above the message media

has\_spoiler

Boolean

*Optional*. Pass *True* if the photo needs to be covered with a spoiler animation

#### [](#inputmediavideo)InputMediaVideo

Represents a video to be sent.

Field

Type

Description

type

String

Type of the result, must be *video*

media

String

File to send. Pass a file\_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://<file\_attach\_name>” to upload a new one using multipart/form-data under <file\_attach\_name> name. [More information on Sending Files »](#sending-files)

thumbnail

String

*Optional*. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass “attach://<file\_attach\_name>” if the thumbnail was uploaded using multipart/form-data under <file\_attach\_name>. [More information on Sending Files »](#sending-files)

cover

String

*Optional*. Cover for the video in the message. Pass a file\_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://<file\_attach\_name>” to upload a new one using multipart/form-data under <file\_attach\_name> name. [More information on Sending Files »](#sending-files)

start\_timestamp

Integer

*Optional*. Start timestamp for the video in the message

caption

String

*Optional*. Caption of the video to be sent, 0-1024 characters after entities parsing

parse\_mode

String

*Optional*. Mode for parsing entities in the video caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

*Optional*. List of special entities that appear in the caption, which can be specified instead of *parse\_mode*

show\_caption\_above\_media

Boolean

*Optional*. Pass *True*, if the caption must be shown above the message media

width

Integer

*Optional*. Video width

height

Integer

*Optional*. Video height

duration

Integer

*Optional*. Video duration in seconds

supports\_streaming

Boolean

*Optional*. Pass *True* if the uploaded video is suitable for streaming

has\_spoiler

Boolean

*Optional*. Pass *True* if the video needs to be covered with a spoiler animation

#### [](#inputmediaanimation)InputMediaAnimation

Represents an animation file (GIF or H.264/MPEG-4 AVC video without sound) to be sent.

Field

Type

Description

type

String

Type of the result, must be *animation*

media

String

File to send. Pass a file\_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://<file\_attach\_name>” to upload a new one using multipart/form-data under <file\_attach\_name> name. [More information on Sending Files »](#sending-files)

thumbnail

String

*Optional*. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass “attach://<file\_attach\_name>” if the thumbnail was uploaded using multipart/form-data under <file\_attach\_name>. [More information on Sending Files »](#sending-files)

caption

String

*Optional*. Caption of the animation to be sent, 0-1024 characters after entities parsing

parse\_mode

String

*Optional*. Mode for parsing entities in the animation caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

*Optional*. List of special entities that appear in the caption, which can be specified instead of *parse\_mode*

show\_caption\_above\_media

Boolean

*Optional*. Pass *True*, if the caption must be shown above the message media

width

Integer

*Optional*. Animation width

height

Integer

*Optional*. Animation height

duration

Integer

*Optional*. Animation duration in seconds

has\_spoiler

Boolean

*Optional*. Pass *True* if the animation needs to be covered with a spoiler animation

#### [](#inputmediaaudio)InputMediaAudio

Represents an audio file to be treated as music to be sent.

Field

Type

Description

type

String

Type of the result, must be *audio*

media

String

File to send. Pass a file\_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://<file\_attach\_name>” to upload a new one using multipart/form-data under <file\_attach\_name> name. [More information on Sending Files »](#sending-files)

thumbnail

String

*Optional*. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass “attach://<file\_attach\_name>” if the thumbnail was uploaded using multipart/form-data under <file\_attach\_name>. [More information on Sending Files »](#sending-files)

caption

String

*Optional*. Caption of the audio to be sent, 0-1024 characters after entities parsing

parse\_mode

String

*Optional*. Mode for parsing entities in the audio caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

*Optional*. List of special entities that appear in the caption, which can be specified instead of *parse\_mode*

duration

Integer

*Optional*. Duration of the audio in seconds

performer

String

*Optional*. Performer of the audio

title

String

*Optional*. Title of the audio

#### [](#inputmediadocument)InputMediaDocument

Represents a general file to be sent.

Field

Type

Description

type

String

Type of the result, must be *document*

media

String

File to send. Pass a file\_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://<file\_attach\_name>” to upload a new one using multipart/form-data under <file\_attach\_name> name. [More information on Sending Files »](#sending-files)

thumbnail

String

*Optional*. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass “attach://<file\_attach\_name>” if the thumbnail was uploaded using multipart/form-data under <file\_attach\_name>. [More information on Sending Files »](#sending-files)

caption

String

*Optional*. Caption of the document to be sent, 0-1024 characters after entities parsing

parse\_mode

String

*Optional*. Mode for parsing entities in the document caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

*Optional*. List of special entities that appear in the caption, which can be specified instead of *parse\_mode*

disable\_content\_type\_detection

Boolean

*Optional*. Disables automatic server-side content type detection for files uploaded using multipart/form-data. Always *True*, if the document is sent as part of an album.

#### [](#inputfile)InputFile

This object represents the contents of a file to be uploaded. Must be posted using multipart/form-data in the usual way that files are uploaded via the browser.

#### [](#inputpaidmedia)InputPaidMedia

This object describes the paid media to be sent. Currently, it can be one of

-   [InputPaidMediaPhoto](#inputpaidmediaphoto)
-   [InputPaidMediaVideo](#inputpaidmediavideo)

#### [](#inputpaidmediaphoto)InputPaidMediaPhoto

The paid media to send is a photo.

Field

Type

Description

type

String

Type of the media, must be *photo*

media

String

File to send. Pass a file\_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://<file\_attach\_name>” to upload a new one using multipart/form-data under <file\_attach\_name> name. [More information on Sending Files »](#sending-files)

#### [](#inputpaidmediavideo)InputPaidMediaVideo

The paid media to send is a video.

Field

Type

Description

type

String

Type of the media, must be *video*

media

String

File to send. Pass a file\_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://<file\_attach\_name>” to upload a new one using multipart/form-data under <file\_attach\_name> name. [More information on Sending Files »](#sending-files)

thumbnail

String

*Optional*. Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass “attach://<file\_attach\_name>” if the thumbnail was uploaded using multipart/form-data under <file\_attach\_name>. [More information on Sending Files »](#sending-files)

cover

String

*Optional*. Cover for the video in the message. Pass a file\_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://<file\_attach\_name>” to upload a new one using multipart/form-data under <file\_attach\_name> name. [More information on Sending Files »](#sending-files)

start\_timestamp

Integer

*Optional*. Start timestamp for the video in the message

width

Integer

*Optional*. Video width

height

Integer

*Optional*. Video height

duration

Integer

*Optional*. Video duration in seconds

supports\_streaming

Boolean

*Optional*. Pass *True* if the uploaded video is suitable for streaming

#### [](#inputprofilephoto)InputProfilePhoto

This object describes a profile photo to set. Currently, it can be one of

-   [InputProfilePhotoStatic](#inputprofilephotostatic)
-   [InputProfilePhotoAnimated](#inputprofilephotoanimated)

#### [](#inputprofilephotostatic)InputProfilePhotoStatic

A static profile photo in the .JPG format.

Field

Type

Description

type

String

Type of the profile photo, must be *static*

photo

String

The static profile photo. Profile photos can't be reused and can only be uploaded as a new file, so you can pass “attach://<file\_attach\_name>” if the photo was uploaded using multipart/form-data under <file\_attach\_name>. [More information on Sending Files »](#sending-files)

#### [](#inputprofilephotoanimated)InputProfilePhotoAnimated

An animated profile photo in the MPEG4 format.

Field

Type

Description

type

String

Type of the profile photo, must be *animated*

animation

String

The animated profile photo. Profile photos can't be reused and can only be uploaded as a new file, so you can pass “attach://<file\_attach\_name>” if the photo was uploaded using multipart/form-data under <file\_attach\_name>. [More information on Sending Files »](#sending-files)

main\_frame\_timestamp

Float

*Optional*. Timestamp in seconds of the frame that will be used as the static profile photo. Defaults to 0.0.

#### [](#inputstorycontent)InputStoryContent

This object describes the content of a story to post. Currently, it can be one of

-   [InputStoryContentPhoto](#inputstorycontentphoto)
-   [InputStoryContentVideo](#inputstorycontentvideo)

#### [](#inputstorycontentphoto)InputStoryContentPhoto

Describes a photo to post as a story.

Field

Type

Description

type

String

Type of the content, must be *photo*

photo

String

The photo to post as a story. The photo must be of the size 1080x1920 and must not exceed 10 MB. The photo can't be reused and can only be uploaded as a new file, so you can pass “attach://<file\_attach\_name>” if the photo was uploaded using multipart/form-data under <file\_attach\_name>. [More information on Sending Files »](#sending-files)

#### [](#inputstorycontentvideo)InputStoryContentVideo

Describes a video to post as a story.

Field

Type

Description

type

String

Type of the content, must be *video*

video

String

The video to post as a story. The video must be of the size 720x1280, streamable, encoded with H.265 codec, with key frames added each second in the MPEG4 format, and must not exceed 30 MB. The video can't be reused and can only be uploaded as a new file, so you can pass “attach://<file\_attach\_name>” if the video was uploaded using multipart/form-data under <file\_attach\_name>. [More information on Sending Files »](#sending-files)

duration

Float

*Optional*. Precise duration of the video in seconds; 0-60

cover\_frame\_timestamp

Float

*Optional*. Timestamp in seconds of the frame that will be used as the static cover for the story. Defaults to 0.0.

is\_animation

Boolean

*Optional*. Pass *True* if the video has no sound

#### [](#sending-files)Sending files

There are three ways to send files (photos, stickers, audio, media, etc.):

1.  If the file is already stored somewhere on the Telegram servers, you don't need to reupload it: each file object has a **file\_id** field, simply pass this **file\_id** as a parameter instead of uploading. There are **no limits** for files sent this way.
2.  Provide Telegram with an HTTP URL for the file to be sent. Telegram will download and send the file. 5 MB max size for photos and 20 MB max for other types of content.
3.  Post the file using multipart/form-data in the usual way that files are uploaded via the browser. 10 MB max size for photos, 50 MB for other files.

**Sending by file\_id**

-   It is not possible to change the file type when resending by **file\_id**. I.e. a [video](#video) can't be [sent as a photo](#sendphoto), a [photo](#photosize) can't be [sent as a document](#senddocument), etc.
-   It is not possible to resend thumbnails.
-   Resending a photo by **file\_id** will send all of its [sizes](#photosize).
-   **file\_id** is unique for each individual bot and **can't** be transferred from one bot to another.
-   **file\_id** uniquely identifies a file, but a file can have different valid **file\_id**s even for the same bot.

**Sending by URL**

-   When sending by URL the target file must have the correct MIME type (e.g., audio/mpeg for [sendAudio](#sendaudio), etc.).
-   In [sendDocument](#senddocument), sending by URL will currently only work for **.PDF** and **.ZIP** files.
-   To use [sendVoice](#sendvoice), the file must have the type audio/ogg and be no more than 1MB in size. 1-20MB voice notes will be sent as files.
-   Other configurations may work but we can't guarantee that they will.

#### [](#accent-colors)Accent colors

Colors with identifiers 0 (red), 1 (orange), 2 (purple/violet), 3 (green), 4 (cyan), 5 (blue), 6 (pink) can be customized by app themes. Additionally, the following colors in RGB format are currently in use.

Color identifier

Light colors

Dark colors

7

E15052 F9AE63

FF9380 992F37

8

E0802B FAC534

ECB04E C35714

9

A05FF3 F48FFF

C697FF 5E31C8

10

27A910 A7DC57

A7EB6E 167E2D

11

27ACCE 82E8D6

40D8D0 045C7F

12

3391D4 7DD3F0

52BFFF 0B5494

13

DD4371 FFBE9F

FF86A6 8E366E

14

247BED F04856 FFFFFF

3FA2FE E5424F FFFFFF

15

D67722 1EA011 FFFFFF

FF905E 32A527 FFFFFF

16

179E42 E84A3F FFFFFF

66D364 D5444F FFFFFF

17

2894AF 6FC456 FFFFFF

22BCE2 3DA240 FFFFFF

18

0C9AB3 FFAD95 FFE6B5

22BCE2 FF9778 FFDA6B

19

7757D6 F79610 FFDE8E

9791FF F2731D FFDB59

20

1585CF F2AB1D FFFFFF

3DA6EB EEA51D FFFFFF

#### [](#profile-accent-colors)Profile accent colors

Currently, the following colors in RGB format are in use for profile backgrounds.

Color identifier

Light colors

Dark colors

0

BA5650

9C4540

1

C27C3E

945E2C

2

956AC8

715099

3

49A355

33713B

4

3E97AD

387E87

5

5A8FBB

477194

6

B85378

944763

7

7F8B95

435261

8

C9565D D97C57

994343 AC583E

9

CF7244 CC9433

8F552F A17232

10

9662D4 B966B6

634691 9250A2

11

3D9755 89A650

296A43 5F8F44

12

3D95BA 50AD98

306C7C 3E987E

13

538BC2 4DA8BD

38618C 458BA1

14

B04F74 D1666D

884160 A65259

15

637482 7B8A97

53606E 384654

#### [](#inline-mode-objects)Inline mode objects

Objects and methods used in the inline mode are described in the [Inline mode section](#inline-mode).

