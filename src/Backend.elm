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


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Sub.none
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { message = "Hello!" }
    , Cmd.none
    )


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