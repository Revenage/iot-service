module Api.Endpoint exposing (Endpoint, me)
import Url.Builder exposing (..)

-- TYPES


{-| Get a URL to the Conduit API.
This is not publicly exposed, because we want to make sure the only way to get one of these URLs is from this module.
-}
type Endpoint
    = Endpoint String


unwrap : Endpoint -> String
unwrap (Endpoint str) =
    str


url : String -> List String -> Endpoint
url host paths =
    -- NOTE: Url.Builder takes care of percent-encoding special URL characters.
    -- See https://package.elm-lang.org/packages/elm/url/latest/Url#percentEncode
    crossOrigin
        host
        ("api" :: paths)
        []
        |> Endpoint



-- ENDPOINTS



-- login : Endpoint
-- login =
--     url [ "users", "login" ] []

me : String -> Endpoint
me host =
    url host [ "users", "auth", "me" ]

-- user : Endpoint
-- user =
--     url [ "user" ] []


-- users : Endpoint
-- users =
--     url [ "users" ] []

