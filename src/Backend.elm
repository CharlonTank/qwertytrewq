module Backend exposing (..)

import BiSeqDict exposing (BiSeqDict)
import Lamdera exposing (ClientId, SessionId)
import MultiBiSeqDict exposing (MultiBiSeqDict)
import MultiSeqDict exposing (MultiSeqDict)
import SeqDict exposing (SeqDict)
import SeqSet exposing (SeqSet)
import Types exposing (..)


type alias Model =
    BackendModel


type CustomType
    = Foo
    | Bar


testBiSeqDict : BiSeqDict CustomType String
testBiSeqDict =
    BiSeqDict.empty
        |> BiSeqDict.insert Foo "hello"
        |> BiSeqDict.insert Bar "world"


chat1 : ChatId
chat1 =
    ChatId never


chat2 : ChatId
chat2 =
    ChatId never


chat3 : ChatId
chat3 =
    ChatId never


doc1 : DocumentId
doc1 =
    DocumentId never


doc2 : DocumentId
doc2 =
    DocumentId never


doc3 : DocumentId
doc3 =
    DocumentId never


generateFakeDocument : DocumentId -> String -> Document
generateFakeDocument id name =
    { id = id
    , name = name
    , s3Url = "https://fake-s3-bucket.s3.amazonaws.com/documents/" ++ name ++ ".pdf"
    }


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Sub.none
        }


init : ( Model, Cmd BackendMsg )
init =
    let
        documents =
            [ generateFakeDocument doc1 "meeting-notes"
            , generateFakeDocument doc2 "project-proposal"
            , generateFakeDocument doc3 "budget-2024"
            ]

        chatDocuments =
            MultiBiSeqDict.empty
                |> MultiBiSeqDict.insert chat1 doc1
                |> MultiBiSeqDict.insert chat1 doc2
                |> MultiBiSeqDict.insert chat2 doc1
                |> MultiBiSeqDict.insert chat2 doc3
    in
    ( { message = "Hello!"
      , chatDocuments = chatDocuments
      , documents = documents
      }
    , Cmd.none
    )


getDocumentsInChat : ChatId -> Model -> SeqSet DocumentId
getDocumentsInChat chatId model =
    MultiBiSeqDict.get chatId model.chatDocuments


getChatsWithDocument : DocumentId -> Model -> SeqSet ChatId
getChatsWithDocument docId model =
    MultiBiSeqDict.getReverse docId model.chatDocuments


transferDocument : ChatId -> ChatId -> DocumentId -> Model -> Model
transferDocument fromChat toChat docId ({ chatDocuments } as model) =
    { model
        | chatDocuments =
            chatDocuments
                |> MultiBiSeqDict.remove fromChat docId
                |> MultiBiSeqDict.insert toChat docId
    }


shareDocumentWithChat : ChatId -> DocumentId -> Model -> Model
shareDocumentWithChat chatId docId ({ chatDocuments } as model) =
    { model
        | chatDocuments = MultiBiSeqDict.insert chatId docId chatDocuments
    }


removeDocumentFromChat : ChatId -> DocumentId -> Model -> Model
removeDocumentFromChat chatId docId ({ chatDocuments } as model) =
    { model
        | chatDocuments = MultiBiSeqDict.remove chatId docId chatDocuments
    }


exampleOperations : Model -> Model
exampleOperations model =
    model
        |> shareDocumentWithChat chat3 doc2
        |> transferDocument chat1 chat3 doc1


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        NoOpToBackend ->
            ( model, Cmd.none )