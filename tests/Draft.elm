module Draft exposing (..)

import Expect
import Fuzz
import Helpers exposing (testFn)
import Result.Extra
import Sqids
import Sqids.Context exposing (Context)
import Test exposing (Test, describe)


abc : Test
abc =
    let
        encodes =
            testFn <| Sqids.encodeWith abcContext
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
        [ testFn Sqids.encode [ 0 ] (Ok "bM")
        , testFn Sqids.encode [ 0, 1, 2 ] (Ok "rSCtlB")
        ]


testEncodeWithTitle : String -> List Int -> Result Sqids.EncodeError String -> Test
testEncodeWithTitle title input expected =
    Test.test title <|
        \() ->
            Sqids.encode input |> Expect.equal expected


singleIntFuzz : Test
singleIntFuzz =
    Test.fuzz (Fuzz.intAtLeast 0) "roundtrip tests" <|
        \int ->
            let
                context =
                    Sqids.Context.new
                        -- fuzzing tests with the block list is very slow
                        |> Sqids.Context.withBlockList []
                        |> Sqids.Context.build
                        |> Result.Extra.extract (Debug.todo << Debug.toString)

                numbers =
                    [ int ]
            in
            Sqids.encodeWith context numbers
                |> Result.Extra.extract (Debug.todo << Debug.toString)
                |> Sqids.decodeWith context
                |> Expect.equal numbers
