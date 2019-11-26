module Types exposing (Translation, Me, UserData, Config, InitialData, Language(..), TranslateStatus(..), Session(..))

-- import Browser
-- import Browser.Navigation as Nav
import Dict exposing (Dict)
-- import Html exposing (Html)

type alias Me = { 
    id : Int,
    username : String,
    email : String
    }

type alias UserData = { 
    id : Int,
    username : String,
    email : String,
    token: String
    }

type alias InitialData = { 
    token: String,
    config: Config
    }

type alias Config = { 
    host: String,
    defaultLanguage: String
    }

type TranslateStatus
    = TranslateFailure
    | TranslateLoading
    | TranslateSuccess Translation


type Language
    = English
    | Russian
    | Ukrainian


type alias Translation =
    Dict String String

type Session
    = LoggedIn
    | Unauthorised

