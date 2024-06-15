module Alphabet exposing (..)

{- Same tests as in https://github.com/sqids/sqids-spec/blob/40f407169fa0f555b93a197ff0a9e974efa9fba6/tests/alphabet.test.ts

-}

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



-- HELPERS


contextWithAlphabet : String -> Context
contextWithAlphabet alphabet =
    Sqids.Context.new
        |> Sqids.Context.withAlphabet alphabet
        |> Sqids.Context.build
        |> Result.Extra.extract (Debug.todo << Debug.toString)
