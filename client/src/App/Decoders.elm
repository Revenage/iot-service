module Decoders exposing (decodeTranslations, decodeMe, decodeConfig, decodeInitialData, decodeLoginResponse)

import Types exposing (..)
import Json.Decode exposing (..)


decodeTranslations : Decoder Translation
decodeTranslations =
    dict string

decodeMe : Decoder Me
decodeMe = 
  map3 Me
    (field "id" int)
    (field "username" string)
    (field "email" string)

decodeLoginResponse : Decoder UserData
decodeLoginResponse =
    map4 UserData
            (field "id" int)
            (field "username" string)
            (field "email" string)
            (field "token" string)

decodeConfig : Decoder Config
decodeConfig =
    map2 Config
        (field "host" string)
        (field "defaultLanguage" string)

decodeInitialData : Decoder InitialData
decodeInitialData =
    map2 InitialData
            (field "token" string)
            (field "config" decodeConfig)
                    