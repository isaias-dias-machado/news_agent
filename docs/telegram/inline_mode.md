### [](#inline-mode)Inline mode

The following methods and objects allow your bot to work in [inline mode](/bots/inline).  
Please see our [Introduction to Inline bots](/bots/inline) for more details.

To enable this option, send the `/setinline` command to [@BotFather](https://t.me/botfather) and provide the placeholder text that the user will see in the input field after typing your bot's name.

#### [](#inlinequery)InlineQuery

This object represents an incoming inline query. When the user sends an empty query, your bot could return some default or trending results.

Field

Type

Description

id

String

Unique identifier for this query

from

[User](#user)

Sender

query

String

Text of the query (up to 256 characters)

offset

String

Offset of the results to be returned, can be controlled by the bot

chat\_type

String

*Optional*. Type of the chat from which the inline query was sent. Can be either “sender” for a private chat with the inline query sender, “private”, “group”, “supergroup”, or “channel”. The chat type should be always known for requests sent from official clients and most third-party clients, unless the request was sent from a secret chat

location

[Location](#location)

*Optional*. Sender location, only for bots that request user location

#### [](#answerinlinequery)answerInlineQuery

Use this method to send answers to an inline query. On success, *True* is returned.  
No more than **50** results per query are allowed.

Parameter

Type

Required

Description

inline\_query\_id

String

Yes

Unique identifier for the answered query

results

Array of [InlineQueryResult](#inlinequeryresult)

Yes

A JSON-serialized array of results for the inline query

cache\_time

Integer

Optional

The maximum amount of time in seconds that the result of the inline query may be cached on the server. Defaults to 300.

is\_personal

Boolean

Optional

Pass *True* if results may be cached on the server side only for the user that sent the query. By default, results may be returned to any user who sends the same query.

next\_offset

String

Optional

Pass the offset that a client should send in the next query with the same text to receive more results. Pass an empty string if there are no more results or if you don't support pagination. Offset length can't exceed 64 bytes.

button

[InlineQueryResultsButton](#inlinequeryresultsbutton)

Optional

A JSON-serialized object describing a button to be shown above inline query results

#### [](#inlinequeryresultsbutton)InlineQueryResultsButton

This object represents a button to be shown above inline query results. You **must** use exactly one of the optional fields.

Field

Type

Description

text

String

Label text on the button

web\_app

[WebAppInfo](#webappinfo)

*Optional*. Description of the [Web App](/bots/webapps) that will be launched when the user presses the button. The Web App will be able to switch back to the inline mode using the method [switchInlineQuery](/bots/webapps#initializing-mini-apps) inside the Web App.

start\_parameter

String

*Optional*. [Deep-linking](/bots/features#deep-linking) parameter for the /start message sent to the bot when a user presses the button. 1-64 characters, only `A-Z`, `a-z`, `0-9`, `_` and `-` are allowed.  
  
*Example:* An inline bot that sends YouTube videos can ask the user to connect the bot to their YouTube account to adapt search results accordingly. To do this, it displays a 'Connect your YouTube account' button above the results, or even before showing any. The user presses the button, switches to a private chat with the bot and, in doing so, passes a start parameter that instructs the bot to return an OAuth link. Once done, the bot can offer a [*switch\_inline*](#inlinekeyboardmarkup) button so that the user can easily return to the chat where they wanted to use the bot's inline capabilities.

#### [](#inlinequeryresult)InlineQueryResult

This object represents one result of an inline query. Telegram clients currently support results of the following 20 types:

-   [InlineQueryResultCachedAudio](#inlinequeryresultcachedaudio)
-   [InlineQueryResultCachedDocument](#inlinequeryresultcacheddocument)
-   [InlineQueryResultCachedGif](#inlinequeryresultcachedgif)
-   [InlineQueryResultCachedMpeg4Gif](#inlinequeryresultcachedmpeg4gif)
-   [InlineQueryResultCachedPhoto](#inlinequeryresultcachedphoto)
-   [InlineQueryResultCachedSticker](#inlinequeryresultcachedsticker)
-   [InlineQueryResultCachedVideo](#inlinequeryresultcachedvideo)
-   [InlineQueryResultCachedVoice](#inlinequeryresultcachedvoice)
-   [InlineQueryResultArticle](#inlinequeryresultarticle)
-   [InlineQueryResultAudio](#inlinequeryresultaudio)
-   [InlineQueryResultContact](#inlinequeryresultcontact)
-   [InlineQueryResultGame](#inlinequeryresultgame)
-   [InlineQueryResultDocument](#inlinequeryresultdocument)
-   [InlineQueryResultGif](#inlinequeryresultgif)
-   [InlineQueryResultLocation](#inlinequeryresultlocation)
-   [InlineQueryResultMpeg4Gif](#inlinequeryresultmpeg4gif)
-   [InlineQueryResultPhoto](#inlinequeryresultphoto)
-   [InlineQueryResultVenue](#inlinequeryresultvenue)
-   [InlineQueryResultVideo](#inlinequeryresultvideo)
-   [InlineQueryResultVoice](#inlinequeryresultvoice)

**Note:** All URLs passed in inline query results will be available to end users and therefore must be assumed to be **public**.

#### [](#inlinequeryresultarticle)InlineQueryResultArticle

Represents a link to an article or web page.

Field

Type

Description

type

String

Type of the result, must be *article*

id

String

Unique identifier for this result, 1-64 Bytes

title

String

Title of the result

input\_message\_content

[InputMessageContent](#inputmessagecontent)

Content of the message to be sent

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. [Inline keyboard](/bots/features#inline-keyboards) attached to the message

url

String

*Optional*. URL of the result

description

String

*Optional*. Short description of the result

thumbnail\_url

String

*Optional*. Url of the thumbnail for the result

thumbnail\_width

Integer

*Optional*. Thumbnail width

thumbnail\_height

Integer

*Optional*. Thumbnail height

#### [](#inlinequeryresultphoto)InlineQueryResultPhoto

Represents a link to a photo. By default, this photo will be sent by the user with optional caption. Alternatively, you can use *input\_message\_content* to send a message with the specified content instead of the photo.

Field

Type

Description

type

String

Type of the result, must be *photo*

id

String

Unique identifier for this result, 1-64 bytes

photo\_url

String

A valid URL of the photo. Photo must be in **JPEG** format. Photo size must not exceed 5MB

thumbnail\_url

String

URL of the thumbnail for the photo

photo\_width

Integer

*Optional*. Width of the photo

photo\_height

Integer

*Optional*. Height of the photo

title

String

*Optional*. Title for the result

description

String

*Optional*. Short description of the result

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

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. [Inline keyboard](/bots/features#inline-keyboards) attached to the message

input\_message\_content

[InputMessageContent](#inputmessagecontent)

*Optional*. Content of the message to be sent instead of the photo

#### [](#inlinequeryresultgif)InlineQueryResultGif

Represents a link to an animated GIF file. By default, this animated GIF file will be sent by the user with optional caption. Alternatively, you can use *input\_message\_content* to send a message with the specified content instead of the animation.

Field

Type

Description

type

String

Type of the result, must be *gif*

id

String

Unique identifier for this result, 1-64 bytes

gif\_url

String

A valid URL for the GIF file

gif\_width

Integer

*Optional*. Width of the GIF

gif\_height

Integer

*Optional*. Height of the GIF

gif\_duration

Integer

*Optional*. Duration of the GIF in seconds

thumbnail\_url

String

URL of the static (JPEG or GIF) or animated (MPEG4) thumbnail for the result

thumbnail\_mime\_type

String

*Optional*. MIME type of the thumbnail, must be one of “image/jpeg”, “image/gif”, or “video/mp4”. Defaults to “image/jpeg”

title

String

*Optional*. Title for the result

caption

String

*Optional*. Caption of the GIF file to be sent, 0-1024 characters after entities parsing

parse\_mode

String

*Optional*. Mode for parsing entities in the caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

*Optional*. List of special entities that appear in the caption, which can be specified instead of *parse\_mode*

show\_caption\_above\_media

Boolean

*Optional*. Pass *True*, if the caption must be shown above the message media

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. [Inline keyboard](/bots/features#inline-keyboards) attached to the message

input\_message\_content

[InputMessageContent](#inputmessagecontent)

*Optional*. Content of the message to be sent instead of the GIF animation

#### [](#inlinequeryresultmpeg4gif)InlineQueryResultMpeg4Gif

Represents a link to a video animation (H.264/MPEG-4 AVC video without sound). By default, this animated MPEG-4 file will be sent by the user with optional caption. Alternatively, you can use *input\_message\_content* to send a message with the specified content instead of the animation.

Field

Type

Description

type

String

Type of the result, must be *mpeg4\_gif*

id

String

Unique identifier for this result, 1-64 bytes

mpeg4\_url

String

A valid URL for the MPEG4 file

mpeg4\_width

Integer

*Optional*. Video width

mpeg4\_height

Integer

*Optional*. Video height

mpeg4\_duration

Integer

*Optional*. Video duration in seconds

thumbnail\_url

String

URL of the static (JPEG or GIF) or animated (MPEG4) thumbnail for the result

thumbnail\_mime\_type

String

*Optional*. MIME type of the thumbnail, must be one of “image/jpeg”, “image/gif”, or “video/mp4”. Defaults to “image/jpeg”

title

String

*Optional*. Title for the result

caption

String

*Optional*. Caption of the MPEG-4 file to be sent, 0-1024 characters after entities parsing

parse\_mode

String

*Optional*. Mode for parsing entities in the caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

*Optional*. List of special entities that appear in the caption, which can be specified instead of *parse\_mode*

show\_caption\_above\_media

Boolean

*Optional*. Pass *True*, if the caption must be shown above the message media

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. [Inline keyboard](/bots/features#inline-keyboards) attached to the message

input\_message\_content

[InputMessageContent](#inputmessagecontent)

*Optional*. Content of the message to be sent instead of the video animation

#### [](#inlinequeryresultvideo)InlineQueryResultVideo

Represents a link to a page containing an embedded video player or a video file. By default, this video file will be sent by the user with an optional caption. Alternatively, you can use *input\_message\_content* to send a message with the specified content instead of the video.

> If an InlineQueryResultVideo message contains an embedded video (e.g., YouTube), you **must** replace its content using *input\_message\_content*.

Field

Type

Description

type

String

Type of the result, must be *video*

id

String

Unique identifier for this result, 1-64 bytes

video\_url

String

A valid URL for the embedded video player or video file

mime\_type

String

MIME type of the content of the video URL, “text/html” or “video/mp4”

thumbnail\_url

String

URL of the thumbnail (JPEG only) for the video

title

String

Title for the result

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

video\_width

Integer

*Optional*. Video width

video\_height

Integer

*Optional*. Video height

video\_duration

Integer

*Optional*. Video duration in seconds

description

String

*Optional*. Short description of the result

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. [Inline keyboard](/bots/features#inline-keyboards) attached to the message

input\_message\_content

[InputMessageContent](#inputmessagecontent)

*Optional*. Content of the message to be sent instead of the video. This field is **required** if InlineQueryResultVideo is used to send an HTML-page as a result (e.g., a YouTube video).

#### [](#inlinequeryresultaudio)InlineQueryResultAudio

Represents a link to an MP3 audio file. By default, this audio file will be sent by the user. Alternatively, you can use *input\_message\_content* to send a message with the specified content instead of the audio.

Field

Type

Description

type

String

Type of the result, must be *audio*

id

String

Unique identifier for this result, 1-64 bytes

audio\_url

String

A valid URL for the audio file

title

String

Title

caption

String

*Optional*. Caption, 0-1024 characters after entities parsing

parse\_mode

String

*Optional*. Mode for parsing entities in the audio caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

*Optional*. List of special entities that appear in the caption, which can be specified instead of *parse\_mode*

performer

String

*Optional*. Performer

audio\_duration

Integer

*Optional*. Audio duration in seconds

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. [Inline keyboard](/bots/features#inline-keyboards) attached to the message

input\_message\_content

[InputMessageContent](#inputmessagecontent)

*Optional*. Content of the message to be sent instead of the audio

#### [](#inlinequeryresultvoice)InlineQueryResultVoice

Represents a link to a voice recording in an .OGG container encoded with OPUS. By default, this voice recording will be sent by the user. Alternatively, you can use *input\_message\_content* to send a message with the specified content instead of the the voice message.

Field

Type

Description

type

String

Type of the result, must be *voice*

id

String

Unique identifier for this result, 1-64 bytes

voice\_url

String

A valid URL for the voice recording

title

String

Recording title

caption

String

*Optional*. Caption, 0-1024 characters after entities parsing

parse\_mode

String

*Optional*. Mode for parsing entities in the voice message caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

*Optional*. List of special entities that appear in the caption, which can be specified instead of *parse\_mode*

voice\_duration

Integer

*Optional*. Recording duration in seconds

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. [Inline keyboard](/bots/features#inline-keyboards) attached to the message

input\_message\_content

[InputMessageContent](#inputmessagecontent)

*Optional*. Content of the message to be sent instead of the voice recording

#### [](#inlinequeryresultdocument)InlineQueryResultDocument

Represents a link to a file. By default, this file will be sent by the user with an optional caption. Alternatively, you can use *input\_message\_content* to send a message with the specified content instead of the file. Currently, only **.PDF** and **.ZIP** files can be sent using this method.

Field

Type

Description

type

String

Type of the result, must be *document*

id

String

Unique identifier for this result, 1-64 bytes

title

String

Title for the result

caption

String

*Optional*. Caption of the document to be sent, 0-1024 characters after entities parsing

parse\_mode

String

*Optional*. Mode for parsing entities in the document caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

*Optional*. List of special entities that appear in the caption, which can be specified instead of *parse\_mode*

document\_url

String

A valid URL for the file

mime\_type

String

MIME type of the content of the file, either “application/pdf” or “application/zip”

description

String

*Optional*. Short description of the result

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. Inline keyboard attached to the message

input\_message\_content

[InputMessageContent](#inputmessagecontent)

*Optional*. Content of the message to be sent instead of the file

thumbnail\_url

String

*Optional*. URL of the thumbnail (JPEG only) for the file

thumbnail\_width

Integer

*Optional*. Thumbnail width

thumbnail\_height

Integer

*Optional*. Thumbnail height

#### [](#inlinequeryresultlocation)InlineQueryResultLocation

Represents a location on a map. By default, the location will be sent by the user. Alternatively, you can use *input\_message\_content* to send a message with the specified content instead of the location.

Field

Type

Description

type

String

Type of the result, must be *location*

id

String

Unique identifier for this result, 1-64 Bytes

latitude

Float

Location latitude in degrees

longitude

Float

Location longitude in degrees

title

String

Location title

horizontal\_accuracy

Float

*Optional*. The radius of uncertainty for the location, measured in meters; 0-1500

live\_period

Integer

*Optional*. Period in seconds during which the location can be updated, should be between 60 and 86400, or 0x7FFFFFFF for live locations that can be edited indefinitely.

heading

Integer

*Optional*. For live locations, a direction in which the user is moving, in degrees. Must be between 1 and 360 if specified.

proximity\_alert\_radius

Integer

*Optional*. For live locations, a maximum distance for proximity alerts about approaching another chat member, in meters. Must be between 1 and 100000 if specified.

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. [Inline keyboard](/bots/features#inline-keyboards) attached to the message

input\_message\_content

[InputMessageContent](#inputmessagecontent)

*Optional*. Content of the message to be sent instead of the location

thumbnail\_url

String

*Optional*. Url of the thumbnail for the result

thumbnail\_width

Integer

*Optional*. Thumbnail width

thumbnail\_height

Integer

*Optional*. Thumbnail height

#### [](#inlinequeryresultvenue)InlineQueryResultVenue

Represents a venue. By default, the venue will be sent by the user. Alternatively, you can use *input\_message\_content* to send a message with the specified content instead of the venue.

Field

Type

Description

type

String

Type of the result, must be *venue*

id

String

Unique identifier for this result, 1-64 Bytes

latitude

Float

Latitude of the venue location in degrees

longitude

Float

Longitude of the venue location in degrees

title

String

Title of the venue

address

String

Address of the venue

foursquare\_id

String

*Optional*. Foursquare identifier of the venue if known

foursquare\_type

String

*Optional*. Foursquare type of the venue, if known. (For example, “arts\_entertainment/default”, “arts\_entertainment/aquarium” or “food/icecream”.)

google\_place\_id

String

*Optional*. Google Places identifier of the venue

google\_place\_type

String

*Optional*. Google Places type of the venue. (See [supported types](https://developers.google.com/places/web-service/supported_types).)

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. [Inline keyboard](/bots/features#inline-keyboards) attached to the message

input\_message\_content

[InputMessageContent](#inputmessagecontent)

*Optional*. Content of the message to be sent instead of the venue

thumbnail\_url

String

*Optional*. Url of the thumbnail for the result

thumbnail\_width

Integer

*Optional*. Thumbnail width

thumbnail\_height

Integer

*Optional*. Thumbnail height

#### [](#inlinequeryresultcontact)InlineQueryResultContact

Represents a contact with a phone number. By default, this contact will be sent by the user. Alternatively, you can use *input\_message\_content* to send a message with the specified content instead of the contact.

Field

Type

Description

type

String

Type of the result, must be *contact*

id

String

Unique identifier for this result, 1-64 Bytes

phone\_number

String

Contact's phone number

first\_name

String

Contact's first name

last\_name

String

*Optional*. Contact's last name

vcard

String

*Optional*. Additional data about the contact in the form of a [vCard](https://en.wikipedia.org/wiki/VCard), 0-2048 bytes

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. [Inline keyboard](/bots/features#inline-keyboards) attached to the message

input\_message\_content

[InputMessageContent](#inputmessagecontent)

*Optional*. Content of the message to be sent instead of the contact

thumbnail\_url

String

*Optional*. Url of the thumbnail for the result

thumbnail\_width

Integer

*Optional*. Thumbnail width

thumbnail\_height

Integer

*Optional*. Thumbnail height

#### [](#inlinequeryresultgame)InlineQueryResultGame

Represents a [Game](#games).

Field

Type

Description

type

String

Type of the result, must be *game*

id

String

Unique identifier for this result, 1-64 bytes

game\_short\_name

String

Short name of the game

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. [Inline keyboard](/bots/features#inline-keyboards) attached to the message

#### [](#inlinequeryresultcachedphoto)InlineQueryResultCachedPhoto

Represents a link to a photo stored on the Telegram servers. By default, this photo will be sent by the user with an optional caption. Alternatively, you can use *input\_message\_content* to send a message with the specified content instead of the photo.

Field

Type

Description

type

String

Type of the result, must be *photo*

id

String

Unique identifier for this result, 1-64 bytes

photo\_file\_id

String

A valid file identifier of the photo

title

String

*Optional*. Title for the result

description

String

*Optional*. Short description of the result

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

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. [Inline keyboard](/bots/features#inline-keyboards) attached to the message

input\_message\_content

[InputMessageContent](#inputmessagecontent)

*Optional*. Content of the message to be sent instead of the photo

#### [](#inlinequeryresultcachedgif)InlineQueryResultCachedGif

Represents a link to an animated GIF file stored on the Telegram servers. By default, this animated GIF file will be sent by the user with an optional caption. Alternatively, you can use *input\_message\_content* to send a message with specified content instead of the animation.

Field

Type

Description

type

String

Type of the result, must be *gif*

id

String

Unique identifier for this result, 1-64 bytes

gif\_file\_id

String

A valid file identifier for the GIF file

title

String

*Optional*. Title for the result

caption

String

*Optional*. Caption of the GIF file to be sent, 0-1024 characters after entities parsing

parse\_mode

String

*Optional*. Mode for parsing entities in the caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

*Optional*. List of special entities that appear in the caption, which can be specified instead of *parse\_mode*

show\_caption\_above\_media

Boolean

*Optional*. Pass *True*, if the caption must be shown above the message media

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. [Inline keyboard](/bots/features#inline-keyboards) attached to the message

input\_message\_content

[InputMessageContent](#inputmessagecontent)

*Optional*. Content of the message to be sent instead of the GIF animation

#### [](#inlinequeryresultcachedmpeg4gif)InlineQueryResultCachedMpeg4Gif

Represents a link to a video animation (H.264/MPEG-4 AVC video without sound) stored on the Telegram servers. By default, this animated MPEG-4 file will be sent by the user with an optional caption. Alternatively, you can use *input\_message\_content* to send a message with the specified content instead of the animation.

Field

Type

Description

type

String

Type of the result, must be *mpeg4\_gif*

id

String

Unique identifier for this result, 1-64 bytes

mpeg4\_file\_id

String

A valid file identifier for the MPEG4 file

title

String

*Optional*. Title for the result

caption

String

*Optional*. Caption of the MPEG-4 file to be sent, 0-1024 characters after entities parsing

parse\_mode

String

*Optional*. Mode for parsing entities in the caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

*Optional*. List of special entities that appear in the caption, which can be specified instead of *parse\_mode*

show\_caption\_above\_media

Boolean

*Optional*. Pass *True*, if the caption must be shown above the message media

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. [Inline keyboard](/bots/features#inline-keyboards) attached to the message

input\_message\_content

[InputMessageContent](#inputmessagecontent)

*Optional*. Content of the message to be sent instead of the video animation

#### [](#inlinequeryresultcachedsticker)InlineQueryResultCachedSticker

Represents a link to a sticker stored on the Telegram servers. By default, this sticker will be sent by the user. Alternatively, you can use *input\_message\_content* to send a message with the specified content instead of the sticker.

Field

Type

Description

type

String

Type of the result, must be *sticker*

id

String

Unique identifier for this result, 1-64 bytes

sticker\_file\_id

String

A valid file identifier of the sticker

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. [Inline keyboard](/bots/features#inline-keyboards) attached to the message

input\_message\_content

[InputMessageContent](#inputmessagecontent)

*Optional*. Content of the message to be sent instead of the sticker

#### [](#inlinequeryresultcacheddocument)InlineQueryResultCachedDocument

Represents a link to a file stored on the Telegram servers. By default, this file will be sent by the user with an optional caption. Alternatively, you can use *input\_message\_content* to send a message with the specified content instead of the file.

Field

Type

Description

type

String

Type of the result, must be *document*

id

String

Unique identifier for this result, 1-64 bytes

title

String

Title for the result

document\_file\_id

String

A valid file identifier for the file

description

String

*Optional*. Short description of the result

caption

String

*Optional*. Caption of the document to be sent, 0-1024 characters after entities parsing

parse\_mode

String

*Optional*. Mode for parsing entities in the document caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

*Optional*. List of special entities that appear in the caption, which can be specified instead of *parse\_mode*

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. [Inline keyboard](/bots/features#inline-keyboards) attached to the message

input\_message\_content

[InputMessageContent](#inputmessagecontent)

*Optional*. Content of the message to be sent instead of the file

#### [](#inlinequeryresultcachedvideo)InlineQueryResultCachedVideo

Represents a link to a video file stored on the Telegram servers. By default, this video file will be sent by the user with an optional caption. Alternatively, you can use *input\_message\_content* to send a message with the specified content instead of the video.

Field

Type

Description

type

String

Type of the result, must be *video*

id

String

Unique identifier for this result, 1-64 bytes

video\_file\_id

String

A valid file identifier for the video file

title

String

Title for the result

description

String

*Optional*. Short description of the result

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

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. [Inline keyboard](/bots/features#inline-keyboards) attached to the message

input\_message\_content

[InputMessageContent](#inputmessagecontent)

*Optional*. Content of the message to be sent instead of the video

#### [](#inlinequeryresultcachedvoice)InlineQueryResultCachedVoice

Represents a link to a voice message stored on the Telegram servers. By default, this voice message will be sent by the user. Alternatively, you can use *input\_message\_content* to send a message with the specified content instead of the voice message.

Field

Type

Description

type

String

Type of the result, must be *voice*

id

String

Unique identifier for this result, 1-64 bytes

voice\_file\_id

String

A valid file identifier for the voice message

title

String

Voice message title

caption

String

*Optional*. Caption, 0-1024 characters after entities parsing

parse\_mode

String

*Optional*. Mode for parsing entities in the voice message caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

*Optional*. List of special entities that appear in the caption, which can be specified instead of *parse\_mode*

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. [Inline keyboard](/bots/features#inline-keyboards) attached to the message

input\_message\_content

[InputMessageContent](#inputmessagecontent)

*Optional*. Content of the message to be sent instead of the voice message

#### [](#inlinequeryresultcachedaudio)InlineQueryResultCachedAudio

Represents a link to an MP3 audio file stored on the Telegram servers. By default, this audio file will be sent by the user. Alternatively, you can use *input\_message\_content* to send a message with the specified content instead of the audio.

Field

Type

Description

type

String

Type of the result, must be *audio*

id

String

Unique identifier for this result, 1-64 bytes

audio\_file\_id

String

A valid file identifier for the audio file

caption

String

*Optional*. Caption, 0-1024 characters after entities parsing

parse\_mode

String

*Optional*. Mode for parsing entities in the audio caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

*Optional*. List of special entities that appear in the caption, which can be specified instead of *parse\_mode*

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

*Optional*. [Inline keyboard](/bots/features#inline-keyboards) attached to the message

input\_message\_content

[InputMessageContent](#inputmessagecontent)

*Optional*. Content of the message to be sent instead of the audio

#### [](#inputmessagecontent)InputMessageContent

This object represents the content of a message to be sent as a result of an inline query. Telegram clients currently support the following 5 types:

-   [InputTextMessageContent](#inputtextmessagecontent)
-   [InputLocationMessageContent](#inputlocationmessagecontent)
-   [InputVenueMessageContent](#inputvenuemessagecontent)
-   [InputContactMessageContent](#inputcontactmessagecontent)
-   [InputInvoiceMessageContent](#inputinvoicemessagecontent)

#### [](#inputtextmessagecontent)InputTextMessageContent

Represents the [content](#inputmessagecontent) of a text message to be sent as the result of an inline query.

Field

Type

Description

message\_text

String

Text of the message to be sent, 1-4096 characters

parse\_mode

String

*Optional*. Mode for parsing entities in the message text. See [formatting options](#formatting-options) for more details.

entities

Array of [MessageEntity](#messageentity)

*Optional*. List of special entities that appear in message text, which can be specified instead of *parse\_mode*

link\_preview\_options

[LinkPreviewOptions](#linkpreviewoptions)

*Optional*. Link preview generation options for the message

#### [](#inputlocationmessagecontent)InputLocationMessageContent

Represents the [content](#inputmessagecontent) of a location message to be sent as the result of an inline query.

Field

Type

Description

latitude

Float

Latitude of the location in degrees

longitude

Float

Longitude of the location in degrees

horizontal\_accuracy

Float

*Optional*. The radius of uncertainty for the location, measured in meters; 0-1500

live\_period

Integer

*Optional*. Period in seconds during which the location can be updated, should be between 60 and 86400, or 0x7FFFFFFF for live locations that can be edited indefinitely.

heading

Integer

*Optional*. For live locations, a direction in which the user is moving, in degrees. Must be between 1 and 360 if specified.

proximity\_alert\_radius

Integer

*Optional*. For live locations, a maximum distance for proximity alerts about approaching another chat member, in meters. Must be between 1 and 100000 if specified.

#### [](#inputvenuemessagecontent)InputVenueMessageContent

Represents the [content](#inputmessagecontent) of a venue message to be sent as the result of an inline query.

Field

Type

Description

latitude

Float

Latitude of the venue in degrees

longitude

Float

Longitude of the venue in degrees

title

String

Name of the venue

address

String

Address of the venue

foursquare\_id

String

*Optional*. Foursquare identifier of the venue, if known

foursquare\_type

String

*Optional*. Foursquare type of the venue, if known. (For example, “arts\_entertainment/default”, “arts\_entertainment/aquarium” or “food/icecream”.)

google\_place\_id

String

*Optional*. Google Places identifier of the venue

google\_place\_type

String

*Optional*. Google Places type of the venue. (See [supported types](https://developers.google.com/places/web-service/supported_types).)

#### [](#inputcontactmessagecontent)InputContactMessageContent

Represents the [content](#inputmessagecontent) of a contact message to be sent as the result of an inline query.

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

vcard

String

*Optional*. Additional data about the contact in the form of a [vCard](https://en.wikipedia.org/wiki/VCard), 0-2048 bytes

#### [](#inputinvoicemessagecontent)InputInvoiceMessageContent

Represents the [content](#inputmessagecontent) of an invoice message to be sent as the result of an inline query.

Field

Type

Description

title

String

Product name, 1-32 characters

description

String

Product description, 1-255 characters

payload

String

Bot-defined invoice payload, 1-128 bytes. This will not be displayed to the user, use it for your internal processes.

provider\_token

String

*Optional*. Payment provider token, obtained via [@BotFather](https://t.me/botfather). Pass an empty string for payments in [Telegram Stars](https://t.me/BotNews/90).

currency

String

Three-letter ISO 4217 currency code, see [more on currencies](/bots/payments#supported-currencies). Pass “XTR” for payments in [Telegram Stars](https://t.me/BotNews/90).

prices

Array of [LabeledPrice](#labeledprice)

Price breakdown, a JSON-serialized list of components (e.g. product price, tax, discount, delivery cost, delivery tax, bonus, etc.). Must contain exactly one item for payments in [Telegram Stars](https://t.me/BotNews/90).

max\_tip\_amount

Integer

*Optional*. The maximum accepted amount for tips in the *smallest units* of the currency (integer, **not** float/double). For example, for a maximum tip of `US$ 1.45` pass `max_tip_amount = 145`. See the *exp* parameter in [currencies.json](/bots/payments/currencies.json), it shows the number of digits past the decimal point for each currency (2 for the majority of currencies). Defaults to 0. Not supported for payments in [Telegram Stars](https://t.me/BotNews/90).

suggested\_tip\_amounts

Array of Integer

*Optional*. A JSON-serialized array of suggested amounts of tip in the *smallest units* of the currency (integer, **not** float/double). At most 4 suggested tip amounts can be specified. The suggested tip amounts must be positive, passed in a strictly increased order and must not exceed *max\_tip\_amount*.

provider\_data

String

*Optional*. A JSON-serialized object for data about the invoice, which will be shared with the payment provider. A detailed description of the required fields should be provided by the payment provider.

photo\_url

String

*Optional*. URL of the product photo for the invoice. Can be a photo of the goods or a marketing image for a service.

photo\_size

Integer

*Optional*. Photo size in bytes

photo\_width

Integer

*Optional*. Photo width

photo\_height

Integer

*Optional*. Photo height

need\_name

Boolean

*Optional*. Pass *True* if you require the user's full name to complete the order. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

need\_phone\_number

Boolean

*Optional*. Pass *True* if you require the user's phone number to complete the order. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

need\_email

Boolean

*Optional*. Pass *True* if you require the user's email address to complete the order. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

need\_shipping\_address

Boolean

*Optional*. Pass *True* if you require the user's shipping address to complete the order. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

send\_phone\_number\_to\_provider

Boolean

*Optional*. Pass *True* if the user's phone number should be sent to the provider. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

send\_email\_to\_provider

Boolean

*Optional*. Pass *True* if the user's email address should be sent to the provider. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

is\_flexible

Boolean

*Optional*. Pass *True* if the final price depends on the shipping method. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

#### [](#choseninlineresult)ChosenInlineResult

Represents a [result](#inlinequeryresult) of an inline query that was chosen by the user and sent to their chat partner.

Field

Type

Description

result\_id

String

The unique identifier for the result that was chosen

from

[User](#user)

The user that chose the result

location

[Location](#location)

*Optional*. Sender location, only for bots that require user location

inline\_message\_id

String

*Optional*. Identifier of the sent inline message. Available only if there is an [inline keyboard](#inlinekeyboardmarkup) attached to the message. Will be also received in [callback queries](#callbackquery) and can be used to [edit](#updating-messages) the message.

query

String

The query that was used to obtain the result

**Note:** It is necessary to enable [inline feedback](/bots/inline#collecting-feedback) via [@BotFather](https://t.me/botfather) in order to receive these objects in updates.

#### [](#answerwebappquery)answerWebAppQuery

Use this method to set the result of an interaction with a [Web App](/bots/webapps) and send a corresponding message on behalf of the user to the chat from which the query originated. On success, a [SentWebAppMessage](#sentwebappmessage) object is returned.

Parameter

Type

Required

Description

web\_app\_query\_id

String

Yes

Unique identifier for the query to be answered

result

[InlineQueryResult](#inlinequeryresult)

Yes

A JSON-serialized object describing the message to be sent

#### [](#sentwebappmessage)SentWebAppMessage

Describes an inline message sent by a [Web App](/bots/webapps) on behalf of a user.

Field

Type

Description

inline\_message\_id

String

*Optional*. Identifier of the sent inline message. Available only if there is an [inline keyboard](#inlinekeyboardmarkup) attached to the message.

#### [](#savepreparedinlinemessage)savePreparedInlineMessage

Stores a message that can be sent by a user of a Mini App. Returns a [PreparedInlineMessage](#preparedinlinemessage) object.

Parameter

Type

Required

Description

user\_id

Integer

Yes

Unique identifier of the target user that can use the prepared message

result

[InlineQueryResult](#inlinequeryresult)

Yes

A JSON-serialized object describing the message to be sent

allow\_user\_chats

Boolean

Optional

Pass *True* if the message can be sent to private chats with users

allow\_bot\_chats

Boolean

Optional

Pass *True* if the message can be sent to private chats with bots

allow\_group\_chats

Boolean

Optional

Pass *True* if the message can be sent to group and supergroup chats

allow\_channel\_chats

Boolean

Optional

Pass *True* if the message can be sent to channel chats

#### [](#preparedinlinemessage)PreparedInlineMessage

Describes an inline message to be sent by a user of a Mini App.

Field

Type

Description

id

String

Unique identifier of the prepared message

expiration\_date

Integer

Expiration date of the prepared message, in Unix time. Expired prepared messages can no longer be used

