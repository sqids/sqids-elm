module ContextBuilder exposing (..)

{-| Additional tests that don't exist in the official sources
-}

import Expect
import Fuzz
import Sqids.Context
import Test exposing (Test, describe)


minLength : Test
minLength =
    describe "minLength"
        [ Test.test "must not be a negative number" <|
            \() ->
                Sqids.Context.new
                    |> Sqids.Context.withMinLength -1
                    |> Sqids.Context.build
                    |> Expect.equal (Err (Sqids.Context.MinLengthInvalid -1))
        , Test.test "must be at least 0" <|
            \() ->
                Sqids.Context.new
                    |> Sqids.Context.withMinLength 0
                    |> Sqids.Context.build
                    |> Expect.ok
        , Test.test "must be smaller or equal 255" <|
            \() ->
                Sqids.Context.new
                    |> Sqids.Context.withMinLength 255
                    |> Sqids.Context.build
                    |> Expect.ok
        , Test.test "must not be greater than 255" <|
            \() ->
                Sqids.Context.new
                    |> Sqids.Context.withMinLength 256
                    |> Sqids.Context.build
                    |> Expect.equal (Err (Sqids.Context.MinLengthInvalid 256))
        ]


blockList : Test
blockList =
    describe "block list"
        [ Test.fuzz (Fuzz.stringOfLengthBetween 0 2) "must be at least 3 characters" <|
            \str ->
                Sqids.Context.new
                    |> Sqids.Context.withBlockList [ str ]
                    |> Sqids.Context.build
                    |> Expect.equal (Err (Sqids.Context.BlockedWordNeedsAtLeastThreeChars str))
        , Test.test "is ok" <|
            \() ->
                Sqids.Context.new
                    |> Sqids.Context.withBlockList [ "abc" ]
                    |> Sqids.Context.build
                    |> Expect.ok
        , Test.test "must not contain UPPERCASE characters" <|
            \() ->
                Sqids.Context.new
                    |> Sqids.Context.withBlockList [ "abC" ]
                    |> Sqids.Context.build
                    |> Expect.equal (Err (Sqids.Context.BlockedWordMustBeLowercase "abC"))
        ]
