module Encoding exposing (..)

{-| Same tests as in <https://github.com/sqids/sqids-spec/blob/40f407169fa0f555b93a197ff0a9e974efa9fba6/tests/encoding.test.ts>
-}

import Draft as Sqids exposing (testFn)
import Expect
import Test exposing (Test, describe)


simple : Test
simple =
    describe "simple encoding test"
        [ roundTripTest [ 1, 2, 3 ] "86Rf07" ]


{-| TODO

    test('different inputs', () => {
        const sqids = new Sqids();

        const numbers = [0, 0, 0, 1, 2, 3, 100, 1_000, 100_000, 1_000_000, Number.MAX_SAFE_INTEGER];
        expect.soft(sqids.decode(sqids.encode(numbers))).toEqual(numbers);
    });

-}
differentInputs : Test
differentInputs =
    Test.todo "needs decode"


incrementalNumbers : Test
incrementalNumbers =
    roundTripTests "incremental numbers"
        [ ( "bM", [ 0 ] )
        , ( "Uk", [ 1 ] )
        , ( "gb", [ 2 ] )
        , ( "Ef", [ 3 ] )
        , ( "Vq", [ 4 ] )
        , ( "uw", [ 5 ] )
        , ( "OI", [ 6 ] )
        , ( "AX", [ 7 ] )
        , ( "p6", [ 8 ] )
        , ( "nJ", [ 9 ] )
        ]


incrementalNumbersSameIndex0 : Test
incrementalNumbersSameIndex0 =
    roundTripTests "incremental numbers, same index 0"
        [ ( "SvIz", [ 0, 0 ] )
        , ( "n3qa", [ 0, 1 ] )
        , ( "tryF", [ 0, 2 ] )
        , ( "eg6q", [ 0, 3 ] )
        , ( "rSCF", [ 0, 4 ] )
        , ( "sR8x", [ 0, 5 ] )
        , ( "uY2M", [ 0, 6 ] )
        , ( "74dI", [ 0, 7 ] )
        , ( "30WX", [ 0, 8 ] )
        , ( "moxr", [ 0, 9 ] )
        ]


incrementalNumbersSameIndex1 : Test
incrementalNumbersSameIndex1 =
    roundTripTests "incremental numbers, same index 1"
        [ ( "SvIz", [ 0, 0 ] )
        , ( "nWqP", [ 1, 0 ] )
        , ( "tSyw", [ 2, 0 ] )
        , ( "eX68", [ 3, 0 ] )
        , ( "rxCY", [ 4, 0 ] )
        , ( "sV8a", [ 5, 0 ] )
        , ( "uf2K", [ 6, 0 ] )
        , ( "7Cdk", [ 7, 0 ] )
        , ( "3aWP", [ 8, 0 ] )
        , ( "m2xn", [ 9, 0 ] )
        ]


{-| TODO

    test('multi input', () => {
        const sqids = new Sqids();

        const numbers = [
            0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,
            26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
            50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73,
            74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97,
            98, 99
        ];
        const output = sqids.decode(sqids.encode(numbers));
        expect.soft(numbers).toEqual(output);
    });

-}
multiInput : Test
multiInput =
    Test.todo "Needs a fully working decode"


encodingNoNumbers : Test
encodingNoNumbers =
    Test.test "encoding no numbers" <|
        \() -> Sqids.encodeList [] |> Expect.equal (Ok "")


decodingEmptyString : Test
decodingEmptyString =
    Test.test "decoding empty string" <|
        \() -> Sqids.decode "" |> Expect.equal []


decodeCharacterNotInAlphabet : Test
decodeCharacterNotInAlphabet =
    Test.test "decoding an ID with an invalid character" <|
        \() -> Sqids.decode "*" |> Expect.equal []


encodeOutOfRange : Test
encodeOutOfRange =
    describe "encode out-of-range numbers"
        [ testFn Sqids.encodeList
            [ -1 ]
            (Err (Sqids.NegativeNumber -1))
        , testFn Sqids.encodeList
            [ Sqids.maxSafeInt + 1 ]
            (Err (Sqids.TooHighInteger (Sqids.maxSafeInt + 1)))
        ]



-- HELPERS


roundTripTests : String -> List ( String, List Int ) -> Test
roundTripTests title tests =
    describe title <|
        List.map
            (\( id, numbers ) -> roundTripTest numbers id)
            tests


roundTripTest : List Int -> String -> Test
roundTripTest numbers id =
    describe (Debug.toString numbers ++ " <-> " ++ id)
        [ testFn Sqids.encodeList numbers (Ok id)
        , testFn Sqids.decode id numbers
            |> Test.skip
        ]
