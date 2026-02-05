### [](#available-methods)Available methods

> All methods in the Bot API are case-insensitive. We support **GET** and **POST** HTTP methods. Use either [URL query string](https://en.wikipedia.org/wiki/Query_string) or *application/json* or *application/x-www-form-urlencoded* or *multipart/form-data* for passing parameters in Bot API requests.  
> On successful call, a JSON-object containing the result will be returned.

#### [](#getme)getMe

A simple method for testing your bot's authentication token. Requires no parameters. Returns basic information about the bot in form of a [User](#user) object.

#### [](#logout)logOut

Use this method to log out from the cloud Bot API server before launching the bot locally. You **must** log out the bot before running it locally, otherwise there is no guarantee that the bot will receive updates. After a successful call, you can immediately log in on a local server, but will not be able to log in back to the cloud Bot API server for 10 minutes. Returns *True* on success. Requires no parameters.

#### [](#close)close

Use this method to close the bot instance before moving it from one local server to another. You need to delete the webhook before calling this method to ensure that the bot isn't launched again after server restart. The method will return error 429 in the first 10 minutes after the bot is launched. Returns *True* on success. Requires no parameters.

#### [](#sendmessage)sendMessage

Use this method to send text messages. On success, the sent [Message](#message) is returned.

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

text

String

Yes

Text of the message to be sent, 1-4096 characters after entities parsing

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

#### [](#formatting-options)Formatting options

The Bot API supports basic formatting for messages. You can use bold, italic, underlined, strikethrough, spoiler text, block quotations as well as inline links and pre-formatted code in your bots' messages. Telegram clients will render them accordingly. You can specify text entities directly, or use markdown-style or HTML-style formatting.

Note that Telegram clients will display an **alert** to the user before opening an inline link ('Open this link?' together with the full URL).

Message entities can be nested, providing following restrictions are met:  
\- If two entities have common characters, then one of them is fully contained inside another.  
\- *bold*, *italic*, *underline*, *strikethrough*, and *spoiler* entities can contain and can be part of any other entities, except *pre* and *code*.  
\- *blockquote* and *expandable\_blockquote* entities can't be nested.  
\- All other entities can't contain each other.

Links `tg://user?id=<user_id>` can be used to mention a user by their identifier without using a username. Please note:

-   These links will work **only** if they are used inside an inline link or in an inline keyboard button. For example, they will not work, when used in a message text.
-   Unless the user is a member of the chat where they were mentioned, these mentions are only guaranteed to work if the user has contacted the bot in private in the past or has sent a callback query to the bot via an inline button and doesn't have Forwarded Messages privacy enabled for the bot.

You can find the list of programming and markup languages for which syntax highlighting is supported at [libprisma#supported-languages](https://github.com/TelegramMessenger/libprisma#supported-languages).

###### [](#markdownv2-style)MarkdownV2 style

To use this mode, pass *MarkdownV2* in the *parse\_mode* field. Use the following syntax in your message:

````
*bold \*text*
_italic \*text_
__underline__
~strikethrough~
||spoiler||
*bold _italic bold ~italic bold strikethrough ||italic bold strikethrough spoiler||~ __underline italic bold___ bold*
[inline URL](http://www.example.com/)
[inline mention of a user](tg://user?id=123456789)
![](tg://emoji?id=5368324170671202286)
`inline fixed-width code`
```
pre-formatted fixed-width code block
```
```python
pre-formatted fixed-width code block written in the Python programming language
```
>Block quotation started
>Block quotation continued
>Block quotation continued
>Block quotation continued
>The last line of the block quotation
**>The expandable block quotation started right after the previous block quotation
>It is separated from the previous block quotation by an empty bold entity
>Expandable block quotation continued
>Hidden by default part of the expandable block quotation started
>Expandable block quotation continued
>The last line of the expandable block quotation with the expandability mark||
````

Please note:

-   Any character with code between 1 and 126 inclusively can be escaped anywhere with a preceding '\\' character, in which case it is treated as an ordinary character and not a part of the markup. This implies that '\\' character usually must be escaped with a preceding '\\' character.
-   Inside `pre` and `code` entities, all '\`' and '\\' characters must be escaped with a preceding '\\' character.
-   Inside the `(...)` part of the inline link and custom emoji definition, all ')' and '\\' must be escaped with a preceding '\\' character.
-   In all other places characters '\_', '\*', '\[', '\]', '(', ')', '~', '\`', '>', '#', '+', '-', '=', '|', '{', '}', '.', '!' must be escaped with the preceding character '\\'.
-   In case of ambiguity between `italic` and `underline` entities `__` is always greedily treated from left to right as beginning or end of an `underline` entity, so instead of `___italic underline___` use `___italic underline_**__`, adding an empty bold entity as a separator.
-   A valid emoji must be provided as an alternative value for the custom emoji. The emoji will be shown instead of the custom emoji in places where a custom emoji cannot be displayed (e.g., system notifications) or if the message is forwarded by a non-premium user. It is recommended to use the emoji from the **emoji** field of the custom emoji [sticker](#sticker).
-   Custom emoji entities can only be used by bots that purchased additional usernames on [Fragment](https://fragment.com).

###### [](#html-style)HTML style

To use this mode, pass *HTML* in the *parse\_mode* field. The following tags are currently supported:

```
<b>bold</b>, <strong>bold</strong>
<i>italic</i>, <em>italic</em>
<u>underline</u>, <ins>underline</ins>
<s>strikethrough</s>, <strike>strikethrough</strike>, <del>strikethrough</del>
<span class="tg-spoiler">spoiler</span>, <tg-spoiler>spoiler</tg-spoiler>
<b>bold <i>italic bold <s>italic bold strikethrough <span class="tg-spoiler">italic bold strikethrough spoiler</span></s> <u>underline italic bold</u></i> bold</b>
<a href="http://www.example.com/">inline URL</a>
<a href="tg://user?id=123456789">inline mention of a user</a>
<tg-emoji emoji-id="5368324170671202286"></tg-emoji>
<code>inline fixed-width code</code>
<pre>pre-formatted fixed-width code block</pre>
<pre><code class="language-python">pre-formatted fixed-width code block written in the Python programming language</code></pre>
<blockquote>Block quotation started\nBlock quotation continued\nThe last line of the block quotation</blockquote>
<blockquote expandable>Expandable block quotation started\nExpandable block quotation continued\nExpandable block quotation continued\nHidden by default part of the block quotation started\nExpandable block quotation continued\nThe last line of the block quotation</blockquote>
```

Please note:

-   Only the tags mentioned above are currently supported.
-   All `<`, `>` and `&` symbols that are not a part of a tag or an HTML entity must be replaced with the corresponding HTML entities (`<` with `&lt;`, `>` with `&gt;` and `&` with `&amp;`).
-   All numerical HTML entities are supported.
-   The API currently supports only the following named HTML entities: `&lt;`, `&gt;`, `&amp;` and `&quot;`.
-   Use nested `pre` and `code` tags, to define programming language for `pre` entity.
-   Programming language can't be specified for standalone `code` tags.
-   A valid emoji must be used as the content of the `tg-emoji` tag. The emoji will be shown instead of the custom emoji in places where a custom emoji cannot be displayed (e.g., system notifications) or if the message is forwarded by a non-premium user. It is recommended to use the emoji from the **emoji** field of the custom emoji [sticker](#sticker).
-   Custom emoji entities can only be used by bots that purchased additional usernames on [Fragment](https://fragment.com).

###### [](#markdown-style)Markdown style

This is a legacy mode, retained for backward compatibility. To use this mode, pass *Markdown* in the *parse\_mode* field. Use the following syntax in your message:

````
*bold text*
_italic text_
[inline URL](http://www.example.com/)
[inline mention of a user](tg://user?id=123456789)
`inline fixed-width code`
```
pre-formatted fixed-width code block
```
```python
pre-formatted fixed-width code block written in the Python programming language
```
````

Please note:

-   Entities must not be nested, use parse mode [MarkdownV2](#markdownv2-style) instead.
-   There is no way to specify “underline”, “strikethrough”, “spoiler”, “blockquote”, “expandable\_blockquote” and “custom\_emoji” entities, use parse mode [MarkdownV2](#markdownv2-style) instead.
-   To escape characters '\_', '\*', '\`', '\[' outside of an entity, prepend the character '\\' before them.
-   Escaping inside entities is not allowed, so entity must be closed first and reopened again: use `_snake_\__case_` for italic `snake_case` and `*2*\**2=4*` for bold `2*2=4`.

#### [](#paid-broadcasts)Paid Broadcasts

By default, all bots are able to broadcast up to [30 messages](https://core.telegram.org/bots/faq#my-bot-is-hitting-limits-how-do-i-avoid-this) per second to their users. Developers can increase this limit by enabling *Paid Broadcasts* in [@Botfather](https://t.me/botfather) - allowing their bot to broadcast **up to 1000 messages** per second.

Each message broadcasted over the free amount of 30 messages per second incurs a cost of 0.1 Stars per message, paid with Telegram Stars from the bot's balance. In order to use this feature, a bot must have at least *10,000 Stars* on its balance.

> Bots with increased limits are only charged for messages that are broadcasted successfully.

#### [](#forwardmessage)forwardMessage

Use this method to forward messages of any kind. Service messages and messages with protected content can't be forwarded. On success, the sent [Message](#message) is returned.

Parameter

Type

Required

Description

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

Identifier of the direct messages topic to which the message will be forwarded; required if the message is forwarded to a direct messages chat

from\_chat\_id

Integer or String

Yes

Unique identifier for the chat where the original message was sent (or channel username in the format `@channelusername`)

video\_start\_timestamp

Integer

Optional

New start timestamp for the forwarded video in the message

disable\_notification

Boolean

Optional

Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.

protect\_content

Boolean

Optional

Protects the contents of the forwarded message from forwarding and saving

message\_effect\_id

String

Optional

Unique identifier of the message effect to be added to the message; only available when forwarding to private chats

suggested\_post\_parameters

[SuggestedPostParameters](#suggestedpostparameters)

Optional

A JSON-serialized object containing the parameters of the suggested post to send; for direct messages chats only

message\_id

Integer

Yes

Message identifier in the chat specified in *from\_chat\_id*

#### [](#forwardmessages)forwardMessages

Use this method to forward multiple messages of any kind. If some of the specified messages can't be found or forwarded, they are skipped. Service messages and messages with protected content can't be forwarded. Album grouping is kept for forwarded messages. On success, an array of [MessageId](#messageid) of the sent messages is returned.

Parameter

Type

Required

Description

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

Identifier of the direct messages topic to which the messages will be forwarded; required if the messages are forwarded to a direct messages chat

from\_chat\_id

Integer or String

Yes

Unique identifier for the chat where the original messages were sent (or channel username in the format `@channelusername`)

message\_ids

Array of Integer

Yes

A JSON-serialized list of 1-100 identifiers of messages in the chat *from\_chat\_id* to forward. The identifiers must be specified in a strictly increasing order.

disable\_notification

Boolean

Optional

Sends the messages [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.

protect\_content

Boolean

Optional

Protects the contents of the forwarded messages from forwarding and saving

#### [](#copymessage)copyMessage

Use this method to copy messages of any kind. Service messages, paid media messages, giveaway messages, giveaway winners messages, and invoice messages can't be copied. A quiz [poll](#poll) can be copied only if the value of the field *correct\_option\_id* is known to the bot. The method is analogous to the method [forwardMessage](#forwardmessage), but the copied message doesn't have a link to the original message. Returns the [MessageId](#messageid) of the sent message on success.

Parameter

Type

Required

Description

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

from\_chat\_id

Integer or String

Yes

Unique identifier for the chat where the original message was sent (or channel username in the format `@channelusername`)

message\_id

Integer

Yes

Message identifier in the chat specified in *from\_chat\_id*

video\_start\_timestamp

Integer

Optional

New start timestamp for the copied video in the message

caption

String

Optional

New caption for media, 0-1024 characters after entities parsing. If not specified, the original caption is kept

parse\_mode

String

Optional

Mode for parsing entities in the new caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

Optional

A JSON-serialized list of special entities that appear in the new caption, which can be specified instead of *parse\_mode*

show\_caption\_above\_media

Boolean

Optional

Pass *True*, if the caption must be shown above the message media. Ignored if a new caption isn't specified.

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

Unique identifier of the message effect to be added to the message; only available when copying to private chats

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

#### [](#copymessages)copyMessages

Use this method to copy messages of any kind. If some of the specified messages can't be found or copied, they are skipped. Service messages, paid media messages, giveaway messages, giveaway winners messages, and invoice messages can't be copied. A quiz [poll](#poll) can be copied only if the value of the field *correct\_option\_id* is known to the bot. The method is analogous to the method [forwardMessages](#forwardmessages), but the copied messages don't have a link to the original message. Album grouping is kept for copied messages. On success, an array of [MessageId](#messageid) of the sent messages is returned.

Parameter

Type

Required

Description

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

Identifier of the direct messages topic to which the messages will be sent; required if the messages are sent to a direct messages chat

from\_chat\_id

Integer or String

Yes

Unique identifier for the chat where the original messages were sent (or channel username in the format `@channelusername`)

message\_ids

Array of Integer

Yes

A JSON-serialized list of 1-100 identifiers of messages in the chat *from\_chat\_id* to copy. The identifiers must be specified in a strictly increasing order.

disable\_notification

Boolean

Optional

Sends the messages [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.

protect\_content

Boolean

Optional

Protects the contents of the sent messages from forwarding and saving

remove\_caption

Boolean

Optional

Pass *True* to copy the messages without their captions

#### [](#sendphoto)sendPhoto

Use this method to send photos. On success, the sent [Message](#message) is returned.

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

photo

[InputFile](#inputfile) or String

Yes

Photo to send. Pass a file\_id as String to send a photo that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a photo from the Internet, or upload a new photo using multipart/form-data. The photo must be at most 10 MB in size. The photo's width and height must not exceed 10000 in total. Width and height ratio must be at most 20. [More information on Sending Files »](#sending-files)

caption

String

Optional

Photo caption (may also be used when resending photos by *file\_id*), 0-1024 characters after entities parsing

parse\_mode

String

Optional

Mode for parsing entities in the photo caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

Optional

A JSON-serialized list of special entities that appear in the caption, which can be specified instead of *parse\_mode*

show\_caption\_above\_media

Boolean

Optional

Pass *True*, if the caption must be shown above the message media

has\_spoiler

Boolean

Optional

Pass *True* if the photo needs to be covered with a spoiler animation

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

#### [](#sendaudio)sendAudio

Use this method to send audio files, if you want Telegram clients to display them in the music player. Your audio must be in the .MP3 or .M4A format. On success, the sent [Message](#message) is returned. Bots can currently send audio files of up to 50 MB in size, this limit may be changed in the future.

For sending voice messages, use the [sendVoice](#sendvoice) method instead.

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

audio

[InputFile](#inputfile) or String

Yes

Audio file to send. Pass a file\_id as String to send an audio file that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get an audio file from the Internet, or upload a new one using multipart/form-data. [More information on Sending Files »](#sending-files)

caption

String

Optional

Audio caption, 0-1024 characters after entities parsing

parse\_mode

String

Optional

Mode for parsing entities in the audio caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

Optional

A JSON-serialized list of special entities that appear in the caption, which can be specified instead of *parse\_mode*

duration

Integer

Optional

Duration of the audio in seconds

performer

String

Optional

Performer

title

String

Optional

Track name

thumbnail

[InputFile](#inputfile) or String

Optional

Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass “attach://<file\_attach\_name>” if the thumbnail was uploaded using multipart/form-data under <file\_attach\_name>. [More information on Sending Files »](#sending-files)

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

#### [](#senddocument)sendDocument

Use this method to send general files. On success, the sent [Message](#message) is returned. Bots can currently send files of any type of up to 50 MB in size, this limit may be changed in the future.

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

document

[InputFile](#inputfile) or String

Yes

File to send. Pass a file\_id as String to send a file that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data. [More information on Sending Files »](#sending-files)

thumbnail

[InputFile](#inputfile) or String

Optional

Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass “attach://<file\_attach\_name>” if the thumbnail was uploaded using multipart/form-data under <file\_attach\_name>. [More information on Sending Files »](#sending-files)

caption

String

Optional

Document caption (may also be used when resending documents by *file\_id*), 0-1024 characters after entities parsing

parse\_mode

String

Optional

Mode for parsing entities in the document caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

Optional

A JSON-serialized list of special entities that appear in the caption, which can be specified instead of *parse\_mode*

disable\_content\_type\_detection

Boolean

Optional

Disables automatic server-side content type detection for files uploaded using multipart/form-data

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

#### [](#sendvideo)sendVideo

Use this method to send video files, Telegram clients support MPEG4 videos (other formats may be sent as [Document](#document)). On success, the sent [Message](#message) is returned. Bots can currently send video files of up to 50 MB in size, this limit may be changed in the future.

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

video

[InputFile](#inputfile) or String

Yes

Video to send. Pass a file\_id as String to send a video that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a video from the Internet, or upload a new video using multipart/form-data. [More information on Sending Files »](#sending-files)

duration

Integer

Optional

Duration of sent video in seconds

width

Integer

Optional

Video width

height

Integer

Optional

Video height

thumbnail

[InputFile](#inputfile) or String

Optional

Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass “attach://<file\_attach\_name>” if the thumbnail was uploaded using multipart/form-data under <file\_attach\_name>. [More information on Sending Files »](#sending-files)

cover

[InputFile](#inputfile) or String

Optional

Cover for the video in the message. Pass a file\_id to send a file that exists on the Telegram servers (recommended), pass an HTTP URL for Telegram to get a file from the Internet, or pass “attach://<file\_attach\_name>” to upload a new one using multipart/form-data under <file\_attach\_name> name. [More information on Sending Files »](#sending-files)

start\_timestamp

Integer

Optional

Start timestamp for the video in the message

caption

String

Optional

Video caption (may also be used when resending videos by *file\_id*), 0-1024 characters after entities parsing

parse\_mode

String

Optional

Mode for parsing entities in the video caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

Optional

A JSON-serialized list of special entities that appear in the caption, which can be specified instead of *parse\_mode*

show\_caption\_above\_media

Boolean

Optional

Pass *True*, if the caption must be shown above the message media

has\_spoiler

Boolean

Optional

Pass *True* if the video needs to be covered with a spoiler animation

supports\_streaming

Boolean

Optional

Pass *True* if the uploaded video is suitable for streaming

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

#### [](#sendanimation)sendAnimation

Use this method to send animation files (GIF or H.264/MPEG-4 AVC video without sound). On success, the sent [Message](#message) is returned. Bots can currently send animation files of up to 50 MB in size, this limit may be changed in the future.

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

animation

[InputFile](#inputfile) or String

Yes

Animation to send. Pass a file\_id as String to send an animation that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get an animation from the Internet, or upload a new animation using multipart/form-data. [More information on Sending Files »](#sending-files)

duration

Integer

Optional

Duration of sent animation in seconds

width

Integer

Optional

Animation width

height

Integer

Optional

Animation height

thumbnail

[InputFile](#inputfile) or String

Optional

Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass “attach://<file\_attach\_name>” if the thumbnail was uploaded using multipart/form-data under <file\_attach\_name>. [More information on Sending Files »](#sending-files)

caption

String

Optional

Animation caption (may also be used when resending animation by *file\_id*), 0-1024 characters after entities parsing

parse\_mode

String

Optional

Mode for parsing entities in the animation caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

Optional

A JSON-serialized list of special entities that appear in the caption, which can be specified instead of *parse\_mode*

show\_caption\_above\_media

Boolean

Optional

Pass *True*, if the caption must be shown above the message media

has\_spoiler

Boolean

Optional

Pass *True* if the animation needs to be covered with a spoiler animation

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

#### [](#sendvoice)sendVoice

Use this method to send audio files, if you want Telegram clients to display the file as a playable voice message. For this to work, your audio must be in an .OGG file encoded with OPUS, or in .MP3 format, or in .M4A format (other formats may be sent as [Audio](#audio) or [Document](#document)). On success, the sent [Message](#message) is returned. Bots can currently send voice messages of up to 50 MB in size, this limit may be changed in the future.

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

voice

[InputFile](#inputfile) or String

Yes

Audio file to send. Pass a file\_id as String to send a file that exists on the Telegram servers (recommended), pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data. [More information on Sending Files »](#sending-files)

caption

String

Optional

Voice message caption, 0-1024 characters after entities parsing

parse\_mode

String

Optional

Mode for parsing entities in the voice message caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

Optional

A JSON-serialized list of special entities that appear in the caption, which can be specified instead of *parse\_mode*

duration

Integer

Optional

Duration of the voice message in seconds

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

#### [](#sendvideonote)sendVideoNote

As of [v.4.0](https://telegram.org/blog/video-messages-and-telescope), Telegram clients support rounded square MPEG4 videos of up to 1 minute long. Use this method to send video messages. On success, the sent [Message](#message) is returned.

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

video\_note

[InputFile](#inputfile) or String

Yes

Video note to send. Pass a file\_id as String to send a video note that exists on the Telegram servers (recommended) or upload a new video using multipart/form-data. [More information on Sending Files »](#sending-files). Sending video notes by a URL is currently unsupported

duration

Integer

Optional

Duration of sent video in seconds

length

Integer

Optional

Video width and height, i.e. diameter of the video message

thumbnail

[InputFile](#inputfile) or String

Optional

Thumbnail of the file sent; can be ignored if thumbnail generation for the file is supported server-side. The thumbnail should be in JPEG format and less than 200 kB in size. A thumbnail's width and height should not exceed 320. Ignored if the file is not uploaded using multipart/form-data. Thumbnails can't be reused and can be only uploaded as a new file, so you can pass “attach://<file\_attach\_name>” if the thumbnail was uploaded using multipart/form-data under <file\_attach\_name>. [More information on Sending Files »](#sending-files)

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

#### [](#sendpaidmedia)sendPaidMedia

Use this method to send paid media. On success, the sent [Message](#message) is returned.

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

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`). If the chat is a channel, all Telegram Star proceeds from this media will be credited to the chat's balance. Otherwise, they will be credited to the bot's balance.

message\_thread\_id

Integer

Optional

Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only

direct\_messages\_topic\_id

Integer

Optional

Identifier of the direct messages topic to which the message will be sent; required if the message is sent to a direct messages chat

star\_count

Integer

Yes

The number of Telegram Stars that must be paid to buy access to the media; 1-25000

media

Array of [InputPaidMedia](#inputpaidmedia)

Yes

A JSON-serialized array describing the media to be sent; up to 10 items

payload

String

Optional

Bot-defined paid media payload, 0-128 bytes. This will not be displayed to the user, use it for your internal processes.

caption

String

Optional

Media caption, 0-1024 characters after entities parsing

parse\_mode

String

Optional

Mode for parsing entities in the media caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

Optional

A JSON-serialized list of special entities that appear in the caption, which can be specified instead of *parse\_mode*

show\_caption\_above\_media

Boolean

Optional

Pass *True*, if the caption must be shown above the message media

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

#### [](#sendmediagroup)sendMediaGroup

Use this method to send a group of photos, videos, documents or audios as an album. Documents and audio files can be only grouped in an album with messages of the same type. On success, an array of [Message](#message) objects that were sent is returned.

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

Identifier of the direct messages topic to which the messages will be sent; required if the messages are sent to a direct messages chat

media

Array of [InputMediaAudio](#inputmediaaudio), [InputMediaDocument](#inputmediadocument), [InputMediaPhoto](#inputmediaphoto) and [InputMediaVideo](#inputmediavideo)

Yes

A JSON-serialized array describing messages to be sent, must include 2-10 items

disable\_notification

Boolean

Optional

Sends messages [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.

protect\_content

Boolean

Optional

Protects the contents of the sent messages from forwarding and saving

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

#### [](#sendlocation)sendLocation

Use this method to send point on the map. On success, the sent [Message](#message) is returned.

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

latitude

Float

Yes

Latitude of the location

longitude

Float

Yes

Longitude of the location

horizontal\_accuracy

Float

Optional

The radius of uncertainty for the location, measured in meters; 0-1500

live\_period

Integer

Optional

Period in seconds during which the location will be updated (see [Live Locations](https://telegram.org/blog/live-locations), should be between 60 and 86400, or 0x7FFFFFFF for live locations that can be edited indefinitely.

heading

Integer

Optional

For live locations, a direction in which the user is moving, in degrees. Must be between 1 and 360 if specified.

proximity\_alert\_radius

Integer

Optional

For live locations, a maximum distance for proximity alerts about approaching another chat member, in meters. Must be between 1 and 100000 if specified.

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

#### [](#sendvenue)sendVenue

Use this method to send information about a venue. On success, the sent [Message](#message) is returned.

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

latitude

Float

Yes

Latitude of the venue

longitude

Float

Yes

Longitude of the venue

title

String

Yes

Name of the venue

address

String

Yes

Address of the venue

foursquare\_id

String

Optional

Foursquare identifier of the venue

foursquare\_type

String

Optional

Foursquare type of the venue, if known. (For example, “arts\_entertainment/default”, “arts\_entertainment/aquarium” or “food/icecream”.)

google\_place\_id

String

Optional

Google Places identifier of the venue

google\_place\_type

String

Optional

Google Places type of the venue. (See [supported types](https://developers.google.com/places/web-service/supported_types).)

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

#### [](#sendcontact)sendContact

Use this method to send phone contacts. On success, the sent [Message](#message) is returned.

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

phone\_number

String

Yes

Contact's phone number

first\_name

String

Yes

Contact's first name

last\_name

String

Optional

Contact's last name

vcard

String

Optional

Additional data about the contact in the form of a [vCard](https://en.wikipedia.org/wiki/VCard), 0-2048 bytes

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

#### [](#sendpoll)sendPoll

Use this method to send a native poll. On success, the sent [Message](#message) is returned.

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

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`). Polls can't be sent to channel direct messages chats.

message\_thread\_id

Integer

Optional

Unique identifier for the target message thread (topic) of a forum; for forum supergroups and private chats of bots with forum topic mode enabled only

question

String

Yes

Poll question, 1-300 characters

question\_parse\_mode

String

Optional

Mode for parsing entities in the question. See [formatting options](#formatting-options) for more details. Currently, only custom emoji entities are allowed

question\_entities

Array of [MessageEntity](#messageentity)

Optional

A JSON-serialized list of special entities that appear in the poll question. It can be specified instead of *question\_parse\_mode*

options

Array of [InputPollOption](#inputpolloption)

Yes

A JSON-serialized list of 2-12 answer options

is\_anonymous

Boolean

Optional

*True*, if the poll needs to be anonymous, defaults to *True*

type

String

Optional

Poll type, “quiz” or “regular”, defaults to “regular”

allows\_multiple\_answers

Boolean

Optional

*True*, if the poll allows multiple answers, ignored for polls in quiz mode, defaults to *False*

correct\_option\_id

Integer

Optional

0-based identifier of the correct answer option, required for polls in quiz mode

explanation

String

Optional

Text that is shown when a user chooses an incorrect answer or taps on the lamp icon in a quiz-style poll, 0-200 characters with at most 2 line feeds after entities parsing

explanation\_parse\_mode

String

Optional

Mode for parsing entities in the explanation. See [formatting options](#formatting-options) for more details.

explanation\_entities

Array of [MessageEntity](#messageentity)

Optional

A JSON-serialized list of special entities that appear in the poll explanation. It can be specified instead of *explanation\_parse\_mode*

open\_period

Integer

Optional

Amount of time in seconds the poll will be active after creation, 5-600. Can't be used together with *close\_date*.

close\_date

Integer

Optional

Point in time (Unix timestamp) when the poll will be automatically closed. Must be at least 5 and no more than 600 seconds in the future. Can't be used together with *open\_period*.

is\_closed

Boolean

Optional

Pass *True* if the poll needs to be immediately closed. This can be useful for poll preview.

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

[InlineKeyboardMarkup](#inlinekeyboardmarkup) or [ReplyKeyboardMarkup](#replykeyboardmarkup) or [ReplyKeyboardRemove](#replykeyboardremove) or [ForceReply](#forcereply)

Optional

Additional interface options. A JSON-serialized object for an [inline keyboard](/bots/features#inline-keyboards), [custom reply keyboard](/bots/features#keyboards), instructions to remove a reply keyboard or to force a reply from the user

#### [](#sendchecklist)sendChecklist

Use this method to send a checklist on behalf of a connected business account. On success, the sent [Message](#message) is returned.

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

checklist

[InputChecklist](#inputchecklist)

Yes

A JSON-serialized object for the checklist to send

disable\_notification

Boolean

Optional

Sends the message silently. Users will receive a notification with no sound.

protect\_content

Boolean

Optional

Protects the contents of the sent message from forwarding and saving

message\_effect\_id

String

Optional

Unique identifier of the message effect to be added to the message

reply\_parameters

[ReplyParameters](#replyparameters)

Optional

A JSON-serialized object for description of the message to reply to

reply\_markup

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

Optional

A JSON-serialized object for an inline keyboard

#### [](#senddice)sendDice

Use this method to send an animated emoji that will display a random value. On success, the sent [Message](#message) is returned.

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

emoji

String

Optional

Emoji on which the dice throw animation is based. Currently, must be one of “![🎲](//telegram.org/img/emoji/40/F09F8EB2.png)”, “![🎯](//telegram.org/img/emoji/40/F09F8EAF.png)”, “![🏀](//telegram.org/img/emoji/40/F09F8F80.png)”, “![⚽](//telegram.org/img/emoji/40/E29ABD.png)”, “![🎳](//telegram.org/img/emoji/40/F09F8EB3.png)”, or “![🎰](//telegram.org/img/emoji/40/F09F8EB0.png)”. Dice can have values 1-6 for “![🎲](//telegram.org/img/emoji/40/F09F8EB2.png)”, “![🎯](//telegram.org/img/emoji/40/F09F8EAF.png)” and “![🎳](//telegram.org/img/emoji/40/F09F8EB3.png)”, values 1-5 for “![🏀](//telegram.org/img/emoji/40/F09F8F80.png)” and “![⚽](//telegram.org/img/emoji/40/E29ABD.png)”, and values 1-64 for “![🎰](//telegram.org/img/emoji/40/F09F8EB0.png)”. Defaults to “![🎲](//telegram.org/img/emoji/40/F09F8EB2.png)”

disable\_notification

Boolean

Optional

Sends the message [silently](https://telegram.org/blog/channels-2-0#silent-messages). Users will receive a notification with no sound.

protect\_content

Boolean

Optional

Protects the contents of the sent message from forwarding

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

#### [](#sendmessagedraft)sendMessageDraft

Use this method to stream a partial message to a user while the message is being generated; supported only for bots with forum topic mode enabled. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer

Yes

Unique identifier for the target private chat

message\_thread\_id

Integer

Optional

Unique identifier for the target message thread

draft\_id

Integer

Yes

Unique identifier of the message draft; must be non-zero. Changes of drafts with the same identifier are animated

text

String

Yes

Text of the message to be sent, 1-4096 characters after entities parsing

parse\_mode

String

Optional

Mode for parsing entities in the message text. See [formatting options](#formatting-options) for more details.

entities

Array of [MessageEntity](#messageentity)

Optional

A JSON-serialized list of special entities that appear in message text, which can be specified instead of *parse\_mode*

#### [](#sendchataction)sendChatAction

Use this method when you need to tell the user that something is happening on the bot's side. The status is set for 5 seconds or less (when a message arrives from your bot, Telegram clients clear its typing status). Returns *True* on success.

> Example: The [ImageBot](https://t.me/imagebot) needs some time to process a request and upload the image. Instead of sending a text message along the lines of “Retrieving image, please wait…”, the bot may use [sendChatAction](#sendchataction) with *action* = *upload\_photo*. The user will see a “sending photo” status for the bot.

We only recommend using this method when a response from the bot will take a **noticeable** amount of time to arrive.

Parameter

Type

Required

Description

business\_connection\_id

String

Optional

Unique identifier of the business connection on behalf of which the action will be sent

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`). Channel chats and channel direct messages chats aren't supported.

message\_thread\_id

Integer

Optional

Unique identifier for the target message thread or topic of a forum; for supergroups and private chats of bots with forum topic mode enabled only

action

String

Yes

Type of action to broadcast. Choose one, depending on what the user is about to receive: *typing* for [text messages](#sendmessage), *upload\_photo* for [photos](#sendphoto), *record\_video* or *upload\_video* for [videos](#sendvideo), *record\_voice* or *upload\_voice* for [voice notes](#sendvoice), *upload\_document* for [general files](#senddocument), *choose\_sticker* for [stickers](#sendsticker), *find\_location* for [location data](#sendlocation), *record\_video\_note* or *upload\_video\_note* for [video notes](#sendvideonote).

#### [](#setmessagereaction)setMessageReaction

Use this method to change the chosen reactions on a message. Service messages of some types can't be reacted to. Automatically forwarded messages from a channel to its discussion group have the same available reactions as messages in the channel. Bots can't use paid reactions. Returns *True* on success.

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

Identifier of the target message. If the message belongs to a media group, the reaction is set to the first non-deleted message in the group instead.

reaction

Array of [ReactionType](#reactiontype)

Optional

A JSON-serialized list of reaction types to set on the message. Currently, as non-premium users, bots can set up to one reaction per message. A custom emoji reaction can be used if it is either already present on the message or explicitly allowed by chat administrators. Paid reactions can't be used by bots.

is\_big

Boolean

Optional

Pass *True* to set the reaction with a big animation

#### [](#getuserprofilephotos)getUserProfilePhotos

Use this method to get a list of profile pictures for a user. Returns a [UserProfilePhotos](#userprofilephotos) object.

Parameter

Type

Required

Description

user\_id

Integer

Yes

Unique identifier of the target user

offset

Integer

Optional

Sequential number of the first photo to be returned. By default, all photos are returned.

limit

Integer

Optional

Limits the number of photos to be retrieved. Values between 1-100 are accepted. Defaults to 100.

#### [](#setuseremojistatus)setUserEmojiStatus

Changes the emoji status for a given user that previously allowed the bot to manage their emoji status via the Mini App method [requestEmojiStatusAccess](/bots/webapps#initializing-mini-apps). Returns *True* on success.

Parameter

Type

Required

Description

user\_id

Integer

Yes

Unique identifier of the target user

emoji\_status\_custom\_emoji\_id

String

Optional

Custom emoji identifier of the emoji status to set. Pass an empty string to remove the status.

emoji\_status\_expiration\_date

Integer

Optional

Expiration date of the emoji status, if any

#### [](#getfile)getFile

Use this method to get basic information about a file and prepare it for downloading. For the moment, bots can download files of up to 20MB in size. On success, a [File](#file) object is returned. The file can then be downloaded via the link `https://api.telegram.org/file/bot<token>/<file_path>`, where `<file_path>` is taken from the response. It is guaranteed that the link will be valid for at least 1 hour. When the link expires, a new one can be requested by calling [getFile](#getfile) again.

Parameter

Type

Required

Description

file\_id

String

Yes

File identifier to get information about

**Note:** This function may not preserve the original file name and MIME type. You should save the file's MIME type and name (if available) when the File object is received.

#### [](#banchatmember)banChatMember

Use this method to ban a user in a group, a supergroup or a channel. In the case of supergroups and channels, the user will not be able to return to the chat on their own using invite links, etc., unless [unbanned](#unbanchatmember) first. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target group or username of the target supergroup or channel (in the format `@channelusername`)

user\_id

Integer

Yes

Unique identifier of the target user

until\_date

Integer

Optional

Date when the user will be unbanned; Unix time. If user is banned for more than 366 days or less than 30 seconds from the current time they are considered to be banned forever. Applied for supergroups and channels only.

revoke\_messages

Boolean

Optional

Pass *True* to delete all messages from the chat for the user that is being removed. If *False*, the user will be able to see messages in the group that were sent before the user was removed. Always *True* for supergroups and channels.

#### [](#unbanchatmember)unbanChatMember

Use this method to unban a previously banned user in a supergroup or channel. The user will **not** return to the group or channel automatically, but will be able to join via link, etc. The bot must be an administrator for this to work. By default, this method guarantees that after the call the user is not a member of the chat, but will be able to join it. So if the user is a member of the chat they will also be **removed** from the chat. If you don't want this, use the parameter *only\_if\_banned*. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target group or username of the target supergroup or channel (in the format `@channelusername`)

user\_id

Integer

Yes

Unique identifier of the target user

only\_if\_banned

Boolean

Optional

Do nothing if the user is not banned

#### [](#restrictchatmember)restrictChatMember

Use this method to restrict a user in a supergroup. The bot must be an administrator in the supergroup for this to work and must have the appropriate administrator rights. Pass *True* for all permissions to lift restrictions from a user. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)

user\_id

Integer

Yes

Unique identifier of the target user

permissions

[ChatPermissions](#chatpermissions)

Yes

A JSON-serialized object for new user permissions

use\_independent\_chat\_permissions

Boolean

Optional

Pass *True* if chat permissions are set independently. Otherwise, the *can\_send\_other\_messages* and *can\_add\_web\_page\_previews* permissions will imply the *can\_send\_messages*, *can\_send\_audios*, *can\_send\_documents*, *can\_send\_photos*, *can\_send\_videos*, *can\_send\_video\_notes*, and *can\_send\_voice\_notes* permissions; the *can\_send\_polls* permission will imply the *can\_send\_messages* permission.

until\_date

Integer

Optional

Date when restrictions will be lifted for the user; Unix time. If user is restricted for more than 366 days or less than 30 seconds from the current time, they are considered to be restricted forever

#### [](#promotechatmember)promoteChatMember

Use this method to promote or demote a user in a supergroup or a channel. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Pass *False* for all boolean parameters to demote a user. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

user\_id

Integer

Yes

Unique identifier of the target user

is\_anonymous

Boolean

Optional

Pass *True* if the administrator's presence in the chat is hidden

can\_manage\_chat

Boolean

Optional

Pass *True* if the administrator can access the chat event log, get boost list, see hidden supergroup and channel members, report spam messages, ignore slow mode, and send messages to the chat without paying Telegram Stars. Implied by any other administrator privilege.

can\_delete\_messages

Boolean

Optional

Pass *True* if the administrator can delete messages of other users

can\_manage\_video\_chats

Boolean

Optional

Pass *True* if the administrator can manage video chats

can\_restrict\_members

Boolean

Optional

Pass *True* if the administrator can restrict, ban or unban chat members, or access supergroup statistics. For backward compatibility, defaults to *True* for promotions of channel administrators

can\_promote\_members

Boolean

Optional

Pass *True* if the administrator can add new administrators with a subset of their own privileges or demote administrators that they have promoted, directly or indirectly (promoted by administrators that were appointed by him)

can\_change\_info

Boolean

Optional

Pass *True* if the administrator can change chat title, photo and other settings

can\_invite\_users

Boolean

Optional

Pass *True* if the administrator can invite new users to the chat

can\_post\_stories

Boolean

Optional

Pass *True* if the administrator can post stories to the chat

can\_edit\_stories

Boolean

Optional

Pass *True* if the administrator can edit stories posted by other users, post stories to the chat page, pin chat stories, and access the chat's story archive

can\_delete\_stories

Boolean

Optional

Pass *True* if the administrator can delete stories posted by other users

can\_post\_messages

Boolean

Optional

Pass *True* if the administrator can post messages in the channel, approve suggested posts, or access channel statistics; for channels only

can\_edit\_messages

Boolean

Optional

Pass *True* if the administrator can edit messages of other users and can pin messages; for channels only

can\_pin\_messages

Boolean

Optional

Pass *True* if the administrator can pin messages; for supergroups only

can\_manage\_topics

Boolean

Optional

Pass *True* if the user is allowed to create, rename, close, and reopen forum topics; for supergroups only

can\_manage\_direct\_messages

Boolean

Optional

Pass *True* if the administrator can manage direct messages within the channel and decline suggested posts; for channels only

#### [](#setchatadministratorcustomtitle)setChatAdministratorCustomTitle

Use this method to set a custom title for an administrator in a supergroup promoted by the bot. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)

user\_id

Integer

Yes

Unique identifier of the target user

custom\_title

String

Yes

New custom title for the administrator; 0-16 characters, emoji are not allowed

#### [](#banchatsenderchat)banChatSenderChat

Use this method to ban a channel chat in a supergroup or a channel. Until the chat is [unbanned](#unbanchatsenderchat), the owner of the banned chat won't be able to send messages on behalf of **any of their channels**. The bot must be an administrator in the supergroup or channel for this to work and must have the appropriate administrator rights. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

sender\_chat\_id

Integer

Yes

Unique identifier of the target sender chat

#### [](#unbanchatsenderchat)unbanChatSenderChat

Use this method to unban a previously banned channel chat in a supergroup or channel. The bot must be an administrator for this to work and must have the appropriate administrator rights. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

sender\_chat\_id

Integer

Yes

Unique identifier of the target sender chat

#### [](#setchatpermissions)setChatPermissions

Use this method to set default chat permissions for all members. The bot must be an administrator in the group or a supergroup for this to work and must have the *can\_restrict\_members* administrator rights. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)

permissions

[ChatPermissions](#chatpermissions)

Yes

A JSON-serialized object for new default chat permissions

use\_independent\_chat\_permissions

Boolean

Optional

Pass *True* if chat permissions are set independently. Otherwise, the *can\_send\_other\_messages* and *can\_add\_web\_page\_previews* permissions will imply the *can\_send\_messages*, *can\_send\_audios*, *can\_send\_documents*, *can\_send\_photos*, *can\_send\_videos*, *can\_send\_video\_notes*, and *can\_send\_voice\_notes* permissions; the *can\_send\_polls* permission will imply the *can\_send\_messages* permission.

#### [](#exportchatinvitelink)exportChatInviteLink

Use this method to generate a new primary invite link for a chat; any previously generated primary link is revoked. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Returns the new invite link as *String* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

> Note: Each administrator in a chat generates their own invite links. Bots can't use invite links generated by other administrators. If you want your bot to work with invite links, it will need to generate its own link using [exportChatInviteLink](#exportchatinvitelink) or by calling the [getChat](#getchat) method. If your bot needs to generate a new primary invite link replacing its previous one, use [exportChatInviteLink](#exportchatinvitelink) again.

#### [](#createchatinvitelink)createChatInviteLink

Use this method to create an additional invite link for a chat. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. The link can be revoked using the method [revokeChatInviteLink](#revokechatinvitelink). Returns the new invite link as [ChatInviteLink](#chatinvitelink) object.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

name

String

Optional

Invite link name; 0-32 characters

expire\_date

Integer

Optional

Point in time (Unix timestamp) when the link will expire

member\_limit

Integer

Optional

The maximum number of users that can be members of the chat simultaneously after joining the chat via this invite link; 1-99999

creates\_join\_request

Boolean

Optional

*True*, if users joining the chat via the link need to be approved by chat administrators. If *True*, *member\_limit* can't be specified

#### [](#editchatinvitelink)editChatInviteLink

Use this method to edit a non-primary invite link created by the bot. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Returns the edited invite link as a [ChatInviteLink](#chatinvitelink) object.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

invite\_link

String

Yes

The invite link to edit

name

String

Optional

Invite link name; 0-32 characters

expire\_date

Integer

Optional

Point in time (Unix timestamp) when the link will expire

member\_limit

Integer

Optional

The maximum number of users that can be members of the chat simultaneously after joining the chat via this invite link; 1-99999

creates\_join\_request

Boolean

Optional

*True*, if users joining the chat via the link need to be approved by chat administrators. If *True*, *member\_limit* can't be specified

#### [](#createchatsubscriptioninvitelink)createChatSubscriptionInviteLink

Use this method to create a [subscription invite link](https://telegram.org/blog/superchannels-star-reactions-subscriptions#star-subscriptions) for a channel chat. The bot must have the *can\_invite\_users* administrator rights. The link can be edited using the method [editChatSubscriptionInviteLink](#editchatsubscriptioninvitelink) or revoked using the method [revokeChatInviteLink](#revokechatinvitelink). Returns the new invite link as a [ChatInviteLink](#chatinvitelink) object.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target channel chat or username of the target channel (in the format `@channelusername`)

name

String

Optional

Invite link name; 0-32 characters

subscription\_period

Integer

Yes

The number of seconds the subscription will be active for before the next payment. Currently, it must always be 2592000 (30 days).

subscription\_price

Integer

Yes

The amount of Telegram Stars a user must pay initially and after each subsequent subscription period to be a member of the chat; 1-10000

#### [](#editchatsubscriptioninvitelink)editChatSubscriptionInviteLink

Use this method to edit a subscription invite link created by the bot. The bot must have the *can\_invite\_users* administrator rights. Returns the edited invite link as a [ChatInviteLink](#chatinvitelink) object.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

invite\_link

String

Yes

The invite link to edit

name

String

Optional

Invite link name; 0-32 characters

#### [](#revokechatinvitelink)revokeChatInviteLink

Use this method to revoke an invite link created by the bot. If the primary link is revoked, a new link is automatically generated. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Returns the revoked invite link as [ChatInviteLink](#chatinvitelink) object.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier of the target chat or username of the target channel (in the format `@channelusername`)

invite\_link

String

Yes

The invite link to revoke

#### [](#approvechatjoinrequest)approveChatJoinRequest

Use this method to approve a chat join request. The bot must be an administrator in the chat for this to work and must have the *can\_invite\_users* administrator right. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

user\_id

Integer

Yes

Unique identifier of the target user

#### [](#declinechatjoinrequest)declineChatJoinRequest

Use this method to decline a chat join request. The bot must be an administrator in the chat for this to work and must have the *can\_invite\_users* administrator right. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

user\_id

Integer

Yes

Unique identifier of the target user

#### [](#setchatphoto)setChatPhoto

Use this method to set a new profile photo for the chat. Photos can't be changed for private chats. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

photo

[InputFile](#inputfile)

Yes

New chat photo, uploaded using multipart/form-data

#### [](#deletechatphoto)deleteChatPhoto

Use this method to delete a chat photo. Photos can't be changed for private chats. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

#### [](#setchattitle)setChatTitle

Use this method to change the title of a chat. Titles can't be changed for private chats. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

title

String

Yes

New chat title, 1-128 characters

#### [](#setchatdescription)setChatDescription

Use this method to change the description of a group, a supergroup or a channel. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

description

String

Optional

New chat description, 0-255 characters

#### [](#pinchatmessage)pinChatMessage

Use this method to add a message to the list of pinned messages in a chat. In private chats and channel direct messages chats, all non-service messages can be pinned. Conversely, the bot must be an administrator with the 'can\_pin\_messages' right or the 'can\_edit\_messages' right to pin messages in groups and channels respectively. Returns *True* on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Optional

Unique identifier of the business connection on behalf of which the message will be pinned

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

message\_id

Integer

Yes

Identifier of a message to pin

disable\_notification

Boolean

Optional

Pass *True* if it is not necessary to send a notification to all chat members about the new pinned message. Notifications are always disabled in channels and private chats.

#### [](#unpinchatmessage)unpinChatMessage

Use this method to remove a message from the list of pinned messages in a chat. In private chats and channel direct messages chats, all messages can be unpinned. Conversely, the bot must be an administrator with the 'can\_pin\_messages' right or the 'can\_edit\_messages' right to unpin messages in groups and channels respectively. Returns *True* on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Optional

Unique identifier of the business connection on behalf of which the message will be unpinned

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

message\_id

Integer

Optional

Identifier of the message to unpin. Required if *business\_connection\_id* is specified. If not specified, the most recent pinned message (by sending date) will be unpinned.

#### [](#unpinallchatmessages)unpinAllChatMessages

Use this method to clear the list of pinned messages in a chat. In private chats and channel direct messages chats, no additional rights are required to unpin all pinned messages. Conversely, the bot must be an administrator with the 'can\_pin\_messages' right or the 'can\_edit\_messages' right to unpin all pinned messages in groups and channels respectively. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

#### [](#leavechat)leaveChat

Use this method for your bot to leave a group, supergroup or channel. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`). Channel direct messages chats aren't supported; leave the corresponding channel instead.

#### [](#getchat)getChat

Use this method to get up-to-date information about the chat. Returns a [ChatFullInfo](#chatfullinfo) object on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`)

#### [](#getchatadministrators)getChatAdministrators

Use this method to get a list of administrators in a chat, which aren't bots. Returns an Array of [ChatMember](#chatmember) objects.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`)

#### [](#getchatmembercount)getChatMemberCount

Use this method to get the number of members in a chat. Returns *Int* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`)

#### [](#getchatmember)getChatMember

Use this method to get information about a member of a chat. The method is only guaranteed to work for other users if the bot is an administrator in the chat. Returns a [ChatMember](#chatmember) object on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup or channel (in the format `@channelusername`)

user\_id

Integer

Yes

Unique identifier of the target user

#### [](#setchatstickerset)setChatStickerSet

Use this method to set a new group sticker set for a supergroup. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Use the field *can\_set\_sticker\_set* optionally returned in [getChat](#getchat) requests to check if the bot can use this method. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)

sticker\_set\_name

String

Yes

Name of the sticker set to be set as the group sticker set

#### [](#deletechatstickerset)deleteChatStickerSet

Use this method to delete a group sticker set from a supergroup. The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights. Use the field *can\_set\_sticker\_set* optionally returned in [getChat](#getchat) requests to check if the bot can use this method. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)

#### [](#getforumtopiciconstickers)getForumTopicIconStickers

Use this method to get custom emoji stickers, which can be used as a forum topic icon by any user. Requires no parameters. Returns an Array of [Sticker](#sticker) objects.

#### [](#createforumtopic)createForumTopic

Use this method to create a topic in a forum supergroup chat. The bot must be an administrator in the chat for this to work and must have the *can\_manage\_topics* administrator rights. Returns information about the created topic as a [ForumTopic](#forumtopic) object.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)

name

String

Yes

Topic name, 1-128 characters

icon\_color

Integer

Optional

Color of the topic icon in RGB format. Currently, must be one of 7322096 (0x6FB9F0), 16766590 (0xFFD67E), 13338331 (0xCB86DB), 9367192 (0x8EEE98), 16749490 (0xFF93B2), or 16478047 (0xFB6F5F)

icon\_custom\_emoji\_id

String

Optional

Unique identifier of the custom emoji shown as the topic icon. Use [getForumTopicIconStickers](#getforumtopiciconstickers) to get all allowed custom emoji identifiers.

#### [](#editforumtopic)editForumTopic

Use this method to edit name and icon of a topic in a forum supergroup chat or a private chat with a user. In the case of a supergroup chat the bot must be an administrator in the chat for this to work and must have the *can\_manage\_topics* administrator rights, unless it is the creator of the topic. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)

message\_thread\_id

Integer

Yes

Unique identifier for the target message thread of the forum topic

name

String

Optional

New topic name, 0-128 characters. If not specified or empty, the current name of the topic will be kept

icon\_custom\_emoji\_id

String

Optional

New unique identifier of the custom emoji shown as the topic icon. Use [getForumTopicIconStickers](#getforumtopiciconstickers) to get all allowed custom emoji identifiers. Pass an empty string to remove the icon. If not specified, the current icon will be kept

#### [](#closeforumtopic)closeForumTopic

Use this method to close an open topic in a forum supergroup chat. The bot must be an administrator in the chat for this to work and must have the *can\_manage\_topics* administrator rights, unless it is the creator of the topic. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)

message\_thread\_id

Integer

Yes

Unique identifier for the target message thread of the forum topic

#### [](#reopenforumtopic)reopenForumTopic

Use this method to reopen a closed topic in a forum supergroup chat. The bot must be an administrator in the chat for this to work and must have the *can\_manage\_topics* administrator rights, unless it is the creator of the topic. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)

message\_thread\_id

Integer

Yes

Unique identifier for the target message thread of the forum topic

#### [](#deleteforumtopic)deleteForumTopic

Use this method to delete a forum topic along with all its messages in a forum supergroup chat or a private chat with a user. In the case of a supergroup chat the bot must be an administrator in the chat for this to work and must have the *can\_delete\_messages* administrator rights. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)

message\_thread\_id

Integer

Yes

Unique identifier for the target message thread of the forum topic

#### [](#unpinallforumtopicmessages)unpinAllForumTopicMessages

Use this method to clear the list of pinned messages in a forum topic in a forum supergroup chat or a private chat with a user. In the case of a supergroup chat the bot must be an administrator in the chat for this to work and must have the *can\_pin\_messages* administrator right in the supergroup. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)

message\_thread\_id

Integer

Yes

Unique identifier for the target message thread of the forum topic

#### [](#editgeneralforumtopic)editGeneralForumTopic

Use this method to edit the name of the 'General' topic in a forum supergroup chat. The bot must be an administrator in the chat for this to work and must have the *can\_manage\_topics* administrator rights. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)

name

String

Yes

New topic name, 1-128 characters

#### [](#closegeneralforumtopic)closeGeneralForumTopic

Use this method to close an open 'General' topic in a forum supergroup chat. The bot must be an administrator in the chat for this to work and must have the *can\_manage\_topics* administrator rights. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)

#### [](#reopengeneralforumtopic)reopenGeneralForumTopic

Use this method to reopen a closed 'General' topic in a forum supergroup chat. The bot must be an administrator in the chat for this to work and must have the *can\_manage\_topics* administrator rights. The topic will be automatically unhidden if it was hidden. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)

#### [](#hidegeneralforumtopic)hideGeneralForumTopic

Use this method to hide the 'General' topic in a forum supergroup chat. The bot must be an administrator in the chat for this to work and must have the *can\_manage\_topics* administrator rights. The topic will be automatically closed if it was open. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)

#### [](#unhidegeneralforumtopic)unhideGeneralForumTopic

Use this method to unhide the 'General' topic in a forum supergroup chat. The bot must be an administrator in the chat for this to work and must have the *can\_manage\_topics* administrator rights. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)

#### [](#unpinallgeneralforumtopicmessages)unpinAllGeneralForumTopicMessages

Use this method to clear the list of pinned messages in a General forum topic. The bot must be an administrator in the chat for this to work and must have the *can\_pin\_messages* administrator right in the supergroup. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target supergroup (in the format `@supergroupusername`)

#### [](#answercallbackquery)answerCallbackQuery

Use this method to send answers to callback queries sent from [inline keyboards](/bots/features#inline-keyboards). The answer will be displayed to the user as a notification at the top of the chat screen or as an alert. On success, *True* is returned.

> Alternatively, the user can be redirected to the specified Game URL. For this option to work, you must first create a game for your bot via [@BotFather](https://t.me/botfather) and accept the terms. Otherwise, you may use links like `t.me/your_bot?start=XXXX` that open your bot with a parameter.

Parameter

Type

Required

Description

callback\_query\_id

String

Yes

Unique identifier for the query to be answered

text

String

Optional

Text of the notification. If not specified, nothing will be shown to the user, 0-200 characters

show\_alert

Boolean

Optional

If *True*, an alert will be shown by the client instead of a notification at the top of the chat screen. Defaults to *false*.

url

String

Optional

URL that will be opened by the user's client. If you have created a [Game](#game) and accepted the conditions via [@BotFather](https://t.me/botfather), specify the URL that opens your game - note that this will only work if the query comes from a [*callback\_game*](#inlinekeyboardbutton) button.  
  
Otherwise, you may use links like `t.me/your_bot?start=XXXX` that open your bot with a parameter.

cache\_time

Integer

Optional

The maximum amount of time in seconds that the result of the callback query may be cached client-side. Telegram apps will support caching starting in version 3.14. Defaults to 0.

#### [](#getuserchatboosts)getUserChatBoosts

Use this method to get the list of boosts added to a chat by a user. Requires administrator rights in the chat. Returns a [UserChatBoosts](#userchatboosts) object.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the chat or username of the channel (in the format `@channelusername`)

user\_id

Integer

Yes

Unique identifier of the target user

#### [](#getbusinessconnection)getBusinessConnection

Use this method to get information about the connection of the bot with a business account. Returns a [BusinessConnection](#businessconnection) object on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Yes

Unique identifier of the business connection

#### [](#setmycommands)setMyCommands

Use this method to change the list of the bot's commands. See [this manual](/bots/features#commands) for more details about bot commands. Returns *True* on success.

Parameter

Type

Required

Description

commands

Array of [BotCommand](#botcommand)

Yes

A JSON-serialized list of bot commands to be set as the list of the bot's commands. At most 100 commands can be specified.

scope

[BotCommandScope](#botcommandscope)

Optional

A JSON-serialized object, describing scope of users for which the commands are relevant. Defaults to [BotCommandScopeDefault](#botcommandscopedefault).

language\_code

String

Optional

A two-letter ISO 639-1 language code. If empty, commands will be applied to all users from the given scope, for whose language there are no dedicated commands

#### [](#deletemycommands)deleteMyCommands

Use this method to delete the list of the bot's commands for the given scope and user language. After deletion, [higher level commands](#determining-list-of-commands) will be shown to affected users. Returns *True* on success.

Parameter

Type

Required

Description

scope

[BotCommandScope](#botcommandscope)

Optional

A JSON-serialized object, describing scope of users for which the commands are relevant. Defaults to [BotCommandScopeDefault](#botcommandscopedefault).

language\_code

String

Optional

A two-letter ISO 639-1 language code. If empty, commands will be applied to all users from the given scope, for whose language there are no dedicated commands

#### [](#getmycommands)getMyCommands

Use this method to get the current list of the bot's commands for the given scope and user language. Returns an Array of [BotCommand](#botcommand) objects. If commands aren't set, an empty list is returned.

Parameter

Type

Required

Description

scope

[BotCommandScope](#botcommandscope)

Optional

A JSON-serialized object, describing scope of users. Defaults to [BotCommandScopeDefault](#botcommandscopedefault).

language\_code

String

Optional

A two-letter ISO 639-1 language code or an empty string

#### [](#setmyname)setMyName

Use this method to change the bot's name. Returns *True* on success.

Parameter

Type

Required

Description

name

String

Optional

New bot name; 0-64 characters. Pass an empty string to remove the dedicated name for the given language.

language\_code

String

Optional

A two-letter ISO 639-1 language code. If empty, the name will be shown to all users for whose language there is no dedicated name.

#### [](#getmyname)getMyName

Use this method to get the current bot name for the given user language. Returns [BotName](#botname) on success.

Parameter

Type

Required

Description

language\_code

String

Optional

A two-letter ISO 639-1 language code or an empty string

#### [](#setmydescription)setMyDescription

Use this method to change the bot's description, which is shown in the chat with the bot if the chat is empty. Returns *True* on success.

Parameter

Type

Required

Description

description

String

Optional

New bot description; 0-512 characters. Pass an empty string to remove the dedicated description for the given language.

language\_code

String

Optional

A two-letter ISO 639-1 language code. If empty, the description will be applied to all users for whose language there is no dedicated description.

#### [](#getmydescription)getMyDescription

Use this method to get the current bot description for the given user language. Returns [BotDescription](#botdescription) on success.

Parameter

Type

Required

Description

language\_code

String

Optional

A two-letter ISO 639-1 language code or an empty string

#### [](#setmyshortdescription)setMyShortDescription

Use this method to change the bot's short description, which is shown on the bot's profile page and is sent together with the link when users share the bot. Returns *True* on success.

Parameter

Type

Required

Description

short\_description

String

Optional

New short description for the bot; 0-120 characters. Pass an empty string to remove the dedicated short description for the given language.

language\_code

String

Optional

A two-letter ISO 639-1 language code. If empty, the short description will be applied to all users for whose language there is no dedicated short description.

#### [](#getmyshortdescription)getMyShortDescription

Use this method to get the current bot short description for the given user language. Returns [BotShortDescription](#botshortdescription) on success.

Parameter

Type

Required

Description

language\_code

String

Optional

A two-letter ISO 639-1 language code or an empty string

#### [](#setchatmenubutton)setChatMenuButton

Use this method to change the bot's menu button in a private chat, or the default menu button. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer

Optional

Unique identifier for the target private chat. If not specified, default bot's menu button will be changed

menu\_button

[MenuButton](#menubutton)

Optional

A JSON-serialized object for the bot's new menu button. Defaults to [MenuButtonDefault](#menubuttondefault)

#### [](#getchatmenubutton)getChatMenuButton

Use this method to get the current value of the bot's menu button in a private chat, or the default menu button. Returns [MenuButton](#menubutton) on success.

Parameter

Type

Required

Description

chat\_id

Integer

Optional

Unique identifier for the target private chat. If not specified, default bot's menu button will be returned

#### [](#setmydefaultadministratorrights)setMyDefaultAdministratorRights

Use this method to change the default administrator rights requested by the bot when it's added as an administrator to groups or channels. These rights will be suggested to users, but they are free to modify the list before adding the bot. Returns *True* on success.

Parameter

Type

Required

Description

rights

[ChatAdministratorRights](#chatadministratorrights)

Optional

A JSON-serialized object describing new default administrator rights. If not specified, the default administrator rights will be cleared.

for\_channels

Boolean

Optional

Pass *True* to change the default administrator rights of the bot in channels. Otherwise, the default administrator rights of the bot for groups and supergroups will be changed.

#### [](#getmydefaultadministratorrights)getMyDefaultAdministratorRights

Use this method to get the current default administrator rights of the bot. Returns [ChatAdministratorRights](#chatadministratorrights) on success.

Parameter

Type

Required

Description

for\_channels

Boolean

Optional

Pass *True* to get default administrator rights of the bot in channels. Otherwise, default administrator rights of the bot for groups and supergroups will be returned.

#### [](#getavailablegifts)getAvailableGifts

Returns the list of gifts that can be sent by the bot to users and channel chats. Requires no parameters. Returns a [Gifts](#gifts) object.

#### [](#sendgift)sendGift

Sends a gift to the given user or channel chat. The gift can't be converted to Telegram Stars by the receiver. Returns *True* on success.

Parameter

Type

Required

Description

user\_id

Integer

Optional

Required if *chat\_id* is not specified. Unique identifier of the target user who will receive the gift.

chat\_id

Integer or String

Optional

Required if *user\_id* is not specified. Unique identifier for the chat or username of the channel (in the format `@channelusername`) that will receive the gift.

gift\_id

String

Yes

Identifier of the gift; limited gifts can't be sent to channel chats

pay\_for\_upgrade

Boolean

Optional

Pass *True* to pay for the gift upgrade from the bot's balance, thereby making the upgrade free for the receiver

text

String

Optional

Text that will be shown along with the gift; 0-128 characters

text\_parse\_mode

String

Optional

Mode for parsing entities in the text. See [formatting options](#formatting-options) for more details. Entities other than “bold”, “italic”, “underline”, “strikethrough”, “spoiler”, and “custom\_emoji” are ignored.

text\_entities

Array of [MessageEntity](#messageentity)

Optional

A JSON-serialized list of special entities that appear in the gift text. It can be specified instead of *text\_parse\_mode*. Entities other than “bold”, “italic”, “underline”, “strikethrough”, “spoiler”, and “custom\_emoji” are ignored.

#### [](#giftpremiumsubscription)giftPremiumSubscription

Gifts a Telegram Premium subscription to the given user. Returns *True* on success.

Parameter

Type

Required

Description

user\_id

Integer

Yes

Unique identifier of the target user who will receive a Telegram Premium subscription

month\_count

Integer

Yes

Number of months the Telegram Premium subscription will be active for the user; must be one of 3, 6, or 12

star\_count

Integer

Yes

Number of Telegram Stars to pay for the Telegram Premium subscription; must be 1000 for 3 months, 1500 for 6 months, and 2500 for 12 months

text

String

Optional

Text that will be shown along with the service message about the subscription; 0-128 characters

text\_parse\_mode

String

Optional

Mode for parsing entities in the text. See [formatting options](#formatting-options) for more details. Entities other than “bold”, “italic”, “underline”, “strikethrough”, “spoiler”, and “custom\_emoji” are ignored.

text\_entities

Array of [MessageEntity](#messageentity)

Optional

A JSON-serialized list of special entities that appear in the gift text. It can be specified instead of *text\_parse\_mode*. Entities other than “bold”, “italic”, “underline”, “strikethrough”, “spoiler”, and “custom\_emoji” are ignored.

#### [](#verifyuser)verifyUser

Verifies a user [on behalf of the organization](https://telegram.org/verify#third-party-verification) which is represented by the bot. Returns *True* on success.

Parameter

Type

Required

Description

user\_id

Integer

Yes

Unique identifier of the target user

custom\_description

String

Optional

Custom description for the verification; 0-70 characters. Must be empty if the organization isn't allowed to provide a custom verification description.

#### [](#verifychat)verifyChat

Verifies a chat [on behalf of the organization](https://telegram.org/verify#third-party-verification) which is represented by the bot. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`). Channel direct messages chats can't be verified.

custom\_description

String

Optional

Custom description for the verification; 0-70 characters. Must be empty if the organization isn't allowed to provide a custom verification description.

#### [](#removeuserverification)removeUserVerification

Removes verification from a user who is currently verified [on behalf of the organization](https://telegram.org/verify#third-party-verification) represented by the bot. Returns *True* on success.

Parameter

Type

Required

Description

user\_id

Integer

Yes

Unique identifier of the target user

#### [](#removechatverification)removeChatVerification

Removes verification from a chat that is currently verified [on behalf of the organization](https://telegram.org/verify#third-party-verification) represented by the bot. Returns *True* on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

#### [](#readbusinessmessage)readBusinessMessage

Marks incoming message as read on behalf of a business account. Requires the *can\_read\_messages* business bot right. Returns *True* on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Yes

Unique identifier of the business connection on behalf of which to read the message

chat\_id

Integer

Yes

Unique identifier of the chat in which the message was received. The chat must have been active in the last 24 hours.

message\_id

Integer

Yes

Unique identifier of the message to mark as read

#### [](#deletebusinessmessages)deleteBusinessMessages

Delete messages on behalf of a business account. Requires the *can\_delete\_sent\_messages* business bot right to delete messages sent by the bot itself, or the *can\_delete\_all\_messages* business bot right to delete any message. Returns *True* on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Yes

Unique identifier of the business connection on behalf of which to delete the messages

message\_ids

Array of Integer

Yes

A JSON-serialized list of 1-100 identifiers of messages to delete. All messages must be from the same chat. See [deleteMessage](#deletemessage) for limitations on which messages can be deleted

#### [](#setbusinessaccountname)setBusinessAccountName

Changes the first and last name of a managed business account. Requires the *can\_change\_name* business bot right. Returns *True* on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Yes

Unique identifier of the business connection

first\_name

String

Yes

The new value of the first name for the business account; 1-64 characters

last\_name

String

Optional

The new value of the last name for the business account; 0-64 characters

#### [](#setbusinessaccountusername)setBusinessAccountUsername

Changes the username of a managed business account. Requires the *can\_change\_username* business bot right. Returns *True* on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Yes

Unique identifier of the business connection

username

String

Optional

The new value of the username for the business account; 0-32 characters

#### [](#setbusinessaccountbio)setBusinessAccountBio

Changes the bio of a managed business account. Requires the *can\_change\_bio* business bot right. Returns *True* on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Yes

Unique identifier of the business connection

bio

String

Optional

The new value of the bio for the business account; 0-140 characters

#### [](#setbusinessaccountprofilephoto)setBusinessAccountProfilePhoto

Changes the profile photo of a managed business account. Requires the *can\_edit\_profile\_photo* business bot right. Returns *True* on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Yes

Unique identifier of the business connection

photo

[InputProfilePhoto](#inputprofilephoto)

Yes

The new profile photo to set

is\_public

Boolean

Optional

Pass *True* to set the public photo, which will be visible even if the main photo is hidden by the business account's privacy settings. An account can have only one public photo.

#### [](#removebusinessaccountprofilephoto)removeBusinessAccountProfilePhoto

Removes the current profile photo of a managed business account. Requires the *can\_edit\_profile\_photo* business bot right. Returns *True* on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Yes

Unique identifier of the business connection

is\_public

Boolean

Optional

Pass *True* to remove the public photo, which is visible even if the main photo is hidden by the business account's privacy settings. After the main photo is removed, the previous profile photo (if present) becomes the main photo.

#### [](#setbusinessaccountgiftsettings)setBusinessAccountGiftSettings

Changes the privacy settings pertaining to incoming gifts in a managed business account. Requires the *can\_change\_gift\_settings* business bot right. Returns *True* on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Yes

Unique identifier of the business connection

show\_gift\_button

Boolean

Yes

Pass *True*, if a button for sending a gift to the user or by the business account must always be shown in the input field

accepted\_gift\_types

[AcceptedGiftTypes](#acceptedgifttypes)

Yes

Types of gifts accepted by the business account

#### [](#getbusinessaccountstarbalance)getBusinessAccountStarBalance

Returns the amount of Telegram Stars owned by a managed business account. Requires the *can\_view\_gifts\_and\_stars* business bot right. Returns [StarAmount](#staramount) on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Yes

Unique identifier of the business connection

#### [](#transferbusinessaccountstars)transferBusinessAccountStars

Transfers Telegram Stars from the business account balance to the bot's balance. Requires the *can\_transfer\_stars* business bot right. Returns *True* on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Yes

Unique identifier of the business connection

star\_count

Integer

Yes

Number of Telegram Stars to transfer; 1-10000

#### [](#getbusinessaccountgifts)getBusinessAccountGifts

Returns the gifts received and owned by a managed business account. Requires the *can\_view\_gifts\_and\_stars* business bot right. Returns [OwnedGifts](#ownedgifts) on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Yes

Unique identifier of the business connection

exclude\_unsaved

Boolean

Optional

Pass *True* to exclude gifts that aren't saved to the account's profile page

exclude\_saved

Boolean

Optional

Pass *True* to exclude gifts that are saved to the account's profile page

exclude\_unlimited

Boolean

Optional

Pass *True* to exclude gifts that can be purchased an unlimited number of times

exclude\_limited\_upgradable

Boolean

Optional

Pass *True* to exclude gifts that can be purchased a limited number of times and can be upgraded to unique

exclude\_limited\_non\_upgradable

Boolean

Optional

Pass *True* to exclude gifts that can be purchased a limited number of times and can't be upgraded to unique

exclude\_unique

Boolean

Optional

Pass *True* to exclude unique gifts

exclude\_from\_blockchain

Boolean

Optional

Pass *True* to exclude gifts that were assigned from the TON blockchain and can't be resold or transferred in Telegram

sort\_by\_price

Boolean

Optional

Pass *True* to sort results by gift price instead of send date. Sorting is applied before pagination.

offset

String

Optional

Offset of the first entry to return as received from the previous request; use empty string to get the first chunk of results

limit

Integer

Optional

The maximum number of gifts to be returned; 1-100. Defaults to 100

#### [](#getusergifts)getUserGifts

Returns the gifts owned and hosted by a user. Returns [OwnedGifts](#ownedgifts) on success.

Parameter

Type

Required

Description

user\_id

Integer

Yes

Unique identifier of the user

exclude\_unlimited

Boolean

Optional

Pass *True* to exclude gifts that can be purchased an unlimited number of times

exclude\_limited\_upgradable

Boolean

Optional

Pass *True* to exclude gifts that can be purchased a limited number of times and can be upgraded to unique

exclude\_limited\_non\_upgradable

Boolean

Optional

Pass *True* to exclude gifts that can be purchased a limited number of times and can't be upgraded to unique

exclude\_from\_blockchain

Boolean

Optional

Pass *True* to exclude gifts that were assigned from the TON blockchain and can't be resold or transferred in Telegram

exclude\_unique

Boolean

Optional

Pass *True* to exclude unique gifts

sort\_by\_price

Boolean

Optional

Pass *True* to sort results by gift price instead of send date. Sorting is applied before pagination.

offset

String

Optional

Offset of the first entry to return as received from the previous request; use an empty string to get the first chunk of results

limit

Integer

Optional

The maximum number of gifts to be returned; 1-100. Defaults to 100

#### [](#getchatgifts)getChatGifts

Returns the gifts owned by a chat. Returns [OwnedGifts](#ownedgifts) on success.

Parameter

Type

Required

Description

chat\_id

Integer or String

Yes

Unique identifier for the target chat or username of the target channel (in the format `@channelusername`)

exclude\_unsaved

Boolean

Optional

Pass *True* to exclude gifts that aren't saved to the chat's profile page. Always *True*, unless the bot has the *can\_post\_messages* administrator right in the channel.

exclude\_saved

Boolean

Optional

Pass *True* to exclude gifts that are saved to the chat's profile page. Always *False*, unless the bot has the *can\_post\_messages* administrator right in the channel.

exclude\_unlimited

Boolean

Optional

Pass *True* to exclude gifts that can be purchased an unlimited number of times

exclude\_limited\_upgradable

Boolean

Optional

Pass *True* to exclude gifts that can be purchased a limited number of times and can be upgraded to unique

exclude\_limited\_non\_upgradable

Boolean

Optional

Pass *True* to exclude gifts that can be purchased a limited number of times and can't be upgraded to unique

exclude\_from\_blockchain

Boolean

Optional

Pass *True* to exclude gifts that were assigned from the TON blockchain and can't be resold or transferred in Telegram

exclude\_unique

Boolean

Optional

Pass *True* to exclude unique gifts

sort\_by\_price

Boolean

Optional

Pass *True* to sort results by gift price instead of send date. Sorting is applied before pagination.

offset

String

Optional

Offset of the first entry to return as received from the previous request; use an empty string to get the first chunk of results

limit

Integer

Optional

The maximum number of gifts to be returned; 1-100. Defaults to 100

#### [](#convertgifttostars)convertGiftToStars

Converts a given regular gift to Telegram Stars. Requires the *can\_convert\_gifts\_to\_stars* business bot right. Returns *True* on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Yes

Unique identifier of the business connection

owned\_gift\_id

String

Yes

Unique identifier of the regular gift that should be converted to Telegram Stars

#### [](#upgradegift)upgradeGift

Upgrades a given regular gift to a unique gift. Requires the *can\_transfer\_and\_upgrade\_gifts* business bot right. Additionally requires the *can\_transfer\_stars* business bot right if the upgrade is paid. Returns *True* on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Yes

Unique identifier of the business connection

owned\_gift\_id

String

Yes

Unique identifier of the regular gift that should be upgraded to a unique one

keep\_original\_details

Boolean

Optional

Pass *True* to keep the original gift text, sender and receiver in the upgraded gift

star\_count

Integer

Optional

The amount of Telegram Stars that will be paid for the upgrade from the business account balance. If `gift.prepaid_upgrade_star_count > 0`, then pass 0, otherwise, the *can\_transfer\_stars* business bot right is required and `gift.upgrade_star_count` must be passed.

#### [](#transfergift)transferGift

Transfers an owned unique gift to another user. Requires the *can\_transfer\_and\_upgrade\_gifts* business bot right. Requires *can\_transfer\_stars* business bot right if the transfer is paid. Returns *True* on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Yes

Unique identifier of the business connection

owned\_gift\_id

String

Yes

Unique identifier of the regular gift that should be transferred

new\_owner\_chat\_id

Integer

Yes

Unique identifier of the chat which will own the gift. The chat must be active in the last 24 hours.

star\_count

Integer

Optional

The amount of Telegram Stars that will be paid for the transfer from the business account balance. If positive, then the *can\_transfer\_stars* business bot right is required.

#### [](#poststory)postStory

Posts a story on behalf of a managed business account. Requires the *can\_manage\_stories* business bot right. Returns [Story](#story) on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Yes

Unique identifier of the business connection

content

[InputStoryContent](#inputstorycontent)

Yes

Content of the story

active\_period

Integer

Yes

Period after which the story is moved to the archive, in seconds; must be one of `6 * 3600`, `12 * 3600`, `86400`, or `2 * 86400`

caption

String

Optional

Caption of the story, 0-2048 characters after entities parsing

parse\_mode

String

Optional

Mode for parsing entities in the story caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

Optional

A JSON-serialized list of special entities that appear in the caption, which can be specified instead of *parse\_mode*

areas

Array of [StoryArea](#storyarea)

Optional

A JSON-serialized list of clickable areas to be shown on the story

post\_to\_chat\_page

Boolean

Optional

Pass *True* to keep the story accessible after it expires

protect\_content

Boolean

Optional

Pass *True* if the content of the story must be protected from forwarding and screenshotting

#### [](#repoststory)repostStory

Reposts a story on behalf of a business account from another business account. Both business accounts must be managed by the same bot, and the story on the source account must have been posted (or reposted) by the bot. Requires the *can\_manage\_stories* business bot right for both business accounts. Returns [Story](#story) on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Yes

Unique identifier of the business connection

from\_chat\_id

Integer

Yes

Unique identifier of the chat which posted the story that should be reposted

from\_story\_id

Integer

Yes

Unique identifier of the story that should be reposted

active\_period

Integer

Yes

Period after which the story is moved to the archive, in seconds; must be one of `6 * 3600`, `12 * 3600`, `86400`, or `2 * 86400`

post\_to\_chat\_page

Boolean

Optional

Pass *True* to keep the story accessible after it expires

protect\_content

Boolean

Optional

Pass *True* if the content of the story must be protected from forwarding and screenshotting

#### [](#editstory)editStory

Edits a story previously posted by the bot on behalf of a managed business account. Requires the *can\_manage\_stories* business bot right. Returns [Story](#story) on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Yes

Unique identifier of the business connection

story\_id

Integer

Yes

Unique identifier of the story to edit

content

[InputStoryContent](#inputstorycontent)

Yes

Content of the story

caption

String

Optional

Caption of the story, 0-2048 characters after entities parsing

parse\_mode

String

Optional

Mode for parsing entities in the story caption. See [formatting options](#formatting-options) for more details.

caption\_entities

Array of [MessageEntity](#messageentity)

Optional

A JSON-serialized list of special entities that appear in the caption, which can be specified instead of *parse\_mode*

areas

Array of [StoryArea](#storyarea)

Optional

A JSON-serialized list of clickable areas to be shown on the story

#### [](#deletestory)deleteStory

Deletes a story previously posted by the bot on behalf of a managed business account. Requires the *can\_manage\_stories* business bot right. Returns *True* on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Yes

Unique identifier of the business connection

story\_id

Integer

Yes

Unique identifier of the story to delete

#### [](#inline-mode-methods)Inline mode methods

Methods and objects used in the inline mode are described in the [Inline mode section](#inline-mode).

