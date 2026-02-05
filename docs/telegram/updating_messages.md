### [](#updating-messages)Updating messages

The following methods allow you to change an existing message in the message history instead of sending a new one with a result of an action. This is most useful for messages with [inline keyboards](/bots/features#inline-keyboards) using callback queries, but can also help reduce clutter in conversations with regular chat bots.

Please note, that it is currently only possible to edit messages without *reply\_markup* or with [inline keyboards](/bots/features#inline-keyboards).

#### [](#editmessagetext)editMessageText

Use this method to edit text and [game](#games) messages. On success, if the edited message is not an inline message, the edited [Message](#message) is returned, otherwise *True* is returned. Note that business messages that were not sent by the bot and do not contain an inline keyboard can only be edited within **48 hours** from the time they were sent.

Parameter

Type

Required

Description

business\_connection\_id

String

Optional

Unique identifier of the business connection on behalf of which the message to be edited was sent

chat\_id

Integer or String

Optional

Required if *inline\_message\_id* is not specified. Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

message\_id

Integer

Optional

Required if *inline\_message\_id* is not specified. Identifier of the message to edit

inline\_message\_id

String

Optional

Required if *chat\_id* and *message\_id* are not specified. Identifier of the inline message

text

String

Yes

New text of the message, 1-4096 characters after entities parsing

parse\_mode

String

Optional

Mode for parsing entities in the message text. See [formatting options](#formatting-options) for more details.

entities

Array of [MessageEntity](#messageentity)

Optional

A JSON-serialized list of special entities that appear in message text, which can be specified instead of *parse\_mode*

link\_preview\_options

[LinkPreviewOptions](#linkpreviewoptions)

Optional

Link preview generation options for the message

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

Optional

A JSON-serialized object for an [inline keyboard](/bots/features#inline-keyboards).

#### [](#editmessagecaption)editMessageCaption

Use this method to edit captions of messages. On success, if the edited message is not an inline message, the edited [Message](#message) is returned, otherwise *True* is returned. Note that business messages that were not sent by the bot and do not contain an inline keyboard can only be edited within **48 hours** from the time they were sent.

Parameter

Type

Required

Description

business\_connection\_id

String

Optional

Unique identifier of the business connection on behalf of which the message to be edited was sent

chat\_id

Integer or String

Optional

Required if *inline\_message\_id* is not specified. Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

message\_id

Integer

Optional

Required if *inline\_message\_id* is not specified. Identifier of the message to edit

inline\_message\_id

String

Optional

Required if *chat\_id* and *message\_id* are not specified. Identifier of the inline message

caption

String

Optional

New caption of the message, 0-1024 characters after entities parsing

parse\_mode

String

Optional

Mode for parsing entities in the message caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

Optional

A JSON-serialized list of special entities that appear in the caption, which can be specified instead of *parse\_mode*

show\_caption\_above\_media

Boolean

Optional

Pass *True*, if the caption must be shown above the message media. Supported only for animation, photo and video messages.

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

Optional

A JSON-serialized object for an [inline keyboard](/bots/features#inline-keyboards).

#### [](#editmessagemedia)editMessageMedia

Use this method to edit animation, audio, document, photo, or video messages, or to add media to text messages. If a message is part of a message album, then it can be edited only to an audio for audio albums, only to a document for document albums and to a photo or a video otherwise. When an inline message is edited, a new file can't be uploaded; use a previously uploaded file via its file\_id or specify a URL. On success, if the edited message is not an inline message, the edited [Message](#message) is returned, otherwise *True* is returned. Note that business messages that were not sent by the bot and do not contain an inline keyboard can only be edited within **48 hours** from the time they were sent.

Parameter

Type

Required

Description

business\_connection\_id

String

Optional

Unique identifier of the business connection on behalf of which the message to be edited was sent

chat\_id

Integer or String

Optional

Required if *inline\_message\_id* is not specified. Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

message\_id

Integer

Optional

Required if *inline\_message\_id* is not specified. Identifier of the message to edit

inline\_message\_id

String

Optional

Required if *chat\_id* and *message\_id* are not specified. Identifier of the inline message

media

[InputMedia](#inputmedia)

Yes

A JSON-serialized object for a new media content of the message

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

Optional

A JSON-serialized object for a new [inline keyboard](/bots/features#inline-keyboards).

#### [](#editmessagelivelocation)editMessageLiveLocation

Use this method to edit live location messages. A location can be edited until its *live\_period* expires or editing is explicitly disabled by a call to [stopMessageLiveLocation](#stopmessagelivelocation). On success, if the edited message is not an inline message, the edited [Message](#message) is returned, otherwise *True* is returned.

Parameter

Type

Required

Description

business\_connection\_id

String

Optional

Unique identifier of the business connection on behalf of which the message to be edited was sent

chat\_id

Integer or String

Optional

Required if *inline\_message\_id* is not specified. Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

message\_id

Integer

Optional

Required if *inline\_message\_id* is not specified. Identifier of the message to edit

inline\_message\_id

String

Optional

Required if *chat\_id* and *message\_id* are not specified. Identifier of the inline message

latitude

Float

Yes

Latitude of new location

longitude

Float

Yes

Longitude of new location

live\_period

Integer

Optional

New period in seconds during which the location can be updated, starting from the message send date. If 0x7FFFFFFF is specified, then the location can be updated forever. Otherwise, the new value must not exceed the current *live\_period* by more than a day, and the live location expiration date must remain within the next 90 days. If not specified, then *live\_period* remains unchanged

horizontal\_accuracy

Float

Optional

The radius of uncertainty for the location, measured in meters; 0-1500

heading

Integer

Optional

Direction in which the user is moving, in degrees. Must be between 1 and 360 if specified.

proximity\_alert\_radius

Integer

Optional

The maximum distance for proximity alerts about approaching another chat member, in meters. Must be between 1 and 100000 if specified.

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

Optional

A JSON-serialized object for a new [inline keyboard](/bots/features#inline-keyboards).

#### [](#stopmessagelivelocation)stopMessageLiveLocation

Use this method to stop updating a live location message before *live\_period* expires. On success, if the message is not an inline message, the edited [Message](#message) is returned, otherwise *True* is returned.

Parameter

Type

Required

Description

business\_connection\_id

String

Optional

Unique identifier of the business connection on behalf of which the message to be edited was sent

chat\_id

Integer or String

Optional

Required if *inline\_message\_id* is not specified. Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

message\_id

Integer

Optional

Required if *inline\_message\_id* is not specified. Identifier of the message with live location to stop

inline\_message\_id

String

Optional

Required if *chat\_id* and *message\_id* are not specified. Identifier of the inline message

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

Optional

A JSON-serialized object for a new [inline keyboard](/bots/features#inline-keyboards).

#### [](#editmessagechecklist)editMessageChecklist

Use this method to edit a checklist on behalf of a connected business account. On success, the edited [Message](#message) is returned.

Parameter

Type

Required

Description

business\_connection\_id

String

Yes

Unique identifier of the business connection on behalf of which the message will be sent

chat\_id

Integer

Yes

Unique identifier for the target chat

message\_id

Integer

Yes

Unique identifier for the target message

checklist

[InputChecklist](#inputchecklist)

Yes

A JSON-serialized object for the new checklist

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

Optional

A JSON-serialized object for the new inline keyboard for the message

#### [](#editmessagereplymarkup)editMessageReplyMarkup

Use this method to edit only the reply markup of messages. On success, if the edited message is not an inline message, the edited [Message](#message) is returned, otherwise *True* is returned. Note that business messages that were not sent by the bot and do not contain an inline keyboard can only be edited within **48 hours** from the time they were sent.

Parameter

Type

Required

Description

business\_connection\_id

String

Optional

Unique identifier of the business connection on behalf of which the message to be edited was sent

chat\_id

Integer or String

Optional

Required if *inline\_message\_id* is not specified. Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

message\_id

Integer

Optional

Required if *inline\_message\_id* is not specified. Identifier of the message to edit

inline\_message\_id

String

Optional

Required if *chat\_id* and *message\_id* are not specified. Identifier of the inline message

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

Optional

A JSON-serialized object for an [inline keyboard](/bots/features#inline-keyboards).

#### [](#stoppoll)stopPoll

Use this method to stop a poll which was sent by the bot. On success, the stopped [Poll](#poll) is returned.

Parameter

Type

Required

Description

business\_connection\_id

String

Optional

Unique identifier of the business connection on behalf of which the message to be edited was sent

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

message\_id

Integer

Yes

Identifier of the original message with the poll

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

Optional

A JSON-serialized object for a new message [inline keyboard](/bots/features#inline-keyboards).

#### [](#approvesuggestedpost)approveSuggestedPost

Use this method to approve a suggested post in a direct messages chat. The bot must have the 'can\_post\_messages' administrator right in the corresponding channel chat. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer

Yes

Unique identifier for the target direct messages chat

message\_id

Integer

Yes

Identifier of a suggested post message to approve

send\_date

Integer

Optional

Point in time (Unix timestamp) when the post is expected to be published; omit if the date has already been specified when the suggested post was created. If specified, then the date must be not more than 2678400 seconds (30 days) in the future

#### [](#declinesuggestedpost)declineSuggestedPost

Use this method to decline a suggested post in a direct messages chat. The bot must have the 'can\_manage\_direct\_messages' administrator right in the corresponding channel chat. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer

Yes

Unique identifier for the target direct messages chat

message\_id

Integer

Yes

Identifier of a suggested post message to decline

comment

String

Optional

Comment for the creator of the suggested post; 0-128 characters

#### [](#deletemessage)deleteMessage

Use this method to delete a message, including service messages, with the following limitations:  
\- A message can only be deleted if it was sent less than 48 hours ago.  
\- Service messages about a supergroup, channel, or forum topic creation can't be deleted.  
\- A dice message in a private chat can only be deleted if it was sent more than 24 hours ago.  
\- Bots can delete outgoing messages in private chats, groups, and supergroups.  
\- Bots can delete incoming messages in private chats.  
\- Bots granted *can\_post\_messages* permissions can delete outgoing messages in channels.  
\- If the bot is an administrator of a group, it can delete any message there.  
\- If the bot has *can\_delete\_messages* administrator right in a supergroup or a channel, it can delete any message there.  
\- If the bot has *can\_manage\_direct\_messages* administrator right in a channel, it can delete any message in the corresponding direct messages chat.  
Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

message\_id

Integer

Yes

Identifier of the message to delete

#### [](#deletemessages)deleteMessages

Use this method to delete multiple messages simultaneously. If some of the specified messages can't be found, they are skipped. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

message\_ids

Array of Integer

Yes

A JSON-serialized list of 1-100 identifiers of messages to delete. See [deleteMessage](#deletemessage) for limitations on which messages can be deleted

