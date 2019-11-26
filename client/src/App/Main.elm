module Main exposing (Model, Msg(..), init, main)

import Decoders exposing (..)
import Pages.NotFound as NotFound
import Pages.Guest as Guest
import Pages.Dashboard as Dashboard
import Pages.Login as Login
import Pages.SignUp as SignUp
import Router exposing (..)
import Types exposing (..)
import Task
import Browser
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Services.I18n as I18n exposing (..)
import Api.Endpoint as Endpoint exposing (me)
import Url
import Url.Parser exposing ((</>), Parser, map, oneOf, parse, s, string, top)
import Url.Builder exposing (crossOrigin)

type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , route : Route
    , language : Language
    , translation : TranslateStatus
    , session: Session
    , login: Login.Model
    }


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | MsgNotFound NotFound.Msg
    | MsgGuest Guest.Msg
    | MsgDashboard Dashboard.Msg
    | MsgLogin Login.Msg
    | MsgSignUp SignUp.Msg
    | HandleTranslateResponse (Result Http.Error Translation)
    | HandleCheckMeResponse (Result Http.Error Me)
    | Back
    | Logout


main : Program InitialData Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


init : InitialData -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init initialData url key =
    let
        route =
            toRoute url
        translation = TranslateLoading
    in
    ( { key = key
      , url = url
      , route = route
      , language = English
      , translation = translation
      , session = Unauthorised
      , login = {
          host = initialData.config.host
          , key = key
          , form = { email = "" , password = ""}
          , translation = translation
      }
      }
    , Cmd.batch [
          initialData |> checkMe 
        , English |> getLangString |> getTranslation
      ]
    )


getTranslation : String -> Cmd Msg
getTranslation lang =
    Http.get
        { url = "/translations/" ++ lang ++ ".json"
        , expect = Http.expectJson HandleTranslateResponse decodeTranslations
        }

checkMe : InitialData -> Cmd Msg
checkMe data =
    let { token, config } = data in
    if String.length token == 0 
    then 
        Task.succeed Logout
            |> Task.perform identity
    else 
    Http.request
      { body = Http.emptyBody
      , expect = Http.expectJson HandleCheckMeResponse decodeMe
      , headers = [ 
        Http.header "Content-Type" "application/json"
        , Http.header "Authorization" ("Bearer " ++ token)
         ]
      , method = "GET"
      , timeout = Nothing
      , tracker = Nothing
      , url = crossOrigin config.host ["api","users","auth", "me"] []
      }
-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgNotFound _ ->
            ( model
            , Cmd.none
            )

        MsgGuest _ ->
            ( model
            , Cmd.none
            )
        MsgDashboard _ ->
            ( model
            , Cmd.none
            )
        MsgLogin subN ->
            let 
                (newLoginModel, loginCmd) = Login.update subN model.login
            in
            ( {model | login = newLoginModel}  
            , Cmd.map MsgLogin loginCmd
            )

        MsgSignUp _ ->
            ( model
            , Cmd.none
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            let
                route =
                    toRoute url
            in
            ( { model | url = url, route = route }
            , Cmd.none
            )

        HandleTranslateResponse result ->
            case result of
                Ok translation ->
                    let 
                        loginModel = model.login
                    in
                    ( { 
                        model | translation = TranslateSuccess translation
                        , login = {
                                loginModel | translation = TranslateSuccess translation
                            }
                        }
                         , Cmd.none )

                Err _ ->
                    
                    ( { model | translation = TranslateFailure }, Cmd.none )

        HandleCheckMeResponse result ->
            case result of
                Ok _ ->
                    ( { model | session = LoggedIn }, Cmd.none )

                Err _ ->
                    ( { model | session = Unauthorised, route = toPublicRoute model.route }, Cmd.none )

        -- ChangeLanguage select ->
        --     let
        --         oldSettings =
        --             model.settings
        --         newSettings =
        --             { oldSettings | language = select }
        --     in
        --     ( { model | settings = newSettings }
        --     , Cmd.batch [ saveSettings newSettings, getTranslation select ]
        --     )
        Back ->
            ( model
            , Nav.back model.key 1
            )

        Logout ->
            ( { model | session = Unauthorised, route = toPublicRoute model.route }, Cmd.none )


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


--VIEW


view : Model -> Browser.Document Msg
view model =
    let
        trans =
            I18n.get model.translation
    in
    case model.translation of
        TranslateLoading ->
            { title = trans "LOADING"
            , body = [ loader ]
            }

        TranslateSuccess _ ->
            let
                viewPage pageview =
                    let
                        { title, content } =
                            pageview model
                    in
                    { title = title
                    , body = [ nav model, content, footer model ]
                    }
            in
            case model.route of
                Guest ->
                    let
                        { title, body } =
                            Guest.view (Guest.Model model.translation)
                    in
                    { title = title
                    , body = List.map (Html.map MsgGuest) body
                    }
                Dashboard ->
                    let
                        { title, body } =
                            Dashboard.view (Dashboard.Model model.translation)
                    in
                    { title = title
                    , body = List.map (Html.map MsgDashboard) body
                    }

                Login ->
                    let
                        { title, body } =
                            Login.view (model.login)
                    in
                    { title = title
                    , body = List.map (Html.map MsgLogin) body
                    }

                SignUp ->
                    let
                        { title, body } =
                            SignUp.view (SignUp.Model model.translation)
                    in
                    { title = title
                    , body = List.map (Html.map MsgSignUp) body
                    }

                NotFound ->
                    let
                        { title, body } =
                            NotFound.view (NotFound.Model model.translation)
                    in
                    { title = title
                    , body = List.map (Html.map MsgNotFound) body
                    }

        TranslateFailure ->
            { title = trans "FAILURE"
            , body = [ loader ]
            }


nav : Model -> Html Msg
nav model =
    let
        trans =
            I18n.get model.translation
    in
    header []
        [ Html.nav [ class "navbar", id "myNavBar" ]
            [ ul [ class "nav" ]
                [ li []
                    [ a [ href "/" ]
                        [ span [] [ text (trans "HOME") ] ]
                    ]
                , li []
                    [ a [ href "/404" ]
                        [ span [] [ text (trans "NOT.FOUND") ] ]
                    ]
                ]
            ]
        ]


footer : Model -> Html Msg
footer model =
    let
        trans =
            I18n.get model.translation
    in
    Html.footer [ class "container" ]
        [ Html.nav []
            [ ul []
                [ li []
                    [ a [ href "/about" ]
                        [ text (trans "ABOUT") ]
                    ]
                , li []
                    [ a [ href "/contact" ]
                        [ text (trans "CONTACT") ]
                    ]
                ]
            ]
        , small [] [ text "Copyright © 2019" ]
        ]


loader =
    div [ class "loader" ] []
