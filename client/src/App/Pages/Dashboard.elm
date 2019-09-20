module Pages.Dashboard exposing (Model, Msg(..), init, notFound, subscriptions, update, view)

-- import Helpers.AssetsUrl exposing (assetsUrl)

import Types exposing (..)
import Browser
import Dict exposing (Dict)
import Html exposing (Html, a, div, h1, input, main_, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Services.I18n as I18n exposing (..)


type alias Model =
    { translation : TranslateStatus }


type Msg
    = NoOp


notFound : Program Model Model Msg
notFound =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : Model -> ( Model, Cmd Msg )
init flags =
    ( flags
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model
    , Cmd.none
    )


view : Model -> { title : String, body : List (Html Msg) }
view model =
    let
        trans =
            I18n.get model.translation
    in
    { title = trans "DASHBOARD.TITLE"
    , body =
        [ main_ [ id "content", class "container page404", tabindex -1 ]
            [ div [ class "row" ]
                [ h1 [ class "title" ] [ text (trans "DASHBOARD.TITLE") ]
                ]
            , div [ class "row" ]
                [ div [ class "image404" ] []
                ]
            ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none