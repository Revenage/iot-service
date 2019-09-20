module Decoders exposing (decodeTranslations, decodeMe, decodeConfig, decodeInitialData)

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

decodeConfig : Decoder Config
decodeConfig =
    map Config
        (field "host" string)

decodeInitialData : Decoder InitialData
decodeInitialData =
    map2 InitialData
            (field "token" (nullable string))
            (field "config" decodeConfig)
            

                    