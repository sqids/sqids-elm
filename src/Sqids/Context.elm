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
import Html.Attributes exposing (minlength)
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
    | AlphabetContainsDuplicateChar Char
    | MinLengthInvalid Int


errorToString : Error -> String
errorToString err =
    case err of
        AlphabetTooShort ->
            "Alphabet length must be at least 3"

        AlphabetContainsMultibyteChar char ->
            "Alphabet cannot contain multibyte character '" ++ String.fromChar char ++ "'"

        AlphabetContainsDuplicateChar char ->
            "Alphabet must contain only unique characters, but '" ++ String.fromChar char ++ "' is duplicate"

        MinLengthInvalid int ->
            "Minimum length has to be between 0 and 255, but was " ++ String.fromInt int


build : ContextBuilder -> Result Error Context
build { alphabet, minLength, blockList } =
    if minLength < 0 || minLength > 255 then
        MinLengthInvalid minLength |> Err

    else if String.length alphabet < 3 then
        Err AlphabetTooShort

    else
        let
            chars =
                alphabet |> String.toList
        in
        case findInvalidChar Set.empty chars of
            Just err ->
                Err err

            Nothing ->
                case chars |> Array.fromList |> Shuffle.charArray of
                    Err _ ->
                        Debug.todo "Invalid algorithm"

                    Ok shuffled ->
                        { alphabet =
                            shuffled
                        , minLength = minLength
                        , blockList = filteredBlockList chars blockList
                        }
                            |> Context
                            |> Ok


findInvalidChar : Set Char -> List Char -> Maybe Error
findInvalidChar known chars =
    case chars of
        [] ->
            Nothing

        first :: rest ->
            if Char.toCode first >= 0x80 then
                AlphabetContainsMultibyteChar first |> Just

            else if Set.member first known then
                AlphabetContainsDuplicateChar first |> Just

            else
                findInvalidChar (Set.insert first known) rest


{-| TODO

    // clean up blocklist:
    // 1. all blocklist words should be lowercase
    // 2. no words less than 3 chars
    // 3. if some words contain chars that are not in the alphabet, remove those
    const filteredBlocklist = new Set<string>();
    const alphabetChars = alphabet.toLowerCase().split('');
    for (const word of blocklist) {
        if (word.length >= 3) {
            const wordLowercased = word.toLowerCase();
            const wordChars = wordLowercased.split('');
            const intersection = wordChars.filter((c) => alphabetChars.includes(c));
            if (intersection.length == wordChars.length) {
                filteredBlocklist.add(wordLowercased);
            }
        }
    }

-}
filteredBlockList : List Char -> List String -> List String
filteredBlockList alphabet initialBlockList =
    initialBlockList
