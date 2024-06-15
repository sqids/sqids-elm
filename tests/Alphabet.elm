module Alphabet exposing (..)

{- Same tests as in https://github.com/sqids/sqids-spec/blob/40f407169fa0f555b93a197ff0a9e974efa9fba6/tests/alphabet.test.ts

-}

import Draft as Sqids exposing (testFn)
import Encoding exposing (roundTripTestWith)
import Expect
import Result.Extra
import Sqids.Context exposing (Context)
import Test exposing (Test, describe)


contextWithAlphabet : String -> Context
contextWithAlphabet alphabet =
    Sqids.Context.new
        |> Sqids.Context.withAlphabet alphabet
        |> Sqids.Context.build
        |> Result.Extra.extract (Debug.todo << Debug.toString)


simple : Test
simple =
    describe "simple"
        [ roundTripTestWith
            (contextWithAlphabet "0123456789abcdef")
            [ 1, 2, 3 ]
            "489158"
        ]


shortAlphabet : Test
shortAlphabet =
    roundTripTestWith
        (contextWithAlphabet "abc")
        [ 1, 2, 3 ]
        "aacacbaa"


longAlphabet : Test
longAlphabet =
    testEncodeDecode "long alphabet"
        (contextWithAlphabet "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_+|{}[];:'\"/?.>,<`~")
        [ 1, 2, 3 ]


{-|

    test('multibyte characters', async () => {
        await expect(
            async () =>
                new Sqids({
                    alphabet: 'ë1092'
                })
        ).rejects.toThrow('Alphabet cannot contain multibyte characters');
    });

-}
multiByteCharacters : Test
multiByteCharacters =
    Test.todo "Reject multibyte characters"


{-|

    test('repeating alphabet characters', async () => {
        await expect(
            async () =>
                new Sqids({
                    alphabet: 'aabcdefg'
                })
        ).rejects.toThrow('Alphabet must contain unique characters');
    });

-}
repeatingAlphabet : Test
repeatingAlphabet =
    Test.todo "Reject repeating characters in alphabet"


{-|

    test('too short of an alphabet', async () => {
        await expect(
            async () =>
                new Sqids({
                    alphabet: 'ab'
                })
        ).rejects.toThrow('Alphabet length must be at least 3');
    });

-}
tooShort : Test
tooShort =
    Test.todo "Reject too short alphabet"


testEncodeDecode : String -> Context -> List Int -> Test
testEncodeDecode title context numbers =
    Test.test title <|
        \() ->
            Sqids.encodeListWith context numbers
                |> Result.Extra.extract (Debug.todo << Debug.toString)
                |> Sqids.decodeWith context
                |> Expect.equal numbers
                |> Test.skip
