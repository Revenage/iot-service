
module Router exposing (Route(..), route, toRoute, toPublicRoute)

-- import Page.Guest as Guest
-- import Page.Settings as Settings
-- import Page.NotFound as NotFound

-- import Browser
-- import Browser.Navigation as Nav
-- import Html exposing (..)
-- import Html.Attributes exposing (..)
import Url
import Url.Parser exposing (Parser, map, oneOf, parse, s, top)
-- import Types exposing (..)



type Route
    = Guest
    | Dashboard
    | Login
    | SignUp
    | NotFound


route : Parser (Route -> a) a
route =
    oneOf
        [ Url.Parser.map Dashboard top
        , Url.Parser.map Guest top
        , Url.Parser.map Login (Url.Parser.s "login")
        , Url.Parser.map SignUp (Url.Parser.s "signup")
        , Url.Parser.map NotFound (Url.Parser.s "404")
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