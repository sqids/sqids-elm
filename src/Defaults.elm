module Defaults exposing
    ( Context
    , abc
    , alphabet
    , context
    )

import Array exposing (Array)


type alias Context =
    { alphabet : Array Char, minLength : Int, blockList : List String }


alphabet : String
alphabet =
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"


context : Context
context =
    -- shuffled default alphabet
    { alphabet = "fwjBhEY2uczNPDiloxmvISCrytaJO4d71T0W3qnMZbXVHg6eR8sAQ5KkpLUGF9" |> String.toList |> Array.fromList
    , minLength = 0
    , blockList = []
    }


{-| TODO remove this example context after first tests
-}
abc : Context
abc =
    { alphabet = "abc" |> String.toList |> Array.fromList
    , minLength = 0
    , blockList = []
    }
