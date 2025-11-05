module Backend exposing (..)

import BiSeqDict exposing (BiSeqDict)
import Id exposing (ChatId, DocumentId, Id, chatId1, chatId2, chatId3, docId1, docId2, docId3)
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


generateFakeDocument : Id DocumentId -> String -> Document
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
            [ generateFakeDocument docId1 "meeting-notes"
            , generateFakeDocument docId2 "project-proposal"
            , generateFakeDocument docId3 "budget-2024"
            ]

        chatDocuments =
            MultiBiSeqDict.empty
                |> MultiBiSeqDict.insert chatId1 docId1
                |> MultiBiSeqDict.insert chatId1 docId2
                |> MultiBiSeqDict.insert chatId2 docId1
                |> MultiBiSeqDict.insert chatId2 docId3
    in
    ( { message = "Hello!"
      , chatDocuments = chatDocuments
      , documents = documents
      }
    , Cmd.none
    )


getDocumentsInChat : Id ChatId -> Model -> SeqSet (Id DocumentId)
getDocumentsInChat chatId model =
    MultiBiSeqDict.get chatId model.chatDocuments


getChatsWithDocument : Id DocumentId -> Model -> SeqSet (Id ChatId)
getChatsWithDocument docId model =
    MultiBiSeqDict.getReverse docId model.chatDocuments


transferDocument : Id ChatId -> Id ChatId -> Id DocumentId -> Model -> Model
transferDocument fromChat toChat docId ({ chatDocuments } as model) =
    { model
        | chatDocuments =
            chatDocuments
                |> MultiBiSeqDict.remove fromChat docId
                |> MultiBiSeqDict.insert toChat docId
    }


shareDocumentWithChat : Id ChatId -> Id DocumentId -> Model -> Model
shareDocumentWithChat chatId docId ({ chatDocuments } as model) =
    { model
        | chatDocuments = MultiBiSeqDict.insert chatId docId chatDocuments
    }


removeDocumentFromChat : Id ChatId -> Id DocumentId -> Model -> Model
removeDocumentFromChat chatId docId ({ chatDocuments } as model) =
    { model
        | chatDocuments = MultiBiSeqDict.remove chatId docId chatDocuments
    }


exampleOperations : Model -> Model
exampleOperations model =
    model
        |> shareDocumentWithChat chatId3 docId2
        |> transferDocument chatId1 chatId3 docId1


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