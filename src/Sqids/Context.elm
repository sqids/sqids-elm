module Sqids.Context exposing
    ( Context
    , Error(..)
    , allInAlphabet
    , build
    , default
    , defaultAlphabet
    , errorToString
    , from
    , getAlphabet
    , new
    , withAlphabet
    , withBlockList
    , withMinLength
    )

import Array exposing (Array)
import Set exposing (Set)
import Shuffle


type Context
    = Context
        { alphabet : Array Char
        , minLength : Int
        , blockList : List String
        }


default : Context
default =
    -- shuffled default alphabet
    { alphabet = "fwjBhEY2uczNPDiloxmvISCrytaJO4d71T0W3qnMZbXVHg6eR8sAQ5KkpLUGF9" |> String.toList |> Array.fromList
    , minLength = 0
    , blockList = [] -- TODO
    }
        |> Context


defaultAlphabet : String
defaultAlphabet =
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"


allInAlphabet : Context -> String -> Bool
allInAlphabet (Context { alphabet }) string =
    let
        alphabetSet : Set Char
        alphabetSet =
            Set.fromList <| Array.toList alphabet

        isInAlphabet : Char -> Bool
        isInAlphabet char =
            Set.member char alphabetSet
    in
    List.all isInAlphabet (String.toList string)


getAlphabet : Context -> Array Char
getAlphabet (Context { alphabet }) =
    alphabet


{-| Construct a Context by passing all options.

Alternative to using the builder pattern starting `new`.

-}
from : ContextBuilder -> Result Error Context
from { alphabet, minLength, blockList } =
    new
        |> withAlphabet alphabet
        |> withMinLength minLength
        |> withBlockList blockList
        |> build



-- BUILDER


type alias ContextBuilder =
    { alphabet : String
    , minLength : Int
    , blockList : List String
    }


new : ContextBuilder
new =
    { alphabet = defaultAlphabet
    , minLength = 0
    , blockList = []
    }


withAlphabet : String -> ContextBuilder -> ContextBuilder
withAlphabet alphabet builder =
    { builder | alphabet = alphabet }


withMinLength : Int -> ContextBuilder -> ContextBuilder
withMinLength length builder =
    { builder | minLength = length }


withBlockList : List String -> ContextBuilder -> ContextBuilder
withBlockList blockList builder =
    { builder | blockList = blockList }


type Error
    = AlphabetTooShort
    | AlphabetContainsMultibyteChar Char


errorToString : Error -> String
errorToString err =
    case err of
        AlphabetTooShort ->
            "Alphabet length must be at least 3"

        AlphabetContainsMultibyteChar char ->
            "Alphabet cannot contain multibyte character '" ++ String.fromChar char ++ "'"


build : ContextBuilder -> Result Error Context
build { alphabet, minLength, blockList } =
    if String.length alphabet < 3 then
        Err AlphabetTooShort

    else
        let
            chars =
                alphabet |> String.toList
        in
        case containsInvalidChar chars of
            Just char ->
                AlphabetContainsMultibyteChar char |> Err

            Nothing ->
                case chars |> Array.fromList |> Shuffle.charArray of
                    Err _ ->
                        Debug.todo "Invalid algorithm"

                    Ok shuffled ->
                        { alphabet = shuffled
                        , minLength = minLength
                        , blockList = blockList -- TODO
                        }
                            |> Context
                            |> Ok


containsInvalidChar : List Char -> Maybe Char
containsInvalidChar chars =
    case chars of
        [] ->
            Nothing

        first :: rest ->
            if Debug.log "code" (Char.toCode (Debug.log "char" first)) < 0x80 then
                containsInvalidChar rest

            else
                Just first
