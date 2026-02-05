### [](#getting-updates)Getting updates

There are two mutually exclusive ways of receiving updates for your bot - the [getUpdates](#getupdates) method on one hand and [webhooks](#setwebhook) on the other. Incoming updates are stored on the server until the bot receives them either way, but they will not be kept longer than 24 hours.

Regardless of which option you choose, you will receive JSON-serialized [Update](#update) objects as a result.

#### [](#update)Update

This [object](#available-types) represents an incoming update.  
At most **one** of the optional parameters can be present in any given update.

Field

Type

Description

update\_id

Integer

The update's unique identifier. Update identifiers start from a certain positive number and increase sequentially. This identifier becomes especially handy if you're using [webhooks](#setwebhook), since it allows you to ignore repeated updates or to restore the correct update sequence, should they get out of order. If there are no new updates for at least a week, then identifier of the next update will be chosen randomly instead of sequentially.

message

[Message](#message)

*Optional*. New incoming message of any kind - text, photo, sticker, etc.

edited\_message

[Message](#message)

*Optional*. New version of a message that is known to the bot and was edited. This update may at times be triggered by changes to message fields that are either unavailable or not actively used by your bot.

channel\_post

[Message](#message)

*Optional*. New incoming channel post of any kind - text, photo, sticker, etc.

edited\_channel\_post

[Message](#message)

*Optional*. New version of a channel post that is known to the bot and was edited. This update may at times be triggered by changes to message fields that are either unavailable or not actively used by your bot.

business\_connection

[BusinessConnection](#businessconnection)

*Optional*. The bot was connected to or disconnected from a business account, or a user edited an existing connection with the bot

business\_message

[Message](#message)

*Optional*. New message from a connected business account

edited\_business\_message

[Message](#message)

*Optional*. New version of a message from a connected business account

deleted\_business\_messages

[BusinessMessagesDeleted](#businessmessagesdeleted)

*Optional*. Messages were deleted from a connected business account

message\_reaction

[MessageReactionUpdated](#messagereactionupdated)

*Optional*. A reaction to a message was changed by a user. The bot must be an administrator in the chat and must explicitly specify `"message_reaction"` in the list of *allowed\_updates* to receive these updates. The update isn't received for reactions set by bots.

message\_reaction\_count

[MessageReactionCountUpdated](#messagereactioncountupdated)

*Optional*. Reactions to a message with anonymous reactions were changed. The bot must be an administrator in the chat and must explicitly specify `"message_reaction_count"` in the list of *allowed\_updates* to receive these updates. The updates are grouped and can be sent with delay up to a few minutes.

inline\_query

[InlineQuery](#inlinequery)

*Optional*. New incoming [inline](#inline-mode) query

chosen\_inline\_result

[ChosenInlineResult](#choseninlineresult)

*Optional*. The result of an [inline](#inline-mode) query that was chosen by a user and sent to their chat partner. Please see our documentation on the [feedback collecting](/bots/inline#collecting-feedback) for details on how to enable these updates for your bot.

callback\_query

[CallbackQuery](#callbackquery)

*Optional*. New incoming callback query

shipping\_query

[ShippingQuery](#shippingquery)

*Optional*. New incoming shipping query. Only for invoices with flexible price

pre\_checkout\_query

[PreCheckoutQuery](#precheckoutquery)

*Optional*. New incoming pre-checkout query. Contains full information about checkout

purchased\_paid\_media

[PaidMediaPurchased](#paidmediapurchased)

*Optional*. A user purchased paid media with a non-empty payload sent by the bot in a non-channel chat

poll

[Poll](#poll)

*Optional*. New poll state. Bots receive only updates about manually stopped polls and polls, which are sent by the bot

poll\_answer

[PollAnswer](#pollanswer)

*Optional*. A user changed their answer in a non-anonymous poll. Bots receive new votes only in polls that were sent by the bot itself.

my\_chat\_member

[ChatMemberUpdated](#chatmemberupdated)

*Optional*. The bot's chat member status was updated in a chat. For private chats, this update is received only when the bot is blocked or unblocked by the user.

chat\_member

[ChatMemberUpdated](#chatmemberupdated)

*Optional*. A chat member's status was updated in a chat. The bot must be an administrator in the chat and must explicitly specify `"chat_member"` in the list of *allowed\_updates* to receive these updates.

chat\_join\_request

[ChatJoinRequest](#chatjoinrequest)

*Optional*. A request to join the chat has been sent. The bot must have the *can\_invite\_users* administrator right in the chat to receive these updates.

chat\_boost

[ChatBoostUpdated](#chatboostupdated)

*Optional*. A chat boost was added or changed. The bot must be an administrator in the chat to receive these updates.

removed\_chat\_boost

[ChatBoostRemoved](#chatboostremoved)

*Optional*. A boost was removed from a chat. The bot must be an administrator in the chat to receive these updates.

#### [](#getupdates)getUpdates

Use this method to receive incoming updates using long polling ([wiki](https://en.wikipedia.org/wiki/Push_technology#Long_polling)). Returns an Array of [Update](#update) objects.

Parameter

Type

Required

Description

offset

Integer

Optional

Identifier of the first update to be returned. Must be greater by one than the highest among the identifiers of previously received updates. By default, updates starting with the earliest unconfirmed update are returned. An update is considered confirmed as soon as [getUpdates](#getupdates) is called with an *offset* higher than its *update\_id*. The negative offset can be specified to retrieve updates starting from *\-offset* update from the end of the updates queue. All previous updates will be forgotten.

limit

Integer

Optional

Limits the number of updates to be retrieved. Values between 1-100 are accepted. Defaults to 100.

timeout

Integer

Optional

Timeout in seconds for long polling. Defaults to 0, i.e. usual short polling. Should be positive, short polling should be used for testing purposes only.

allowed\_updates

Array of String

Optional

A JSON-serialized list of the update types you want your bot to receive. For example, specify `["message", "edited_channel_post", "callback_query"]` to only receive updates of these types. See [Update](#update) for a complete list of available update types. Specify an empty list to receive all update types except *chat\_member*, *message\_reaction*, and *message\_reaction\_count* (default). If not specified, the previous setting will be used.  
  
Please note that this parameter doesn't affect updates created before the call to getUpdates, so unwanted updates may be received for a short period of time.

> **Notes**  
> **1.** This method will not work if an outgoing webhook is set up.  
> **2.** In order to avoid getting duplicate updates, recalculate *offset* after each server response.

#### [](#setwebhook)setWebhook

Use this method to specify a URL and receive incoming updates via an outgoing webhook. Whenever there is an update for the bot, we will send an HTTPS POST request to the specified URL, containing a JSON-serialized [Update](#update). In case of an unsuccessful request (a request with response [HTTP status code](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes) different from `2XY`), we will repeat the request and give up after a reasonable amount of attempts. Returns *True* on success.

If you'd like to make sure that the webhook was set by you, you can specify secret data in the parameter *secret\_token*. If specified, the request will contain a header “X-Telegram-Bot-Api-Secret-Token” with the secret token as content.

Parameter

Type

Required

Description

url

String

Yes

HTTPS URL to send updates to. Use an empty string to remove webhook integration

certificate

[InputFile](#inputfile)

Optional

Upload your public key certificate so that the root certificate in use can be checked. See our [self-signed guide](/bots/self-signed) for details.

ip\_address

String

Optional

The fixed IP address which will be used to send webhook requests instead of the IP address resolved through DNS

max\_connections

Integer

Optional

The maximum allowed number of simultaneous HTTPS connections to the webhook for update delivery, 1-100. Defaults to *40*. Use lower values to limit the load on your bot's server, and higher values to increase your bot's throughput.

allowed\_updates

Array of String

Optional

A JSON-serialized list of the update types you want your bot to receive. For example, specify `["message", "edited_channel_post", "callback_query"]` to only receive updates of these types. See [Update](#update) for a complete list of available update types. Specify an empty list to receive all update types except *chat\_member*, *message\_reaction*, and *message\_reaction\_count* (default). If not specified, the previous setting will be used.  
Please note that this parameter doesn't affect updates created before the call to the setWebhook, so unwanted updates may be received for a short period of time.

drop\_pending\_updates

Boolean

Optional

Pass *True* to drop all pending updates

secret\_token

String

Optional

A secret token to be sent in a header “X-Telegram-Bot-Api-Secret-Token” in every webhook request, 1-256 characters. Only characters `A-Z`, `a-z`, `0-9`, `_` and `-` are allowed. The header is useful to ensure that the request comes from a webhook set by you.

> **Notes**  
> **1.** You will not be able to receive updates using [getUpdates](#getupdates) for as long as an outgoing webhook is set up.  
> **2.** To use a self-signed certificate, you need to upload your [public key certificate](/bots/self-signed) using *certificate* parameter. Please upload as InputFile, sending a String will not work.  
> **3.** Ports currently supported *for webhooks*: **443, 80, 88, 8443**.
> 
> If you're having any trouble setting up webhooks, please check out this [amazing guide to webhooks](/bots/webhooks).

#### [](#deletewebhook)deleteWebhook

Use this method to remove webhook integration if you decide to switch back to [getUpdates](#getupdates). Returns *True* on success.

Parameter

Type

Required

Description

drop\_pending\_updates

Boolean

Optional

Pass *True* to drop all pending updates

#### [](#getwebhookinfo)getWebhookInfo

Use this method to get current webhook status. Requires no parameters. On success, returns a [WebhookInfo](#webhookinfo) object. If the bot is using [getUpdates](#getupdates), will return an object with the *url* field empty.

#### [](#webhookinfo)WebhookInfo

Describes the current status of a webhook.

Field

Type

Description

url

String

Webhook URL, may be empty if webhook is not set up

has\_custom\_certificate

Boolean

*True*, if a custom certificate was provided for webhook certificate checks

pending\_update\_count

Integer

Number of updates awaiting delivery

ip\_address

String

*Optional*. Currently used webhook IP address

last\_error\_date

Integer

*Optional*. Unix time for the most recent error that happened when trying to deliver an update via webhook

last\_error\_message

String

*Optional*. Error message in human-readable format for the most recent error that happened when trying to deliver an update via webhook

last\_synchronization\_error\_date

Integer

*Optional*. Unix time of the most recent error that happened when trying to synchronize available updates with Telegram datacenters

max\_connections

Integer

*Optional*. The maximum allowed number of simultaneous HTTPS connections to the webhook for update delivery

allowed\_updates

Array of String

*Optional*. A list of update types the bot is subscribed to. Defaults to all update types except *chat\_member*

