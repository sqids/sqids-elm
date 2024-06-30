module MinLength exposing (..)

{-| Same tests as in <https://github.com/sqids/sqids-spec/blob/40f407169fa0f555b93a197ff0a9e974efa9fba6/tests/minlength.test.ts>
-}

import Expect
import Helpers
import Result.Extra
import Sqids
import Sqids.Context exposing (Context)
import Test exposing (Test, describe)


defaultAlphabetLength : Int
defaultAlphabetLength =
    String.length Sqids.Context.defaultAlphabet


simple : Test
simple =
    describe "simple MinLength test"
        [ Helpers.testEncoderAndDecoderWith
            (contextWithMinLength <| defaultAlphabetLength)
            [ 1, 2, 3 ]
            "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTM"
        ]


incremental : Test
incremental =
    describe "incremental" <|
        ([ ( 6, "86Rf07" )
         , ( 7, "86Rf07x" )
         , ( 8, "86Rf07xd" )
         , ( 9, "86Rf07xd4" )
         , ( 10, "86Rf07xd4z" )
         , ( 11, "86Rf07xd4zB" )
         , ( 12, "86Rf07xd4zBm" )
         , ( 13, "86Rf07xd4zBmi" )
         , ( defaultAlphabetLength + 0, "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTM" )
         , ( defaultAlphabetLength + 1, "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMy" )
         , ( defaultAlphabetLength + 2, "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMyf" )
         , ( defaultAlphabetLength + 3, "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMyf1" )
         ]
            |> List.map
                (\( minLength, output ) ->
                    Helpers.testEncoderAndDecoderWith
                        (contextWithMinLength minLength)
                        [ 1, 2, 3 ]
                        output
                )
        )


incrementalNumbers : Test
incrementalNumbers =
    describe "incremental numbers with a minimal length requirement"
        ([ ( "SvIzsqYMyQwI3GWgJAe17URxX8V924Co0DaTZLtFjHriEn5bPhcSkfmvOslpBu", [ 0, 0 ] )
         , ( "n3qafPOLKdfHpuNw3M61r95svbeJGk7aAEgYn4WlSjXURmF8IDqZBy0CT2VxQc", [ 0, 1 ] )
         , ( "tryFJbWcFMiYPg8sASm51uIV93GXTnvRzyfLleh06CpodJD42B7OraKtkQNxUZ", [ 0, 2 ] )
         , ( "eg6ql0A3XmvPoCzMlB6DraNGcWSIy5VR8iYup2Qk4tjZFKe1hbwfgHdUTsnLqE", [ 0, 3 ] )
         , ( "rSCFlp0rB2inEljaRdxKt7FkIbODSf8wYgTsZM1HL9JzN35cyoqueUvVWCm4hX", [ 0, 4 ] )
         , ( "sR8xjC8WQkOwo74PnglH1YFdTI0eaf56RGVSitzbjuZ3shNUXBrqLxEJyAmKv2", [ 0, 5 ] )
         , ( "uY2MYFqCLpgx5XQcjdtZK286AwWV7IBGEfuS9yTmbJvkzoUPeYRHr4iDs3naN0", [ 0, 6 ] )
         , ( "74dID7X28VLQhBlnGmjZrec5wTA1fqpWtK4YkaoEIM9SRNiC3gUJH0OFvsPDdy", [ 0, 7 ] )
         , ( "30WXpesPhgKiEI5RHTY7xbB1GnytJvXOl2p0AcUjdF6waZDo9Qk8VLzMuWrqCS", [ 0, 8 ] )
         , ( "moxr3HqLAK0GsTND6jowfZz3SUx7cQ8aC54Pl1RbIvFXmEJuBMYVeW9yrdOtin", [ 0, 9 ] )
         ]
            |> List.map
                (\( output, input ) ->
                    Helpers.testEncoderAndDecoderWith
                        (contextWithMinLength <| defaultAlphabetLength)
                        input
                        output
                )
        )


minLengths : Test
minLengths =
    let
        test : Int -> List Int -> Test
        test minLength numbers =
            let
                context =
                    contextWithMinLength minLength

                id =
                    Sqids.encodeListWith context numbers
                        |> Result.Extra.extract (Debug.todo << Debug.toString)
            in
            describe ("encoding and decoding numbers" ++ Debug.toString numbers)
                [ Test.test "The id has the desired minimum length" <|
                    \() ->
                        String.length id
                            |> Expect.atLeast minLength
                , Helpers.testFn (Sqids.decodeWith context) id numbers
                    |> Test.skip
                ]
    in
    describe "min lengths" <|
        ([ 0, 1, 5, 10, defaultAlphabetLength ]
            |> List.map
                (\minLength ->
                    describe ("When requiring a minimum length of " ++ String.fromInt minLength)
                        (List.map (test minLength)
                            [ [ 0 ]
                            , [ 0, 0, 0, 0, 0 ]
                            , [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
                            , [ 100, 200, 300 ]
                            , [ 1000, 2000, 3000 ]
                            , [ 1000000 ]
                            , [ Sqids.maxSafeInt ]
                            ]
                        )
                )
        )


invalidMinLength : Test
invalidMinLength =
    describe "out-of-range invalid min length"
        [ Test.test "rejects negative numbers" <|
            \() ->
                Sqids.Context.new
                    |> Sqids.Context.withMinLength -1
                    |> Sqids.Context.build
                    |> Expect.equal (Err (Sqids.Context.MinLengthInvalid -1))
        , Test.test "rejects numbers greater than 255" <|
            \() ->
                Sqids.Context.new
                    |> Sqids.Context.withMinLength 256
                    |> Sqids.Context.build
                    |> Expect.equal (Err (Sqids.Context.MinLengthInvalid 256))
        ]



-- HELPERS


contextWithMinLength : Int -> Context
contextWithMinLength minLength =
    Sqids.Context.new
        |> Sqids.Context.withMinLength minLength
        |> Sqids.Context.build
        |> Result.Extra.extract (Debug.todo << Debug.toString)
