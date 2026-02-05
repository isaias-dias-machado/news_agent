### [](#payments)Payments

Your bot can accept payments from Telegram users. Please see the [introduction to payments](/bots/payments) for more details on the process and how to set up payments for your bot.

#### [](#sendinvoice)sendInvoice

Use this method to send invoices. On success, the sent [Message](#message) is returned.

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

title

String

Yes

Product name, 1-32 characters

description

String

Yes

Product description, 1-255 characters

payload

String

Yes

Bot-defined invoice payload, 1-128 bytes. This will not be displayed to the user, use it for your internal processes.

provider\_token

String

Optional

Payment provider token, obtained via [@BotFather](https://t.me/botfather). Pass an empty string for payments in [Telegram Stars](https://t.me/BotNews/90).

currency

String

Yes

Three-letter ISO 4217 currency code, see [more on currencies](/bots/payments#supported-currencies). Pass “XTR” for payments in [Telegram Stars](https://t.me/BotNews/90).

prices

Array of [LabeledPrice](#labeledprice)

Yes

Price breakdown, a JSON-serialized list of components (e.g. product price, tax, discount, delivery cost, delivery tax, bonus, etc.). Must contain exactly one item for payments in [Telegram Stars](https://t.me/BotNews/90).

max\_tip\_amount

Integer

Optional

The maximum accepted amount for tips in the *smallest units* of the currency (integer, **not** float/double). For example, for a maximum tip of `US$ 1.45` pass `max_tip_amount = 145`. See the *exp* parameter in [currencies.json](/bots/payments/currencies.json), it shows the number of digits past the decimal point for each currency (2 for the majority of currencies). Defaults to 0. Not supported for payments in [Telegram Stars](https://t.me/BotNews/90).

suggested\_tip\_amounts

Array of Integer

Optional

A JSON-serialized array of suggested amounts of tips in the *smallest units* of the currency (integer, **not** float/double). At most 4 suggested tip amounts can be specified. The suggested tip amounts must be positive, passed in a strictly increased order and must not exceed *max\_tip\_amount*.

start\_parameter

String

Optional

Unique deep-linking parameter. If left empty, **forwarded copies** of the sent message will have a *Pay* button, allowing multiple users to pay directly from the forwarded message, using the same invoice. If non-empty, forwarded copies of the sent message will have a *URL* button with a deep link to the bot (instead of a *Pay* button), with the value used as the start parameter

provider\_data

String

Optional

JSON-serialized data about the invoice, which will be shared with the payment provider. A detailed description of required fields should be provided by the payment provider.

photo\_url

String

Optional

URL of the product photo for the invoice. Can be a photo of the goods or a marketing image for a service. People like it better when they see what they are paying for.

photo\_size

Integer

Optional

Photo size in bytes

photo\_width

Integer

Optional

Photo width

photo\_height

Integer

Optional

Photo height

need\_name

Boolean

Optional

Pass *True* if you require the user's full name to complete the order. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

need\_phone\_number

Boolean

Optional

Pass *True* if you require the user's phone number to complete the order. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

need\_email

Boolean

Optional

Pass *True* if you require the user's email address to complete the order. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

need\_shipping\_address

Boolean

Optional

Pass *True* if you require the user's shipping address to complete the order. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

send\_phone\_number\_to\_provider

Boolean

Optional

Pass *True* if the user's phone number should be sent to the provider. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

send\_email\_to\_provider

Boolean

Optional

Pass *True* if the user's email address should be sent to the provider. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

is\_flexible

Boolean

Optional

Pass *True* if the final price depends on the shipping method. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

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

[InlineKeyboardMarkup](#inlinekeyboardmarkup)

Optional

A JSON-serialized object for an [inline keyboard](/bots/features#inline-keyboards). If empty, one 'Pay `total price`' button will be shown. If not empty, the first button must be a Pay button.

#### [](#createinvoicelink)createInvoiceLink

Use this method to create a link for an invoice. Returns the created invoice link as *String* on success.

Parameter

Type

Required

Description

business\_connection\_id

String

Optional

Unique identifier of the business connection on behalf of which the link will be created. For payments in [Telegram Stars](https://t.me/BotNews/90) only.

title

String

Yes

Product name, 1-32 characters

description

String

Yes

Product description, 1-255 characters

payload

String

Yes

Bot-defined invoice payload, 1-128 bytes. This will not be displayed to the user, use it for your internal processes.

provider\_token

String

Optional

Payment provider token, obtained via [@BotFather](https://t.me/botfather). Pass an empty string for payments in [Telegram Stars](https://t.me/BotNews/90).

currency

String

Yes

Three-letter ISO 4217 currency code, see [more on currencies](/bots/payments#supported-currencies). Pass “XTR” for payments in [Telegram Stars](https://t.me/BotNews/90).

prices

Array of [LabeledPrice](#labeledprice)

Yes

Price breakdown, a JSON-serialized list of components (e.g. product price, tax, discount, delivery cost, delivery tax, bonus, etc.). Must contain exactly one item for payments in [Telegram Stars](https://t.me/BotNews/90).

subscription\_period

Integer

Optional

The number of seconds the subscription will be active for before the next payment. The currency must be set to “XTR” (Telegram Stars) if the parameter is used. Currently, it must always be 2592000 (30 days) if specified. Any number of subscriptions can be active for a given bot at the same time, including multiple concurrent subscriptions from the same user. Subscription price must no exceed 10000 Telegram Stars.

max\_tip\_amount

Integer

Optional

The maximum accepted amount for tips in the *smallest units* of the currency (integer, **not** float/double). For example, for a maximum tip of `US$ 1.45` pass `max_tip_amount = 145`. See the *exp* parameter in [currencies.json](/bots/payments/currencies.json), it shows the number of digits past the decimal point for each currency (2 for the majority of currencies). Defaults to 0. Not supported for payments in [Telegram Stars](https://t.me/BotNews/90).

suggested\_tip\_amounts

Array of Integer

Optional

A JSON-serialized array of suggested amounts of tips in the *smallest units* of the currency (integer, **not** float/double). At most 4 suggested tip amounts can be specified. The suggested tip amounts must be positive, passed in a strictly increased order and must not exceed *max\_tip\_amount*.

provider\_data

String

Optional

JSON-serialized data about the invoice, which will be shared with the payment provider. A detailed description of required fields should be provided by the payment provider.

photo\_url

String

Optional

URL of the product photo for the invoice. Can be a photo of the goods or a marketing image for a service.

photo\_size

Integer

Optional

Photo size in bytes

photo\_width

Integer

Optional

Photo width

photo\_height

Integer

Optional

Photo height

need\_name

Boolean

Optional

Pass *True* if you require the user's full name to complete the order. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

need\_phone\_number

Boolean

Optional

Pass *True* if you require the user's phone number to complete the order. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

need\_email

Boolean

Optional

Pass *True* if you require the user's email address to complete the order. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

need\_shipping\_address

Boolean

Optional

Pass *True* if you require the user's shipping address to complete the order. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

send\_phone\_number\_to\_provider

Boolean

Optional

Pass *True* if the user's phone number should be sent to the provider. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

send\_email\_to\_provider

Boolean

Optional

Pass *True* if the user's email address should be sent to the provider. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

is\_flexible

Boolean

Optional

Pass *True* if the final price depends on the shipping method. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).

#### [](#answershippingquery)answerShippingQuery

If you sent an invoice requesting a shipping address and the parameter *is\_flexible* was specified, the Bot API will send an [Update](#update) with a *shipping\_query* field to the bot. Use this method to reply to shipping queries. On success, *True* is returned.

Parameter

Type

Required

Description

shipping\_query\_id

String

Yes

Unique identifier for the query to be answered

ok

Boolean

Yes

Pass *True* if delivery to the specified address is possible and *False* if there are any problems (for example, if delivery to the specified address is not possible)

shipping\_options

Array of [ShippingOption](#shippingoption)

Optional

Required if *ok* is *True*. A JSON-serialized array of available shipping options.

error\_message

String

Optional

Required if *ok* is *False*. Error message in human readable form that explains why it is impossible to complete the order (e.g. “Sorry, delivery to your desired address is unavailable”). Telegram will display this message to the user.

#### [](#answerprecheckoutquery)answerPreCheckoutQuery

Once the user has confirmed their payment and shipping details, the Bot API sends the final confirmation in the form of an [Update](#update) with the field *pre\_checkout\_query*. Use this method to respond to such pre-checkout queries. On success, *True* is returned. **Note:** The Bot API must receive an answer within 10 seconds after the pre-checkout query was sent.

Parameter

Type

Required

Description

pre\_checkout\_query\_id

String

Yes

Unique identifier for the query to be answered

ok

Boolean

Yes

Specify *True* if everything is alright (goods are available, etc.) and the bot is ready to proceed with the order. Use *False* if there are any problems.

error\_message

String

Optional

Required if *ok* is *False*. Error message in human readable form that explains the reason for failure to proceed with the checkout (e.g. "Sorry, somebody just bought the last of our amazing black T-shirts while you were busy filling out your payment details. Please choose a different color or garment!"). Telegram will display this message to the user.

#### [](#getmystarbalance)getMyStarBalance

A method to get the current Telegram Stars balance of the bot. Requires no parameters. On success, returns a [StarAmount](#staramount) object.

#### [](#getstartransactions)getStarTransactions

Returns the bot's Telegram Star transactions in chronological order. On success, returns a [StarTransactions](#startransactions) object.

Parameter

Type

Required

Description

offset

Integer

Optional

Number of transactions to skip in the response

limit

Integer

Optional

The maximum number of transactions to be retrieved. Values between 1-100 are accepted. Defaults to 100.

#### [](#refundstarpayment)refundStarPayment

Refunds a successful payment in [Telegram Stars](https://t.me/BotNews/90). Returns *True* on success.

Parameter

Type

Required

Description

user\_id

Integer

Yes

Identifier of the user whose payment will be refunded

telegram\_payment\_charge\_id

String

Yes

Telegram payment identifier

#### [](#edituserstarsubscription)editUserStarSubscription

Allows the bot to cancel or re-enable extension of a subscription paid in Telegram Stars. Returns *True* on success.

Parameter

Type

Required

Description

user\_id

Integer

Yes

Identifier of the user whose subscription will be edited

telegram\_payment\_charge\_id

String

Yes

Telegram payment identifier for the subscription

is\_canceled

Boolean

Yes

Pass *True* to cancel extension of the user subscription; the subscription must be active up to the end of the current subscription period. Pass *False* to allow the user to re-enable a subscription that was previously canceled by the bot.

#### [](#labeledprice)LabeledPrice

This object represents a portion of the price for goods or services.

Field

Type

Description

label

String

Portion label

amount

Integer

Price of the product in the *smallest units* of the [currency](/bots/payments#supported-currencies) (integer, **not** float/double). For example, for a price of `US$ 1.45` pass `amount = 145`. See the *exp* parameter in [currencies.json](/bots/payments/currencies.json), it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).

#### [](#invoice)Invoice

This object contains basic information about an invoice.

Field

Type

Description

title

String

Product name

description

String

Product description

start\_parameter

String

Unique bot deep-linking parameter that can be used to generate this invoice

currency

String

Three-letter ISO 4217 [currency](/bots/payments#supported-currencies) code, or “XTR” for payments in [Telegram Stars](https://t.me/BotNews/90)

total\_amount

Integer

Total price in the *smallest units* of the currency (integer, **not** float/double). For example, for a price of `US$ 1.45` pass `amount = 145`. See the *exp* parameter in [currencies.json](/bots/payments/currencies.json), it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).

#### [](#shippingaddress)ShippingAddress

This object represents a shipping address.

Field

Type

Description

country\_code

String

Two-letter [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code

state

String

State, if applicable

city

String

City

street\_line1

String

First line for the address

street\_line2

String

Second line for the address

post\_code

String

Address post code

#### [](#orderinfo)OrderInfo

This object represents information about an order.

Field

Type

Description

name

String

*Optional*. User name

phone\_number

String

*Optional*. User's phone number

email

String

*Optional*. User email

shipping\_address

[ShippingAddress](#shippingaddress)

*Optional*. User shipping address

#### [](#shippingoption)ShippingOption

This object represents one shipping option.

Field

Type

Description

id

String

Shipping option identifier

title

String

Option title

prices

Array of [LabeledPrice](#labeledprice)

List of price portions

#### [](#successfulpayment)SuccessfulPayment

This object contains basic information about a successful payment. Note that if the buyer initiates a chargeback with the relevant payment provider following this transaction, the funds may be debited from your balance. This is outside of Telegram's control.

Field

Type

Description

currency

String

Three-letter ISO 4217 [currency](/bots/payments#supported-currencies) code, or “XTR” for payments in [Telegram Stars](https://t.me/BotNews/90)

total\_amount

Integer

Total price in the *smallest units* of the currency (integer, **not** float/double). For example, for a price of `US$ 1.45` pass `amount = 145`. See the *exp* parameter in [currencies.json](/bots/payments/currencies.json), it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).

invoice\_payload

String

Bot-specified invoice payload

subscription\_expiration\_date

Integer

*Optional*. Expiration date of the subscription, in Unix time; for recurring payments only

is\_recurring

True

*Optional*. *True*, if the payment is a recurring payment for a subscription

is\_first\_recurring

True

*Optional*. *True*, if the payment is the first payment for a subscription

shipping\_option\_id

String

*Optional*. Identifier of the shipping option chosen by the user

order\_info

[OrderInfo](#orderinfo)

*Optional*. Order information provided by the user

telegram\_payment\_charge\_id

String

Telegram payment identifier

provider\_payment\_charge\_id

String

Provider payment identifier

#### [](#refundedpayment)RefundedPayment

This object contains basic information about a refunded payment.

Field

Type

Description

currency

String

Three-letter ISO 4217 [currency](/bots/payments#supported-currencies) code, or “XTR” for payments in [Telegram Stars](https://t.me/BotNews/90). Currently, always “XTR”

total\_amount

Integer

Total refunded price in the *smallest units* of the currency (integer, **not** float/double). For example, for a price of `US$ 1.45`, `total_amount = 145`. See the *exp* parameter in [currencies.json](/bots/payments/currencies.json), it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).

invoice\_payload

String

Bot-specified invoice payload

telegram\_payment\_charge\_id

String

Telegram payment identifier

provider\_payment\_charge\_id

String

*Optional*. Provider payment identifier

#### [](#shippingquery)ShippingQuery

This object contains information about an incoming shipping query.

Field

Type

Description

id

String

Unique query identifier

from

[User](#user)

User who sent the query

invoice\_payload

String

Bot-specified invoice payload

shipping\_address

[ShippingAddress](#shippingaddress)

User specified shipping address

#### [](#precheckoutquery)PreCheckoutQuery

This object contains information about an incoming pre-checkout query.

Field

Type

Description

id

String

Unique query identifier

from

[User](#user)

User who sent the query

currency

String

Three-letter ISO 4217 [currency](/bots/payments#supported-currencies) code, or “XTR” for payments in [Telegram Stars](https://t.me/BotNews/90)

total\_amount

Integer

Total price in the *smallest units* of the currency (integer, **not** float/double). For example, for a price of `US$ 1.45` pass `amount = 145`. See the *exp* parameter in [currencies.json](/bots/payments/currencies.json), it shows the number of digits past the decimal point for each currency (2 for the majority of currencies).

invoice\_payload

String

Bot-specified invoice payload

shipping\_option\_id

String

*Optional*. Identifier of the shipping option chosen by the user

order\_info

[OrderInfo](#orderinfo)

*Optional*. Order information provided by the user

#### [](#paidmediapurchased)PaidMediaPurchased

This object contains information about a paid media purchase.

Field

Type

Description

from

[User](#user)

User who purchased the media

paid\_media\_payload

String

Bot-specified paid media payload

#### [](#revenuewithdrawalstate)RevenueWithdrawalState

This object describes the state of a revenue withdrawal operation. Currently, it can be one of

-   [RevenueWithdrawalStatePending](#revenuewithdrawalstatepending)
-   [RevenueWithdrawalStateSucceeded](#revenuewithdrawalstatesucceeded)
-   [RevenueWithdrawalStateFailed](#revenuewithdrawalstatefailed)

#### [](#revenuewithdrawalstatepending)RevenueWithdrawalStatePending

The withdrawal is in progress.

Field

Type

Description

type

String

Type of the state, always “pending”

#### [](#revenuewithdrawalstatesucceeded)RevenueWithdrawalStateSucceeded

The withdrawal succeeded.

Field

Type

Description

type

String

Type of the state, always “succeeded”

date

Integer

Date the withdrawal was completed in Unix time

url

String

An HTTPS URL that can be used to see transaction details

#### [](#revenuewithdrawalstatefailed)RevenueWithdrawalStateFailed

The withdrawal failed and the transaction was refunded.

Field

Type

Description

type

String

Type of the state, always “failed”

#### [](#affiliateinfo)AffiliateInfo

Contains information about the affiliate that received a commission via this transaction.

Field

Type

Description

affiliate\_user

[User](#user)

*Optional*. The bot or the user that received an affiliate commission if it was received by a bot or a user

affiliate\_chat

[Chat](#chat)

*Optional*. The chat that received an affiliate commission if it was received by a chat

commission\_per\_mille

Integer

The number of Telegram Stars received by the affiliate for each 1000 Telegram Stars received by the bot from referred users

amount

Integer

Integer amount of Telegram Stars received by the affiliate from the transaction, rounded to 0; can be negative for refunds

nanostar\_amount

Integer

*Optional*. The number of 1/1000000000 shares of Telegram Stars received by the affiliate; from -999999999 to 999999999; can be negative for refunds

#### [](#transactionpartner)TransactionPartner

This object describes the source of a transaction, or its recipient for outgoing transactions. Currently, it can be one of

-   [TransactionPartnerUser](#transactionpartneruser)
-   [TransactionPartnerChat](#transactionpartnerchat)
-   [TransactionPartnerAffiliateProgram](#transactionpartneraffiliateprogram)
-   [TransactionPartnerFragment](#transactionpartnerfragment)
-   [TransactionPartnerTelegramAds](#transactionpartnertelegramads)
-   [TransactionPartnerTelegramApi](#transactionpartnertelegramapi)
-   [TransactionPartnerOther](#transactionpartnerother)

#### [](#transactionpartneruser)TransactionPartnerUser

Describes a transaction with a user.

Field

Type

Description

type

String

Type of the transaction partner, always “user”

transaction\_type

String

Type of the transaction, currently one of “invoice\_payment” for payments via invoices, “paid\_media\_payment” for payments for paid media, “gift\_purchase” for gifts sent by the bot, “premium\_purchase” for Telegram Premium subscriptions gifted by the bot, “business\_account\_transfer” for direct transfers from managed business accounts

user

[User](#user)

Information about the user

affiliate

[AffiliateInfo](#affiliateinfo)

*Optional*. Information about the affiliate that received a commission via this transaction. Can be available only for “invoice\_payment” and “paid\_media\_payment” transactions.

invoice\_payload

String

*Optional*. Bot-specified invoice payload. Can be available only for “invoice\_payment” transactions.

subscription\_period

Integer

*Optional*. The duration of the paid subscription. Can be available only for “invoice\_payment” transactions.

paid\_media

Array of [PaidMedia](#paidmedia)

*Optional*. Information about the paid media bought by the user; for “paid\_media\_payment” transactions only

paid\_media\_payload

String

*Optional*. Bot-specified paid media payload. Can be available only for “paid\_media\_payment” transactions.

gift

[Gift](#gift)

*Optional*. The gift sent to the user by the bot; for “gift\_purchase” transactions only

premium\_subscription\_duration

Integer

*Optional*. Number of months the gifted Telegram Premium subscription will be active for; for “premium\_purchase” transactions only

#### [](#transactionpartnerchat)TransactionPartnerChat

Describes a transaction with a chat.

Field

Type

Description

type

String

Type of the transaction partner, always “chat”

chat

[Chat](#chat)

Information about the chat

gift

[Gift](#gift)

*Optional*. The gift sent to the chat by the bot

#### [](#transactionpartneraffiliateprogram)TransactionPartnerAffiliateProgram

Describes the affiliate program that issued the affiliate commission received via this transaction.

Field

Type

Description

type

String

Type of the transaction partner, always “affiliate\_program”

sponsor\_user

[User](#user)

*Optional*. Information about the bot that sponsored the affiliate program

commission\_per\_mille

Integer

The number of Telegram Stars received by the bot for each 1000 Telegram Stars received by the affiliate program sponsor from referred users

#### [](#transactionpartnerfragment)TransactionPartnerFragment

Describes a withdrawal transaction with Fragment.

Field

Type

Description

type

String

Type of the transaction partner, always “fragment”

withdrawal\_state

[RevenueWithdrawalState](#revenuewithdrawalstate)

*Optional*. State of the transaction if the transaction is outgoing

#### [](#transactionpartnertelegramads)TransactionPartnerTelegramAds

Describes a withdrawal transaction to the Telegram Ads platform.

Field

Type

Description

type

String

Type of the transaction partner, always “telegram\_ads”

#### [](#transactionpartnertelegramapi)TransactionPartnerTelegramApi

Describes a transaction with payment for [paid broadcasting](#paid-broadcasts).

Field

Type

Description

type

String

Type of the transaction partner, always “telegram\_api”

request\_count

Integer

The number of successful requests that exceeded regular limits and were therefore billed

#### [](#transactionpartnerother)TransactionPartnerOther

Describes a transaction with an unknown source or recipient.

Field

Type

Description

type

String

Type of the transaction partner, always “other”

#### [](#startransaction)StarTransaction

Describes a Telegram Star transaction. Note that if the buyer initiates a chargeback with the payment provider from whom they acquired Stars (e.g., Apple, Google) following this transaction, the refunded Stars will be deducted from the bot's balance. This is outside of Telegram's control.

Field

Type

Description

id

String

Unique identifier of the transaction. Coincides with the identifier of the original transaction for refund transactions. Coincides with *SuccessfulPayment.telegram\_payment\_charge\_id* for successful incoming payments from users.

amount

Integer

Integer amount of Telegram Stars transferred by the transaction

nanostar\_amount

Integer

*Optional*. The number of 1/1000000000 shares of Telegram Stars transferred by the transaction; from 0 to 999999999

date

Integer

Date the transaction was created in Unix time

source

[TransactionPartner](#transactionpartner)

*Optional*. Source of an incoming transaction (e.g., a user purchasing goods or services, Fragment refunding a failed withdrawal). Only for incoming transactions

receiver

[TransactionPartner](#transactionpartner)

*Optional*. Receiver of an outgoing transaction (e.g., a user for a purchase refund, Fragment for a withdrawal). Only for outgoing transactions

#### [](#startransactions)StarTransactions

Contains a list of Telegram Star transactions.

Field

Type

Description

transactions

Array of [StarTransaction](#startransaction)

The list of transactions

