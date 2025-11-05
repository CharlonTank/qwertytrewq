module Types exposing (..)

import BiSeqDict exposing (BiSeqDict)
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Id exposing (ChatId, DocumentId, Id)
import MultiBiSeqDict exposing (MultiBiSeqDict)
import SeqDict exposing (SeqDict)
import Url exposing (Url)


type alias Document =
    { id : Id DocumentId
    , name : String
    , s3Url : String
    }


type alias FrontendModel =
    { key : Key
    , message : String
    }


type alias BackendModel =
    { message : String
    , chatDocuments : MultiBiSeqDict (Id ChatId) (Id DocumentId)
    , documents : List Document
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend