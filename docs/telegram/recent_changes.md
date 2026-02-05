### [](#recent-changes)Recent changes

> Subscribe to [@BotNews](https://t.me/botnews) to be the first to know about the latest updates and join the discussion in [@BotTalk](https://t.me/bottalk)

#### [](#december-31-2025)December 31, 2025

**Bot API 9.3**

**Topics in private chats**

-   Added the field *has\_topics\_enabled* to the class [User](#user), which can be used to determine whether forum topic mode is enabled for the bot in private chats.
-   Added the method [sendMessageDraft](#sendmessagedraft), allowing partial messages to be streamed to a user while being generated.
-   Supported the fields *message\_thread\_id* and *is\_topic\_message* in the class [Message](#message) for messages in private chats with forum topic mode enabled.
-   Supported the parameter *message\_thread\_id* in private chats with topics in the methods [sendMessage](#sendmessage), [sendPhoto](#sendphoto), [sendVideo](#sendvideo), [sendAnimation](#sendanimation), [sendAudio](#sendaudio), [sendDocument](#senddocument), [sendPaidMedia](#sendpaidmedia), [sendSticker](#sendsticker), [sendVideoNote](#sendvideonote), [sendVoice](#sendvoice), [sendLocation](#sendlocation), [sendVenue](#sendvenue), [sendContact](#sendcontact), [sendPoll](#sendpoll), [sendDice](#senddice), [sendInvoice](#sendinvoice), [sendGame](#sendgame), [sendMediaGroup](#sendmediagroup), [copyMessage](#copymessage), [copyMessages](#copymessages), [forwardMessage](#forwardmessage), and [forwardMessages](#forwardmessages), allowing bots to send a message to a specific topic.
-   Supported the parameter *message\_thread\_id* in private chats in the method [sendChatAction](#sendchataction), allowing bots to send chat actions to a specific topic in private chats.
-   Supported the parameter *message\_thread\_id* in private chats with topics in the method [editForumTopic](#editforumtopic), [deleteForumTopic](#deleteforumtopic), and [unpinAllForumTopicMessages](#unpinallforumtopicmessages), allowing bots to manage topics in private chats.
-   Added the field *is\_name\_implicit* to the classes [ForumTopic](#forumtopic) and [ForumTopicCreated](#forumtopiccreated).

**Gifts**

-   Added the methods [getUserGifts](#getusergifts) and [getChatGifts](#getchatgifts).
-   Replaced the field *last\_resale\_star\_count* with the fields *last\_resale\_currency* and *last\_resale\_amount* in the class [UniqueGiftInfo](#uniquegiftinfo).
-   Replaced the parameter *exclude\_limited* with the parameters *exclude\_limited\_upgradable* and *exclude\_limited\_non\_upgradable* in the method [getBusinessAccountGifts](#getbusinessaccountgifts).
-   Added the value “gifted\_upgrade” as a possible value of *UniqueGiftInfo.origin* for messages about the upgrade of a gift that was purchased after it was sent.
-   Added the value “offer” as a possible value of *UniqueGiftInfo.origin* for messages about the purchase of a gift through a purchase offer.
-   Added the field *gift\_upgrade\_sent* to the class [Message](#message).
-   Added the field *gift\_id* to the class [UniqueGift](#uniquegift).
-   Added the field *is\_from\_blockchain* to the class [UniqueGift](#uniquegift).
-   Added the parameter *exclude\_from\_blockchain* in the method [getBusinessAccountGifts](#getbusinessaccountgifts), to filter out gifts that were assigned from the TON blockchain.
-   Added the fields *personal\_total\_count* and *personal\_remaining\_count* to the class [Gift](#gift).
-   Added the field *is\_premium* to the classes [Gift](#gift) and [UniqueGift](#uniquegift).
-   Added the field *is\_upgrade\_separate* to the classes [GiftInfo](#giftinfo) and [OwnedGiftRegular](#ownedgiftregular).
-   Added the class [UniqueGiftColors](#uniquegiftcolors) that describes the color scheme for a user's name, replies to messages and link previews based on a unique gift.
-   Added the field *has\_colors* to the class [Gift](#gift).
-   Added the field *colors* to the class [UniqueGift](#uniquegift).
-   Added the class [GiftBackground](#giftbackground) and the field *background* to the class [Gift](#gift).
-   Added the field *unique\_gift\_variant\_count* to the class [Gift](#gift).
-   Added the field *unique\_gift\_number* to the classes [GiftInfo](#giftinfo) and [OwnedGiftRegular](#ownedgiftregular).
-   Added the field *gifts\_from\_channels* to the class [AcceptedGiftTypes](#acceptedgifttypes).

**Miscellaneous**

-   Allowed bots to disable their main username if they have additional active usernames purchased on Fragment.
-   Allowed bots to disable the right *can\_restrict\_members* in channel chats.
-   Added the method [repostStory](#repoststory), allowing bots to repost stories across different business accounts they manage.
-   Added the class [UserRating](#userrating) and the field *rating* to the class [ChatFullInfo](#chatfullinfo).
-   Increased the maximum price for paid media to 25000 Telegram Stars.
-   Added the field *paid\_message\_star\_count* to the class [ChatFullInfo](#chatfullinfo).
-   Added the parameter *message\_effect\_id* to the methods [forwardMessage](#forwardmessage) and [copyMessage](#copymessage).
-   Added the field *unique\_gift\_colors* to the class [ChatFullInfo](#chatfullinfo).
-   Added the field *completed\_by\_chat* to the class [ChecklistTask](#checklisttask).

#### [](#august-15-2025)August 15, 2025

**Bot API 9.2**

**Checklists**

-   Added the field *checklist\_task\_id* to the class [ReplyParameters](#replyparameters), allowing bots to reply to a specific checklist task.
-   Added the field *reply\_to\_checklist\_task\_id* to the class [Message](#message).

**Gifts**

-   Added the field *publisher\_chat* to the classes [Gift](#gift) and [UniqueGift](#uniquegift) which can be used to get information about the chat that published a gift.

**Direct Messages in Channels**

-   Added the field *is\_direct\_messages* to the classes [Chat](#chat) and [ChatFullInfo](#chatfullinfo) which can be used to identify supergroups that are used as channel direct messages chats.
-   Added the field *parent\_chat* to the class [ChatFullInfo](#chatfullinfo) which indicates the parent channel chat for a channel direct messages chat.
-   Added the class [DirectMessagesTopic](#directmessagestopic) and the field *direct\_messages\_topic* to the class [Message](#message), describing a topic of a direct messages chat.
-   Added the parameter *direct\_messages\_topic\_id* to the methods [sendMessage](#sendmessage), [sendPhoto](#sendphoto), [sendVideo](#sendvideo), [sendAnimation](#sendanimation), [sendAudio](#sendaudio), [sendDocument](#senddocument), [sendPaidMedia](#sendpaidmedia), [sendSticker](#sendsticker), [sendVideoNote](#sendvideonote), [sendVoice](#sendvoice), [sendLocation](#sendlocation), [sendVenue](#sendvenue), [sendContact](#sendcontact), [sendDice](#senddice), [sendInvoice](#sendinvoice), [sendMediaGroup](#sendmediagroup), [copyMessage](#copymessage), [copyMessages](#copymessages), [forwardMessage](#forwardmessage) and [forwardMessages](#forwardmessages). This parameter can be used to send a message to a direct messages chat topic.

**Suggested Posts**

-   Added the class [SuggestedPostParameters](#suggestedpostparameters) and the parameter *suggested\_post\_parameters* to the methods [sendMessage](#sendmessage), [sendPhoto](#sendphoto), [sendVideo](#sendvideo), [sendAnimation](#sendanimation), [sendAudio](#sendaudio), [sendDocument](#senddocument), [sendPaidMedia](#sendpaidmedia), [sendSticker](#sendsticker), [sendVideoNote](#sendvideonote), [sendVoice](#sendvoice), [sendLocation](#sendlocation), [sendVenue](#sendvenue), [sendContact](#sendcontact), [sendDice](#senddice), [sendInvoice](#sendinvoice), [copyMessage](#copymessage), [forwardMessage](#forwardmessage). This parameter can be used to send a suggested post to a direct messages chat topic.
-   Added the method [approveSuggestedPost](#approvesuggestedpost), allowing bots to approve incoming suggested posts.
-   Added the method [declineSuggestedPost](#declinesuggestedpost), allowing bots to decline incoming suggested posts.
-   Added the field *can\_manage\_direct\_messages* to the classes [ChatMemberAdministrator](#chatmemberadministrator) and [ChatAdministratorRights](#chatadministratorrights).
-   Added the parameter *can\_manage\_direct\_messages* to the method [promoteChatMember](#promotechatmember).
-   Added the field *is\_paid\_post* to the class [Message](#message), which can be used to identify paid posts. Such posts must not be deleted for 24 hours to receive the payment.
-   Added the class [SuggestedPostPrice](#suggestedpostprice), describing the price of a suggested post.
-   Added the class [SuggestedPostInfo](#suggestedpostinfo) and the field *suggested\_post\_info* to the class [Message](#message), describing a suggested post.
-   Added the class [SuggestedPostApproved](#suggestedpostapproved) and the field *suggested\_post\_approved* to the class [Message](#message), describing a service message about the approval of a suggested post.
-   Added the class [SuggestedPostApprovalFailed](#suggestedpostapprovalfailed) and the field *suggested\_post\_approval\_failed* to the class [Message](#message), describing a service message about the failed approval of a suggested post.
-   Added the class [SuggestedPostDeclined](#suggestedpostdeclined) and the field *suggested\_post\_declined* to the class [Message](#message), describing a service message about the rejection of a suggested post.
-   Added the class [SuggestedPostPaid](#suggestedpostpaid) and the field *suggested\_post\_paid* to the class [Message](#message), describing a service message about a successful payment for a suggested post.
-   Added the class [SuggestedPostRefunded](#suggestedpostrefunded) and the field *suggested\_post\_refunded* to the class [Message](#message), describing a service message about a payment refund for a suggested post.

#### [](#july-3-2025)July 3, 2025

**Bot API 9.1**

**Checklists**

-   Added the class [ChecklistTask](#checklisttask) representing a task in a checklist.
-   Added the class [Checklist](#checklist) representing a checklist.
-   Added the class [InputChecklistTask](#inputchecklisttask) representing a task to add to a checklist.
-   Added the class [InputChecklist](#inputchecklist) representing a checklist to create.
-   Added the field *checklist* to the classes [Message](#message) and [ExternalReplyInfo](#externalreplyinfo), describing a checklist in a message.
-   Added the class [ChecklistTasksDone](#checklisttasksdone) and the field *checklist\_tasks\_done* to the class [Message](#message), describing a service message about status changes for tasks in a checklist (i.e., marked as done/not done).
-   Added the class [ChecklistTasksAdded](#checklisttasksadded) and the field *checklist\_tasks\_added* to the class [Message](#message), describing a service message about the addition of new tasks to a checklist.
-   Added the method [sendChecklist](#sendchecklist), allowing bots to send a checklist on behalf of a business account.
-   Added the method [editMessageChecklist](#editmessagechecklist), allowing bots to edit a checklist on behalf of a business account.

**Gifts**

-   Added the field *next\_transfer\_date* to the classes [OwnedGiftUnique](#ownedgiftunique) and [UniqueGiftInfo](#uniquegiftinfo).
-   Added the field *last\_resale\_star\_count* to the class [UniqueGiftInfo](#uniquegiftinfo).
-   Added “resale” as the possible value of the field *origin* in the class [UniqueGiftInfo](#uniquegiftinfo).

**General**

-   Increased the maximum number of options in a poll to 12.
-   Added the method [getMyStarBalance](#getmystarbalance), allowing bots to get their current balance of Telegram Stars.
-   Added the class [DirectMessagePriceChanged](#directmessagepricechanged) and the field *direct\_message\_price\_changed* to the class [Message](#message), describing a service message about a price change for direct messages sent to the channel chat.
-   Added the method *hideKeyboard* to the class [WebApp](/bots/webapps#initializing-mini-apps).

**[See earlier changes »](/bots/api-changelog)**

