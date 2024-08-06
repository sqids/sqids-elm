module Sqids.Context exposing
    ( Context
    , default, from, ContextBuilder
    , defaultAlphabet, defaultBlockList
    , new, withAlphabet, withMinLength, withBlockList, build
    , Error(..), errorToString
    , getAlphabet, getMinLength, containsBlockedWord
    )

{-| The context contains the chosen base alphabet, the minimum length of all generated ids, and a list of blocked words.

@docs Context


# Creating a new context

@docs default, from, ContextBuilder

Useful for this could be the

@docs defaultAlphabet, defaultBlockList

An alternative to passing all values would be the builder pattern, where you only pass values that you want to override.


## Building a new context

You start with [new](#new), and only need to change the default values that you want.
In the end you [build](#build) the [Context](#Context), which might return an [Error](#Error).

Fore example:

    Sqids.Context.new
        |> Sqids.Context.withAlphabet "abc123"
        |> Sqids.Context.withMinLength 1
        |> Sqids.Context.withBlockList [ "block", "disallowed" ]
        |> Sqids.Context.build

@docs new, withAlphabet, withMinLength, withBlockList, build


## Context creation errors

@docs Error, errorToString


# To retrieve information from a [Context](#Context)

@docs getAlphabet, getMinLength, containsBlockedWord

-}

import Array exposing (Array)
import Set exposing (Set)
import Shuffle
import Sqids.BlockList


{-| The context contains
the chosen [alphabet](#getAlphabet),
the [minimum length](#getMinLength) of all generated ids,
and a list of [blocked words](#containsBlockedWord).
-}
type Context
    = Context
        { alphabet : Array Char
        , minLength : Int
        , blockList : List String
        }


{-| Same [Context](#Context) as created from

    Sqids.Context.from
        { alphabet = Sqids.Context.defaultAlphabet
        , minLength = 0
        , blockList = Sqids.Context.defaultBlockList
        }

or built with

    Sqids.Context.new
        |> Sqids.Context.build

but without the need to handle a [Error](#Error) case.

-}
default : Context
default =
    -- shuffled default alphabet
    { alphabet = "fwjBhEY2uczNPDiloxmvISCrytaJO4d71T0W3qnMZbXVHg6eR8sAQ5KkpLUGF9" |> String.toList |> Array.fromList
    , minLength = 0
    , blockList = Sqids.BlockList.default
    }
        |> Context


{-| abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
-}
defaultAlphabet : String
defaultAlphabet =
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"


{-| Re-exports [Sqids.BlockList.default](./Sqids-BlockList#default) for convenience.
-}
defaultBlockList : List String
defaultBlockList =
    Sqids.BlockList.default


{-| Returns the chosen alphabet
-}
getAlphabet : Context -> Array Char
getAlphabet (Context { alphabet }) =
    alphabet


{-| Returns the minimum length of every generated id.
-}
getMinLength : Context -> Int
getMinLength (Context { minLength }) =
    minLength


{-| Construct a Context by passing all options, might return an [Error](#Error).
Alternative to using [the builder pattern](#building-a-new-context).
-}
from : ContextBuilder -> Result Error Context
from { alphabet, minLength, blockList } =
    new
        |> withAlphabet alphabet
        |> withMinLength minLength
        |> withBlockList blockList
        |> build



-- BUILDER


{-| Used to construct or build a [Context](#Context)
-}
type alias ContextBuilder =
    { alphabet : String
    , minLength : Int
    , blockList : List String
    }


{-| Starts with the default values for alphabet, minimum length and block list.
-}
new : ContextBuilder
new =
    { alphabet = defaultAlphabet
    , minLength = 0
    , blockList = defaultBlockList
    }


{-| Replaces the alphabet.
-}
withAlphabet : String -> ContextBuilder -> ContextBuilder
withAlphabet alphabet builder =
    { builder | alphabet = alphabet }


{-| Sets the desired minimum length of every generated id.
-}
withMinLength : Int -> ContextBuilder -> ContextBuilder
withMinLength length builder =
    { builder | minLength = length }


{-| Sets the list of blocked strings that must not occur in a generated id.
-}
withBlockList : List String -> ContextBuilder -> ContextBuilder
withBlockList blockList builder =
    { builder | blockList = blockList }


{-| Creating or building a new context might fail with an error if invalid configuration parameters are passed.
-}
type Error
    = AlphabetTooShort
    | AlphabetContainsMultibyteChar Char
    | AlphabetContainsDuplicateChar Char
    | MinLengthInvalid Int
    | BlockedWordNeedsAtLeastThreeChars String
    | BlockedWordMustBeLowercase String


{-| For user feedback, you can generate description texts yourself, or use these English descriptions
-}
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


{-| Verifies that all passed configuration options are valid, and returns either an [Error](#Error) or a valid [Context](#Context).
-}
build : ContextBuilder -> Result Error Context
build { alphabet, minLength, blockList } =
    if minLength < 0 || minLength > 255 then
        MinLengthInvalid minLength |> Err

    else if String.length alphabet < 3 then
        Err AlphabetTooShort

    else
        let
            chars : List Char
            chars =
                alphabet |> String.toList
        in
        findInvalidChar Set.empty chars
            |> Result.andThen (\() -> isValidBlockList blockList)
            |> Result.map
                (\() ->
                    { alphabet = chars |> Array.fromList |> Shuffle.shuffle
                    , minLength = minLength
                    , blockList = filteredBlockList chars blockList
                    }
                        |> Context
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
        abc : Set Char
        abc =
            Set.fromList <| List.map Char.toLower alphabet
    in
    List.filter (\word -> List.all (\char -> Set.member char abc) (String.toList word))


{-| Checks if the given string contains a word on the block list.

Note: The string is converted to lower case.

-}
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
