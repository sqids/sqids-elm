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


roundTripTests : String -> List ( String, List Int ) -> Test
roundTripTests title tests =
    describe title <|
        List.map
            (\( id, numbers ) -> roundTripTest numbers id)
            tests


roundTripTest : List Int -> String -> Test
roundTripTest =
    roundTripTestWith Sqids.Context.default


roundTripTestWith : Context -> List Int -> String -> Test
roundTripTestWith context numbers id =
    describe (Debug.toString numbers ++ " <-> " ++ id)
        [ testFn (Sqids.encodeListWith context) numbers (Ok id)
        , testFn (Sqids.decodeWith context) id numbers
        ]


testEncodeDecode : String -> Context -> List Int -> Test
testEncodeDecode title context numbers =
    Test.test title <|
        \() ->
            Sqids.encodeListWith context numbers
                |> Result.Extra.extract (Debug.todo << Debug.toString)
                |> Sqids.decodeWith context
                |> Expect.equal numbers
