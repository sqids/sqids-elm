module Draft exposing (..)

import Array exposing (Array)
import Array.Extra
import Defaults exposing (Context)
import Expect
import Helpers exposing (testFn)
import Html.Attributes exposing (value)
import List.Extra
import Result.Extra
import Shuffle
import Sqids
import Sqids.Context
import Test exposing (Test, describe)


abc : Test
abc =
    let
        encodes =
            testFn <| Sqids.encodeListWith abcContext
    in
    describe "Encode with short alphabet 'abc'"
        [ encodes [ 0 ] (Ok "ca")
        , encodes [ 0, 1, 2 ] (Ok "abcabac")
        ]


{-| TODO remove this example context after encode and decode work
-}
abcContext : Context
abcContext =
    Sqids.Context.new
        |> Sqids.Context.withAlphabet "abc"
        |> Sqids.Context.build
        |> Result.Extra.extract (Debug.todo << Debug.toString)


defaultAlphabet : Test
defaultAlphabet =
    describe "Encode with default alphabet"
        [ testFn Sqids.encodeList [ 0 ] (Ok "bM")
        , testFn Sqids.encodeList [ 0, 1, 2 ] (Ok "rSCtlB")
        ]


testEncodeWithTitle : String -> List Int -> Result Sqids.EncodeError String -> Test
testEncodeWithTitle title input expected =
    Test.test title <|
        \() ->
            Sqids.encodeList input |> Expect.equal expected


testToId : Test
testToId =
    [ Sqids.toId 1 (Array.fromList [ 'a', 'b', 'c' ]) |> Expect.equal "b"
    , Sqids.toId 13 ("abcde" |> String.toList |> Array.fromList) |> Expect.equal "cd"
    ]
        |> List.indexedMap (\index expectation -> Test.test (String.fromInt index ++ ":") <| \() -> expectation)
        |> Test.concat
