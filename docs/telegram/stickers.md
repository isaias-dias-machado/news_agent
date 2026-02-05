### [](#stickers)Stickers

The following methods and objects allow your bot to handle stickers and sticker sets.

#### [](#sticker)Sticker

This object represents a sticker.

Field

Type

Description

file\_id

String

Identifier for this file, which can be used to download or reuse the file

file\_unique\_id

String

Unique identifier for this file, which is supposed to be the same over time and for different bots. Can't be used to download or reuse the file.

type

String

Type of the sticker, currently one of “regular”, “mask”, “custom\_emoji”. The type of the sticker is independent from its format, which is determined by the fields *is\_animated* and *is\_video*.

width

Integer

Sticker width

height

Integer

Sticker height

is\_animated

Boolean

*True*, if the sticker is [animated](https://telegram.org/blog/animated-stickers)

is\_video

Boolean

*True*, if the sticker is a [video sticker](https://telegram.org/blog/video-stickers-better-reactions)

thumbnail

[PhotoSize](#photosize)

*Optional*. Sticker thumbnail in the .WEBP or .JPG format

emoji

String

*Optional*. Emoji associated with the sticker

set\_name

String

*Optional*. Name of the sticker set to which the sticker belongs

premium\_animation

[File](#file)

*Optional*. For premium regular stickers, premium animation for the sticker

mask\_position

[MaskPosition](#maskposition)

*Optional*. For mask stickers, the position where the mask should be placed

custom\_emoji\_id

String

*Optional*. For custom emoji stickers, unique identifier of the custom emoji

needs\_repainting

True

*Optional*. *True*, if the sticker must be repainted to a text color in messages, the color of the Telegram Premium badge in emoji status, white color on chat photos, or another appropriate color in other places

file\_size

Integer

*Optional*. File size in bytes

#### [](#stickerset)StickerSet

This object represents a sticker set.

Field

Type

Description

name

String

Sticker set name

title

String

Sticker set title

sticker\_type

String

Type of stickers in the set, currently one of “regular”, “mask”, “custom\_emoji”

stickers

Array of [Sticker](#sticker)

List of all set stickers

thumbnail

[PhotoSize](#photosize)

*Optional*. Sticker set thumbnail in the .WEBP, .TGS, or .WEBM format

#### [](#maskposition)MaskPosition

This object describes the position on faces where a mask should be placed by default.

Field

Type

Description

point

String

The part of the face relative to which the mask should be placed. One of “forehead”, “eyes”, “mouth”, or “chin”.

x\_shift

Float

Shift by X-axis measured in widths of the mask scaled to the face size, from left to right. For example, choosing -1.0 will place mask just to the left of the default mask position.

y\_shift

Float

Shift by Y-axis measured in heights of the mask scaled to the face size, from top to bottom. For example, 1.0 will place the mask just below the default mask position.

scale

Float

Mask scaling coefficient. For example, 2.0 means double size.

#### [](#inputsticker)InputSticker

This object describes a sticker to be added to a sticker set.

Field

Type

Description

sticker

String

The added sticker. Pass a *file\_id* as a String to send a file that already exists on the Telegram servers, pass an HTTP URL as a String for Telegram to get a file from the Internet, or pass “attach://<file\_attach\_name>” to upload a new file using multipart/form-data under <file\_attach\_name> name. Animated and video stickers can't be uploaded via HTTP URL. [More information on Sending Files »](#sending-files)

format

String

Format of the added sticker, must be one of “static” for a **.WEBP** or **.PNG** image, “animated” for a **.TGS** animation, “video” for a **.WEBM** video

emoji\_list

Array of String

List of 1-20 emoji associated with the sticker

mask\_position

[MaskPosition](#maskposition)

*Optional*. Position where the mask should be placed on faces. For “mask” stickers only.

keywords

Array of String

*Optional*. List of 0-20 search keywords for the sticker with total length of up to 64 characters. For “regular” and “custom\_emoji” stickers only.

#### [](#sendsticker)sendSticker

Use this method to send static .WEBP, [animated](https://telegram.org/blog/animated-stickers) .TGS, or [video](https://telegram.org/blog/video-stickers-better-reactions) .WEBM stickers. On success, the sent [Message](#message) is returned.

Parameter

Type

Required

Description

business\_connection\_id

String

Optional

Unique identifier of the business connection on behalf of which the message will be sent

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

message\_thread\_id

Integer

Optional

Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only

direct\_messages\_topic\_id

Integer

Optional

Identifier of the direct messages topic to which the message will be sent; required if the message is sent to a direct messages chat

sticker

[InputFile](#inputfile) or String

Yes

Sticker to send. Pass a file\_id as String to send a file that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a .WEBP sticker from the Internet, or upload a new .WEBP, .TGS, or .WEBM sticker using multipart/form-data. [More information on Sending Files »](#sending-files). Video and animated stickers can't be sent via an HTTP URL.

emoji

String

Optional

Emoji associated with the sticker; only for just uploaded stickers

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

suggested\_post\_parameters

[SuggestedPostParameters](#suggestedpostparameters)

Optional

A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only. If the message is sent as a reply to another suggested post, then that suggested post is automatically declined.

reply\_parameters

[ReplyParameters](#replyparameters)

Optional

Description of the message to reply to

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup) or [ReplyKeyboardMarkup](#replykeyboardmarkup) or [ReplyKeyboardRemove](#replykeyboardremove) or [ForceReply](#forcereply)

Optional

Additional interface options. A JSON-serialized object for an [inline keyboard](/bots/features#inline-keyboards), [custom reply keyboard](/bots/features#keyboards), instructions to remove a reply keyboard or to force a reply from the user

#### [](#getstickerset)getStickerSet

Use this method to get a sticker set. On success, a [StickerSet](#stickerset) object is returned.

Parameter

Type

Required

Description

name

String

Yes

Name of the sticker set

#### [](#getcustomemojistickers)getCustomEmojiStickers

Use this method to get information about custom emoji stickers by their identifiers. Returns an Array of [Sticker](#sticker) objects.

Parameter

Type

Required

Description

custom\_emoji\_ids

Array of String

Yes

A JSON-serialized list of custom emoji identifiers. At most 200 custom emoji identifiers can be specified.

#### [](#uploadstickerfile)uploadStickerFile

Use this method to upload a file with a sticker for later use in the [createNewStickerSet](#createnewstickerset), [addStickerToSet](#addstickertoset), or [replaceStickerInSet](#replacestickerinset) methods (the file can be used multiple times). Returns the uploaded [File](#file) on success.

Parameter

Type

Required

Description

user\_id

Integer

Yes

User identifier of sticker file owner

sticker

[InputFile](#inputfile)

Yes

A file with the sticker in .WEBP, .PNG, .TGS, or .WEBM format. See [](/stickers)[https://core.telegram.org/stickers](https://core.telegram.org/stickers) for technical requirements. [More information on Sending Files »](#sending-files)

sticker\_format

String

Yes

Format of the sticker, must be one of “static”, “animated”, “video”

#### [](#createnewstickerset)createNewStickerSet

Use this method to create a new sticker set owned by a user. The bot will be able to edit the sticker set thus created. Returns *True* on success.

Parameter

Type

Required

Description

user\_id

Integer

Yes

User identifier of created sticker set owner

name

String

Yes

Short name of sticker set, to be used in `t.me/addstickers/` URLs (e.g., *animals*). Can contain only English letters, digits and underscores. Must begin with a letter, can't contain consecutive underscores and must end in `"_by_<bot_username>"`. `<bot_username>` is case insensitive. 1-64 characters.

title

String

Yes

Sticker set title, 1-64 characters

stickers

Array of [InputSticker](#inputsticker)

Yes

A JSON-serialized list of 1-50 initial stickers to be added to the sticker set

sticker\_type

String

Optional

Type of stickers in the set, pass “regular”, “mask”, or “custom\_emoji”. By default, a regular sticker set is created.

needs\_repainting

Boolean

Optional

Pass *True* if stickers in the sticker set must be repainted to the color of text when used in messages, the accent color if used as emoji status, white on chat photos, or another appropriate color based on context; for custom emoji sticker sets only

#### [](#addstickertoset)addStickerToSet

Use this method to add a new sticker to a set created by the bot. Emoji sticker sets can have up to 200 stickers. Other sticker sets can have up to 120 stickers. Returns *True* on success.

Parameter

Type

Required

Description

user\_id

Integer

Yes

User identifier of sticker set owner

name

String

Yes

Sticker set name

sticker

[InputSticker](#inputsticker)

Yes

A JSON-serialized object with information about the added sticker. If exactly the same sticker had already been added to the set, then the set isn't changed.

#### [](#setstickerpositioninset)setStickerPositionInSet

Use this method to move a sticker in a set created by the bot to a specific position. Returns *True* on success.

Parameter

Type

Required

Description

sticker

String

Yes

File identifier of the sticker

position

Integer

Yes

New sticker position in the set, zero-based

#### [](#deletestickerfromset)deleteStickerFromSet

Use this method to delete a sticker from a set created by the bot. Returns *True* on success.

Parameter

Type

Required

Description

sticker

String

Yes

File identifier of the sticker

#### [](#replacestickerinset)replaceStickerInSet

Use this method to replace an existing sticker in a sticker set with a new one. The method is equivalent to calling [deleteStickerFromSet](#deletestickerfromset), then [addStickerToSet](#addstickertoset), then [setStickerPositionInSet](#setstickerpositioninset). Returns *True* on success.

Parameter

Type

Required

Description

user\_id

Integer

Yes

User identifier of the sticker set owner

name

String

Yes

Sticker set name

old\_sticker

String

Yes

File identifier of the replaced sticker

sticker

[InputSticker](#inputsticker)

Yes

A JSON-serialized object with information about the added sticker. If exactly the same sticker had already been added to the set, then the set remains unchanged.

#### [](#setstickeremojilist)setStickerEmojiList

Use this method to change the list of emoji assigned to a regular or custom emoji sticker. The sticker must belong to a sticker set created by the bot. Returns *True* on success.

Parameter

Type

Required

Description

sticker

String

Yes

File identifier of the sticker

emoji\_list

Array of String

Yes

A JSON-serialized list of 1-20 emoji associated with the sticker

#### [](#setstickerkeywords)setStickerKeywords

Use this method to change search keywords assigned to a regular or custom emoji sticker. The sticker must belong to a sticker set created by the bot. Returns *True* on success.

Parameter

Type

Required

Description

sticker

String

Yes

File identifier of the sticker

keywords

Array of String

Optional

A JSON-serialized list of 0-20 search keywords for the sticker with total length of up to 64 characters

#### [](#setstickermaskposition)setStickerMaskPosition

Use this method to change the [mask position](#maskposition) of a mask sticker. The sticker must belong to a sticker set that was created by the bot. Returns *True* on success.

Parameter

Type

Required

Description

sticker

String

Yes

File identifier of the sticker

mask\_position

[MaskPosition](#maskposition)

Optional

A JSON-serialized object with the position where the mask should be placed on faces. Omit the parameter to remove the mask position.

#### [](#setstickersettitle)setStickerSetTitle

Use this method to set the title of a created sticker set. Returns *True* on success.

Parameter

Type

Required

Description

name

String

Yes

Sticker set name

title

String

Yes

Sticker set title, 1-64 characters

#### [](#setstickersetthumbnail)setStickerSetThumbnail

Use this method to set the thumbnail of a regular or mask sticker set. The format of the thumbnail file must match the format of the stickers in the set. Returns *True* on success.

Parameter

Type

Required

Description

name

String

Yes

Sticker set name

user\_id

Integer

Yes

User identifier of the sticker set owner

thumbnail

[InputFile](#inputfile) or String

Optional

A **.WEBP** or **.PNG** image with the thumbnail, must be up to 128 kilobytes in size and have a width and height of exactly 100px, or a **.TGS** animation with a thumbnail up to 32 kilobytes in size (see [](/stickers#animation-requirements)[https://core.telegram.org/stickers#animation-requirements](https://core.telegram.org/stickers#animation-requirements) for animated sticker technical requirements), or a **.WEBM** video with the thumbnail up to 32 kilobytes in size; see [](/stickers#video-requirements)[https://core.telegram.org/stickers#video-requirements](https://core.telegram.org/stickers#video-requirements) for video sticker technical requirements. Pass a *file\_id* as a String to send a file that already exists on the Telegram servers, pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data. [More information on Sending Files »](#sending-files). Animated and video sticker set thumbnails can't be uploaded via HTTP URL. If omitted, then the thumbnail is dropped and the first sticker is used as the thumbnail.

format

String

Yes

Format of the thumbnail, must be one of “static” for a **.WEBP** or **.PNG** image, “animated” for a **.TGS** animation, or “video” for a **.WEBM** video

#### [](#setcustomemojistickersetthumbnail)setCustomEmojiStickerSetThumbnail

Use this method to set the thumbnail of a custom emoji sticker set. Returns *True* on success.

Parameter

Type

Required

Description

name

String

Yes

Sticker set name

custom\_emoji\_id

String

Optional

Custom emoji identifier of a sticker from the sticker set; pass an empty string to drop the thumbnail and use the first sticker as the thumbnail.

#### [](#deletestickerset)deleteStickerSet

Use this method to delete a sticker set that was created by the bot. Returns *True* on success.

Parameter

Type

Required

Description

name

String

Yes

Sticker set name

