module Main exposing (Model, Msg(..), init, main)

import Decoders exposing (..)
import Pages.NotFound as NotFound
import Pages.Guest as Guest
import Pages.Dashboard as Dashboard
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
    }


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | MsgNotFound NotFound.Msg
    | MsgGuest Guest.Msg
    | MsgDashboard Dashboard.Msg
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
    in
    ( { key = key
      , url = url
      , route = route
      , language = English
      , translation = TranslateLoading
      , session = Unauthorised
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
                    ( { model | translation = TranslateSuccess translation }, Cmd.none )

                Err _ ->
                    
                    ( { model | translation = TranslateFailure }, Cmd.none )

        HandleCheckMeResponse result ->
            case result of
                Ok user ->
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
             
    --       Html.form [ class "form-signin" ]
    -- [ div [ class "text-center mb-4" ]
    --     [ img [ alt "", class "mb-4", attribute "height" "72", src "/docs/4.3/assets/brand/bootstrap-solid.svg", attribute "width" "72" ]
    --         []
    --     , h1 [ class "h3 mb-3 font-weight-normal" ]
    --         [ text "Floating labels" ]
    --     , p []
    --         [ text "Build form controls with floating labels via the "
    --         , code []
    --             [ text ":placeholder-shown" ]
    --         , text "pseudo-element. "
    --         , a [ href "https://caniuse.com/#feat=css-placeholder-shown" ]
    --             [ text "Works in latest Chrome, Safari, and Firefox." ]
    --         ]
    --     ]
    -- , div [ class "form-label-group" ]
    --     [ input [ attribute "autofocus" "", class "form-control", id "inputEmail", placeholder "Email address", attribute "required" "", type_ "email" ]
    --         []
    --     , label [ for "inputEmail" ]
    --         [ text "Email address" ]
    --     ]
    -- , div [ class "form-label-group" ]
    --     [ input [ class "form-control", id "inputPassword", placeholder "Password", attribute "required" "", type_ "password" ]
    --         []
    --     , label [ for "inputPassword" ]
    --         [ text "Password" ]
    --     ]
    -- -- , div [ class "checkbox mb-3" ]
    -- --     [ label []
    -- --         [ input [ type_ "checkbox", value "remember-me" ]
    -- --             []
    -- --         , text "Remember me"
    -- --         ]
    -- --     ]
    -- , button [ class "btn btn-lg btn-primary btn-block", type_ "submit" ]
    --     [ text "Sign in" ]
    -- ]