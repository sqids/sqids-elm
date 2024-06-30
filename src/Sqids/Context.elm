module Sqids.Context exposing
    ( Context
    , Error(..)
    , build
    , containsBlockedWord
    , default
    , defaultAlphabet
    , defaultBlockList
    , errorToString
    , from
    , getAlphabet
    , getMinLength
    , new
    , withAlphabet
    , withBlockList
    , withMinLength
    )

import Array exposing (Array)
import Set exposing (Set)
import Shuffle
import Sqids.BlockList


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
    , blockList = Sqids.BlockList.default
    }
        |> Context


defaultAlphabet : String
defaultAlphabet =
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"


defaultBlockList : List String
defaultBlockList =
    Sqids.BlockList.default


getAlphabet : Context -> Array Char
getAlphabet (Context { alphabet }) =
    alphabet


getMinLength : Context -> Int
getMinLength (Context { minLength }) =
    minLength


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
    | BlockedWordNeedsAtLeastThreeChars String
    | BlockedWordMustBeLowercase String


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

        BlockedWordNeedsAtLeastThreeChars str ->
            "Each word in the block list needs at least three characters, but '" ++ str ++ "' is shorter"

        BlockedWordMustBeLowercase str ->
            "Each word in the block list must only use lower cased characters, but '" ++ str ++ "' does not"


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
        findInvalidChar Set.empty chars
            |> Result.andThen (\() -> isValidBlockList blockList)
            |> Result.andThen
                (\() ->
                    case chars |> Array.fromList |> Shuffle.charArray of
                        Err _ ->
                            Debug.todo "Invalid shuffle algorithm"

                        Ok shuffled ->
                            { alphabet = shuffled
                            , minLength = minLength
                            , blockList = filteredBlockList chars blockList
                            }
                                |> Context
                                |> Ok
                )


findInvalidChar : Set Char -> List Char -> Result Error ()
findInvalidChar known chars =
    case chars of
        [] ->
            Ok ()

        first :: rest ->
            if Char.toCode first >= 0x80 then
                AlphabetContainsMultibyteChar first |> Err

            else if Set.member first known then
                AlphabetContainsDuplicateChar first |> Err

            else
                findInvalidChar (Set.insert first known) rest


isValidBlockList : List String -> Result Error ()
isValidBlockList blockList =
    case blockList of
        [] ->
            Ok ()

        first :: rest ->
            if String.length first < 3 then
                BlockedWordNeedsAtLeastThreeChars first |> Err

            else if String.toLower first /= first then
                BlockedWordMustBeLowercase first |> Err

            else
                isValidBlockList rest


{-| The TS code ignores invalid blocklist words, we return errors instead.

That way no user will insert different upper and lower cased spelling into the block list, accidentally increasing the size.

We only silently drop valid words from the blocklist if they contain characters that are not in the chosen alphabet

This leaves us with the following:

1.  all blocklist words should be lowercase -> Err BlockedWordMustBeLowercase
2.  no words less than 3 chars -> Err BlockedWordNeedsAtLeastThreeChars
3.  if some words contain chars that are not in the alphabet, remove those

-}
filteredBlockList : List Char -> List String -> List String
filteredBlockList alphabet =
    let
        abc =
            Set.fromList <| List.map Char.toLower alphabet
    in
    List.filter (\word -> List.all (\char -> Set.member char abc) (String.toList word))


containsBlockedWord : Context -> String -> Bool
containsBlockedWord (Context { blockList }) id =
    isBlocked (String.toLower id) blockList


isBlocked : String -> List String -> Bool
isBlocked loweredId blockList =
    case blockList of
        [] ->
            False

        first :: rest ->
            if String.length first > String.length loweredId then
                -- no point in checking words that are longer than the ID
                isBlocked loweredId rest

            else if String.length loweredId <= 3 || String.length first <= 3 then
                -- short words have to match completely; otherwise, too many matches
                if loweredId == first then
                    True

                else
                    isBlocked loweredId rest

            else if
                String.startsWith first loweredId
                    || String.endsWith first loweredId
                    || String.contains first loweredId
            then
                True

            else
                isBlocked loweredId rest
