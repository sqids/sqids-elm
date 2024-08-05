module BlockList exposing (..)

{-| Same tests as in <https://github.com/sqids/sqids-spec/blob/40f407169fa0f555b93a197ff0a9e974efa9fba6/tests/blocklist.test.ts>
-}

import Expect
import Helpers
import Result.Extra
import Sqids
import Sqids.Context exposing (Context, withBlockList)
import Test exposing (Test, describe)


defaultBlockList : Test
defaultBlockList =
    describe "if no custom blocklist param, use the default blocklist"
        [ Helpers.testFn Sqids.decode "aho1e" [ 4572721 ]
        , Helpers.testFn Sqids.encode [ 4572721 ] (Ok "JExTR")
        ]


emptyBlockList : Test
emptyBlockList =
    let
        context =
            withBlockList []
    in
    describe "if an empty blocklist param passed, don't use any blocklist"
        [ Helpers.testEncoderAndDecoderWith context [ 4572721 ] "aho1e"
        ]


singleBlockedWord : Test
singleBlockedWord =
    let
        context =
            -- originally encoded [100000]
            [ "ArUO" ] |> withBlockList
    in
    describe "if a non-empty blocklist param passed, use only that"
        [ describe "does not use the default blocklist"
            [ Helpers.testEncoderAndDecoderWith context [ 4572721 ] "aho1e"
            ]
        , describe "uses the passed blocklist"
            [ Helpers.testFn (Sqids.decodeWith context) "ArUO" [ 100000 ]
            , Helpers.testFn (Sqids.encodeWith context) [ 100000 ] (Ok "QyG4")
            , Helpers.testFn (Sqids.decodeWith context) "QyG4" [ 100000 ]
            ]
        ]


blockList : Test
blockList =
    let
        context =
            [ -- normal result of 1st encoding, let's block that word on purpose
              "JSwXFaosAN"
            , -- result of 2nd encoding
              "OCjV9JK64o"
            , -- result of 3rd encoding is `4rBHfOiqd3`, let's block a substring
              "rBHf"
            , -- result of 4th encoding is `dyhgw479SM`, let's block the postfix
              "79SM"
            , -- result of 5th encoding is `7tE6jdAHLe`, let's block the prefix
              "7tE6"
            ]
                |> withBlockList
    in
    Helpers.testEncoderAndDecoderWith context [ 1000000, 2000000 ] "1aYeB7bRUt"


decodeBlockedWords : Test
decodeBlockedWords =
    let
        context =
            [ "86Rf07", "se8ojk", "ARsz1p", "Q8AI49", "5sQRZO" ]
                |> withBlockList

        numbers =
            [ 1, 2, 3 ]
    in
    describe "decoding blocklist words should still work"
        [ Helpers.testFn (Sqids.decodeWith context) "86Rf07" numbers
        , Helpers.testFn (Sqids.decodeWith context) "se8ojk" numbers
        , Helpers.testFn (Sqids.decodeWith context) "ARsz1p" numbers
        , Helpers.testFn (Sqids.decodeWith context) "Q8AI49" numbers
        , Helpers.testFn (Sqids.decodeWith context) "5sQRZO" numbers
        ]


matchShortBlockedWord : Test
matchShortBlockedWord =
    Helpers.testRoundTrip "match against a short blocklist word"
        (withBlockList [ "pnd" ])
        [ 1000 ]


matchToBlockListAsLowerCase : Test
matchToBlockListAsLowerCase =
    let
        blocks words =
            Sqids.Context.new
                |> Sqids.Context.withAlphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                |> Sqids.Context.withBlockList words
                |> build

        numbers =
            [ 1, 2, 3 ]
    in
    describe "blocklist filtering in constructor"
        [ Helpers.testFn
            (Sqids.encodeWith (blocks []))
            numbers
            (Ok "SXNZKL")
        , Helpers.testFn
            -- lowercase blocklist in only-uppercase alphabet
            (Sqids.encodeWith (blocks [ "sxnzkl" ]))
            numbers
            (Ok "IBSHOZ")
        ]


maxRegenerateAttempts : Test
maxRegenerateAttempts =
    Test.test "max encoding attempts" <|
        \() ->
            let
                context =
                    { alphabet = "abc"
                    , minLength = 3
                    , blockList = [ "cab", "abc", "bca" ]
                    }
                        |> build
            in
            Sqids.encodeWith context [ 0 ]
                |> Expect.equal (Err Sqids.MaxRegenerateAttempts)


withBlockList : List String -> Context
withBlockList words =
    Sqids.Context.new
        |> Sqids.Context.withBlockList (List.map String.toLower words)
        |> build


build : Sqids.Context.ContextBuilder -> Context
build =
    Result.Extra.extract (Debug.todo << Debug.toString) << Sqids.Context.build
