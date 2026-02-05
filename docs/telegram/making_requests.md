### [](#making-requests)Making requests

All queries to the Telegram Bot API must be served over HTTPS and need to be presented in this form: `https://api.telegram.org/bot<token>/METHOD_NAME`. Like this for example:

```
https://api.telegram.org/bot123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11/getMe
```

We support **GET** and **POST** HTTP methods. We support four ways of passing parameters in Bot API requests:

-   [URL query string](https://en.wikipedia.org/wiki/Query_string)
-   application/x-www-form-urlencoded
-   application/json (except for uploading files)
-   multipart/form-data (use to upload files)

The response contains a JSON object, which always has a Boolean field 'ok' and may have an optional String field 'description' with a human-readable description of the result. If 'ok' equals *True*, the request was successful and the result of the query can be found in the 'result' field. In case of an unsuccessful request, 'ok' equals false and the error is explained in the 'description'. An Integer 'error\_code' field is also returned, but its contents are subject to change in the future. Some errors may also have an optional field 'parameters' of the type [ResponseParameters](#responseparameters), which can help to automatically handle the error.

-   All methods in the Bot API are case-insensitive.
-   All queries must be made using UTF-8.

#### [](#making-requests-when-getting-updates)Making requests when getting updates

If you're using [**webhooks**](#getting-updates), you can perform a request to the Bot API while sending an answer to the webhook. Use either *application/json* or *application/x-www-form-urlencoded* or *multipart/form-data* response content type for passing parameters. Specify the method to be invoked in the *method* parameter of the request. It's not possible to know that such a request was successful or get its result.

> Please see our [FAQ](/bots/faq#how-can-i-make-requests-in-response-to-updates) for examples.

