module Id exposing
    ( ChatId(..)
    , DocumentId(..)
    , Id(..)
    , chatId1
    , chatId2
    , chatId3
    , docId1
    , docId2
    , docId3
    , fromString
    , toString
    )

import UUID exposing (UUID)


{-| A universally unique identifier, using UUID v4 under the hood
-}
type Id a
    = Id UUID


type ChatId
    = ChatId Never


type DocumentId
    = DocumentId Never


toString : Id a -> String
toString (Id uuid) =
    UUID.toString uuid


fromString : String -> Maybe (Id a)
fromString str =
    UUID.fromString str
        |> Result.toMaybe
        |> Maybe.map Id


{-| Pre-defined chat IDs for testing
-}
chatId1 : Id ChatId
chatId1 =
    Id (UUID.forName "chat1" UUID.dnsNamespace)


chatId2 : Id ChatId
chatId2 =
    Id (UUID.forName "chat2" UUID.dnsNamespace)


chatId3 : Id ChatId
chatId3 =
    Id (UUID.forName "chat3" UUID.dnsNamespace)


{-| Pre-defined document IDs for testing
-}
docId1 : Id DocumentId
docId1 =
    Id (UUID.forName "doc1" UUID.dnsNamespace)


docId2 : Id DocumentId
docId2 =
    Id (UUID.forName "doc2" UUID.dnsNamespace)


docId3 : Id DocumentId
docId3 =
    Id (UUID.forName "doc3" UUID.dnsNamespace)
