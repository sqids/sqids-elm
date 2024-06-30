module Helpers exposing (..)

import Expect
import Result.Extra
import Sqids
import Sqids.Context exposing (Context)
import Test exposing (Test, describe)


testFn : (input -> output) -> input -> output -> Test
testFn fn input output =
    Test.test ("Input " ++ Debug.toString input ++ " returns " ++ Debug.toString output) <|
        \() -> fn input |> Expect.equal output


testEncoderAndDecoders : String -> List ( String, List Int ) -> Test
testEncoderAndDecoders title tests =
    describe title <|
        List.map
            (\( id, numbers ) -> testEncoderAndDecoder numbers id)
            tests


testEncoderAndDecoder : List Int -> String -> Test
testEncoderAndDecoder =
    testEncoderAndDecoderWith Sqids.Context.default


testEncoderAndDecoderWith : Context -> List Int -> String -> Test
testEncoderAndDecoderWith context numbers id =
    describe (Debug.toString numbers ++ " <-> " ++ id)
        [ testFn (Sqids.encodeListWith context) numbers (Ok id)
        , testFn (Sqids.decodeWith context) id numbers
        ]


testRoundTrip : String -> Context -> List Int -> Test
testRoundTrip title context numbers =
    Test.test title <|
        \() ->
            Sqids.encodeListWith context numbers
                |> Result.Extra.extract (Debug.todo << Debug.toString)
                |> Sqids.decodeWith context
                |> Expect.equal numbers
