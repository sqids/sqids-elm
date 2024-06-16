module Alphabet exposing (..)

{-| Same tests as in <https://github.com/sqids/sqids-spec/blob/40f407169fa0f555b93a197ff0a9e974efa9fba6/tests/alphabet.test.ts>
-}

import Expect
import Helpers
import Result.Extra
import Sqids.Context exposing (Context)
import Test exposing (Test, describe)


simple : Test
simple =
    describe "simple"
        [ Helpers.roundTripTestWith
            (contextWithAlphabet "0123456789abcdef")
            [ 1, 2, 3 ]
            "489158"
        ]


shortAlphabet : Test
shortAlphabet =
    Helpers.roundTripTestWith
        (contextWithAlphabet "abc")
        [ 1, 2, 3 ]
        "aacacbaa"


longAlphabet : Test
longAlphabet =
    Helpers.testEncodeDecode "long alphabet"
        (contextWithAlphabet "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_+|{}[];:'\"/?.>,<`~")
        [ 1, 2, 3 ]
        |> Test.skip


multiByteCharacters : Test
multiByteCharacters =
    Test.test "multibyte characters" <|
        \() ->
            Sqids.Context.new
                |> Sqids.Context.withAlphabet "ë1092"
                |> Sqids.Context.build
                |> Expect.equal (Err <| Sqids.Context.AlphabetContainsMultibyteChar 'ë')


repeatingAlphabet : Test
repeatingAlphabet =
    Test.test "repeating alphabet characters" <|
        \() ->
            Sqids.Context.new
                |> Sqids.Context.withAlphabet "aabcdefg"
                |> Sqids.Context.build
                |> Expect.equal (Err <| Sqids.Context.AlphabetContainsDuplicateChar 'a')


tooShort : Test
tooShort =
    Test.test "too short of an alphabet" <|
        \() ->
            Sqids.Context.new
                |> Sqids.Context.withAlphabet "ab"
                |> Sqids.Context.build
                |> Expect.equal (Err Sqids.Context.AlphabetTooShort)



-- HELPERS


contextWithAlphabet : String -> Context
contextWithAlphabet alphabet =
    Sqids.Context.new
        |> Sqids.Context.withAlphabet alphabet
        |> Sqids.Context.build
        |> Result.Extra.extract (Debug.todo << Debug.toString)
