port module Pages.Login exposing (Model, Msg(..), init, subscriptions, update, view)

-- import Helpers.AssetsUrl exposing (assetsUrl)

import Types exposing (..)
import Browser
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import Services.I18n as I18n exposing (..)
import Http
import Decoders exposing (..)

import Browser.Navigation as Nav
import Url.Builder exposing (crossOrigin)
import Json.Encode as Encode

port localStorage : Encode.Value -> Cmd msg

type alias Form =
    { email : String
    , password : String
    }

type alias Model =
    {   translation : TranslateStatus
        , key: Nav.Key
        , host: String
        , form : Form
    }


type Msg = 
    NoOp
    | SubmittedForm
    | EnteredEmail String
    | EnteredPassword String
    | HandleLoginResponse (Result Http.Error UserData)


login : Program Model Model Msg
login =
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

encodeLogin : Form -> Encode.Value
encodeLogin form =
  Encode.object
      [ ("email", Encode.string form.email)
      , ("password", Encode.string form.password)
      ]

encodeToken : String -> Encode.Value
encodeToken token =
  Encode.object
      [ 
          ("token", Encode.string token)
      ]

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubmittedForm ->
            let adsf = Debug.log "form" model.form in
            ( model
            , Http.post
                    { url = crossOrigin model.host ["api","users","auth", "login"] []
                    , body = model.form |> encodeLogin |> Http.jsonBody
                    , expect = Http.expectJson HandleLoginResponse decodeLoginResponse
                    }
            )

            -- case model.form of
            --     Ok validForm ->
            --         ( { model | problems = [] }
            --         , Cmd.none --Http.send CompletedLogin (login validForm)
            --         )

            --     Err problems ->
            --         ( { model | problems = problems }
            --         , Cmd.none
            --         )

        EnteredEmail email ->
            let 
                oldForm = model.form
                newForm = {oldForm | email = email}
            in
            ( {model | form = newForm}
            , Cmd.none
            )

        EnteredPassword password ->
            let 
                oldForm = model.form
                newForm = {oldForm | password = password}
            in
            ( {model | form = newForm}
            , Cmd.none
            )

        HandleLoginResponse respond ->
            case respond of
                Ok userdata ->
                    let emptyForm = {email = "", password = ""} in
                    ( 
                        { model | form = emptyForm }
                        , Cmd.batch [
                                userdata.token |> encodeToken |> localStorage
                                , Nav.replaceUrl model.key  "/"
                            ]
                    )

                Err _ ->
                    let emptyForm = {email = "", password = ""} in
                    ( { model | form = emptyForm }, Cmd.none )
            
        NoOp ->
            ( model
                , Cmd.none
                )
    


view : Model -> { title : String, body : List (Html Msg) }
view model =
    let
        trans =
            I18n.get model.translation
    in
    { title = trans "LOGIN.TITLE"
    , body =
        [ 
    Html.form [ class "form-signin", onSubmit SubmittedForm, action "javascript:void(0);" ]
    [ div [ class "text-center mb-4" ]
        [ img [ alt "", class "mb-4", attribute "height" "72", src "/docs/4.3/assets/brand/bootstrap-solid.svg", attribute "width" "72" ]
            []
        , h1 [ class "h3 mb-3 font-weight-normal" ]
            [ text "Floating labels" ]
        , p []
            [ text "Build form controls with floating labels via the "
            , code []
                [ text ":placeholder-shown" ]
            , text "pseudo-element. "
            , a [ href "https://caniuse.com/#feat=css-placeholder-shown" ]
                [ text "Works in latest Chrome, Safari, and Firefox." ]
            ]
        ]
    , div [ class "form-label-group" ]
        [ input [ attribute "autofocus" "", class "form-control", id "inputEmail", placeholder "Email address", attribute "required" "", type_ "email", value model.form.email, onInput EnteredEmail  ]
            []
        , label [ for "inputEmail" ]
            [ text "Email address" ]
        ]
    , div [ class "form-label-group" ]
        [ input [ class "form-control", id "inputPassword", placeholder "Password", attribute "required" "", type_ "password", value model.form.password, onInput EnteredPassword ]
            []
        , label [ for "inputPassword" ]
            [ text "Password" ]
        ]
    , button [ class "btn btn-lg btn-primary btn-block", type_ "submit" ] [ text "Sign in" ]
    ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


    