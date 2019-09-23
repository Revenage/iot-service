
module Router exposing (Route(..), route, toRoute, toPublicRoute)

-- import Page.Guest as Guest
-- import Page.Settings as Settings
-- import Page.NotFound as NotFound

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Url.Parser exposing ((</>), Parser, map, oneOf, parse, s, string, top)
import Types exposing (..)



type Route
    = Guest
    | Dashboard
    | Login
    | SignUp
    | NotFound


route : Parser (Route -> a) a
route =
    oneOf
        [ map Dashboard top
        , map Guest top
        , map Login (s "login")
        , map SignUp (s "signup")
        , map NotFound (s "404")
        ]


toRoute : Url.Url -> Route
toRoute string =
    case string.path of
        "" ->
            NotFound

        _ ->
            Maybe.withDefault NotFound (parse route string)

toPublicRoute : Route -> Route
toPublicRoute oldRoute =
    case oldRoute of
        Dashboard ->
            Guest
        _ ->
            oldRoute