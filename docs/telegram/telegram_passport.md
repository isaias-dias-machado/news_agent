### [](#telegram-passport)Telegram Passport

**Telegram Passport** is a unified authorization method for services that require personal identification. Users can upload their documents once, then instantly share their data with services that require real-world ID (finance, ICOs, etc.). Please see the [manual](/passport) for details.

#### [](#passportdata)PassportData

Describes Telegram Passport data shared with the bot by the user.

Field

Type

Description

data

Array of [EncryptedPassportElement](#encryptedpassportelement)

Array with information about documents and other Telegram Passport elements that was shared with the bot

credentials

[EncryptedCredentials](#encryptedcredentials)

Encrypted credentials required to decrypt the data

#### [](#passportfile)PassportFile

This object represents a file uploaded to Telegram Passport. Currently all Telegram Passport files are in JPEG format when decrypted and don't exceed 10MB.

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

File size in bytes

file\_date

Integer

Unix time when the file was uploaded

#### [](#encryptedpassportelement)EncryptedPassportElement

Describes documents or other Telegram Passport elements shared with the bot by the user.

Field

Type

Description

type

String

Element type. One of “personal\_details”, “passport”, “driver\_license”, “identity\_card”, “internal\_passport”, “address”, “utility\_bill”, “bank\_statement”, “rental\_agreement”, “passport\_registration”, “temporary\_registration”, “phone\_number”, “email”.

data

String

*Optional*. Base64-encoded encrypted Telegram Passport element data provided by the user; available only for “personal\_details”, “passport”, “driver\_license”, “identity\_card”, “internal\_passport” and “address” types. Can be decrypted and verified using the accompanying [EncryptedCredentials](#encryptedcredentials).

phone\_number

String

*Optional*. User's verified phone number; available only for “phone\_number” type

email

String

*Optional*. User's verified email address; available only for “email” type

files

Array of [PassportFile](#passportfile)

*Optional*. Array of encrypted files with documents provided by the user; available only for “utility\_bill”, “bank\_statement”, “rental\_agreement”, “passport\_registration” and “temporary\_registration” types. Files can be decrypted and verified using the accompanying [EncryptedCredentials](#encryptedcredentials).

front\_side

[PassportFile](#passportfile)

*Optional*. Encrypted file with the front side of the document, provided by the user; available only for “passport”, “driver\_license”, “identity\_card” and “internal\_passport”. The file can be decrypted and verified using the accompanying [EncryptedCredentials](#encryptedcredentials).

reverse\_side

[PassportFile](#passportfile)

*Optional*. Encrypted file with the reverse side of the document, provided by the user; available only for “driver\_license” and “identity\_card”. The file can be decrypted and verified using the accompanying [EncryptedCredentials](#encryptedcredentials).

selfie

[PassportFile](#passportfile)

*Optional*. Encrypted file with the selfie of the user holding a document, provided by the user; available if requested for “passport”, “driver\_license”, “identity\_card” and “internal\_passport”. The file can be decrypted and verified using the accompanying [EncryptedCredentials](#encryptedcredentials).

translation

Array of [PassportFile](#passportfile)

*Optional*. Array of encrypted files with translated versions of documents provided by the user; available if requested for “passport”, “driver\_license”, “identity\_card”, “internal\_passport”, “utility\_bill”, “bank\_statement”, “rental\_agreement”, “passport\_registration” and “temporary\_registration” types. Files can be decrypted and verified using the accompanying [EncryptedCredentials](#encryptedcredentials).

hash

String

Base64-encoded element hash for using in [PassportElementErrorUnspecified](#passportelementerrorunspecified)

#### [](#encryptedcredentials)EncryptedCredentials

Describes data required for decrypting and authenticating [EncryptedPassportElement](#encryptedpassportelement). See the [Telegram Passport Documentation](/passport#receiving-information) for a complete description of the data decryption and authentication processes.

Field

Type

Description

data

String

Base64-encoded encrypted JSON-serialized data with unique user's payload, data hashes and secrets required for [EncryptedPassportElement](#encryptedpassportelement) decryption and authentication

hash

String

Base64-encoded data hash for data authentication

secret

String

Base64-encoded secret, encrypted with the bot's public RSA key, required for data decryption

#### [](#setpassportdataerrors)setPassportDataErrors

Informs a user that some of the Telegram Passport elements they provided contains errors. The user will not be able to re-submit their Passport to you until the errors are fixed (the contents of the field for which you returned the error must change). Returns *True* on success.

Use this if the data submitted by the user doesn't satisfy the standards your service requires for any reason. For example, if a birthday date seems invalid, a submitted document is blurry, a scan shows evidence of tampering, etc. Supply some details in the error message to make sure the user knows how to correct the issues.

Parameter

Type

Required

Description

user\_id

Integer

Yes

User identifier

errors

Array of [PassportElementError](#passportelementerror)

Yes

A JSON-serialized array describing the errors

#### [](#passportelementerror)PassportElementError

This object represents an error in the Telegram Passport element which was submitted that should be resolved by the user. It should be one of:

-   [PassportElementErrorDataField](#passportelementerrordatafield)
-   [PassportElementErrorFrontSide](#passportelementerrorfrontside)
-   [PassportElementErrorReverseSide](#passportelementerrorreverseside)
-   [PassportElementErrorSelfie](#passportelementerrorselfie)
-   [PassportElementErrorFile](#passportelementerrorfile)
-   [PassportElementErrorFiles](#passportelementerrorfiles)
-   [PassportElementErrorTranslationFile](#passportelementerrortranslationfile)
-   [PassportElementErrorTranslationFiles](#passportelementerrortranslationfiles)
-   [PassportElementErrorUnspecified](#passportelementerrorunspecified)

#### [](#passportelementerrordatafield)PassportElementErrorDataField

Represents an issue in one of the data fields that was provided by the user. The error is considered resolved when the field's value changes.

Field

Type

Description

source

String

Error source, must be *data*

type

String

The section of the user's Telegram Passport which has the error, one of “personal\_details”, “passport”, “driver\_license”, “identity\_card”, “internal\_passport”, “address”

field\_name

String

Name of the data field which has the error

data\_hash

String

Base64-encoded data hash

message

String

Error message

#### [](#passportelementerrorfrontside)PassportElementErrorFrontSide

Represents an issue with the front side of a document. The error is considered resolved when the file with the front side of the document changes.

Field

Type

Description

source

String

Error source, must be *front\_side*

type

String

The section of the user's Telegram Passport which has the issue, one of “passport”, “driver\_license”, “identity\_card”, “internal\_passport”

file\_hash

String

Base64-encoded hash of the file with the front side of the document

message

String

Error message

#### [](#passportelementerrorreverseside)PassportElementErrorReverseSide

Represents an issue with the reverse side of a document. The error is considered resolved when the file with reverse side of the document changes.

Field

Type

Description

source

String

Error source, must be *reverse\_side*

type

String

The section of the user's Telegram Passport which has the issue, one of “driver\_license”, “identity\_card”

file\_hash

String

Base64-encoded hash of the file with the reverse side of the document

message

String

Error message

#### [](#passportelementerrorselfie)PassportElementErrorSelfie

Represents an issue with the selfie with a document. The error is considered resolved when the file with the selfie changes.

Field

Type

Description

source

String

Error source, must be *selfie*

type

String

The section of the user's Telegram Passport which has the issue, one of “passport”, “driver\_license”, “identity\_card”, “internal\_passport”

file\_hash

String

Base64-encoded hash of the file with the selfie

message

String

Error message

#### [](#passportelementerrorfile)PassportElementErrorFile

Represents an issue with a document scan. The error is considered resolved when the file with the document scan changes.

Field

Type

Description

source

String

Error source, must be *file*

type

String

The section of the user's Telegram Passport which has the issue, one of “utility\_bill”, “bank\_statement”, “rental\_agreement”, “passport\_registration”, “temporary\_registration”

file\_hash

String

Base64-encoded file hash

message

String

Error message

#### [](#passportelementerrorfiles)PassportElementErrorFiles

Represents an issue with a list of scans. The error is considered resolved when the list of files containing the scans changes.

Field

Type

Description

source

String

Error source, must be *files*

type

String

The section of the user's Telegram Passport which has the issue, one of “utility\_bill”, “bank\_statement”, “rental\_agreement”, “passport\_registration”, “temporary\_registration”

file\_hashes

Array of String

List of base64-encoded file hashes

message

String

Error message

#### [](#passportelementerrortranslationfile)PassportElementErrorTranslationFile

Represents an issue with one of the files that constitute the translation of a document. The error is considered resolved when the file changes.

Field

Type

Description

source

String

Error source, must be *translation\_file*

type

String

Type of element of the user's Telegram Passport which has the issue, one of “passport”, “driver\_license”, “identity\_card”, “internal\_passport”, “utility\_bill”, “bank\_statement”, “rental\_agreement”, “passport\_registration”, “temporary\_registration”

file\_hash

String

Base64-encoded file hash

message

String

Error message

#### [](#passportelementerrortranslationfiles)PassportElementErrorTranslationFiles

Represents an issue with the translated version of a document. The error is considered resolved when a file with the document translation change.

Field

Type

Description

source

String

Error source, must be *translation\_files*

type

String

Type of element of the user's Telegram Passport which has the issue, one of “passport”, “driver\_license”, “identity\_card”, “internal\_passport”, “utility\_bill”, “bank\_statement”, “rental\_agreement”, “passport\_registration”, “temporary\_registration”

file\_hashes

Array of String

List of base64-encoded file hashes

message

String

Error message

#### [](#passportelementerrorunspecified)PassportElementErrorUnspecified

Represents an issue in an unspecified place. The error is considered resolved when new data is added.

Field

Type

Description

source

String

Error source, must be *unspecified*

type

String

Type of element of the user's Telegram Passport which has the issue

element\_hash

String

Base64-encoded element hash

message

String

Error message

