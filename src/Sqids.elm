module Sqids exposing
    ( encode, encodeWith, EncodeError(..), encodeErrorToString, maxSafeInt
    , decode, decodeWith, DecodeError(..), decodeErrorToString
    )

{-|


# Encode a list of integers into a string

@docs encode, encodeWith, EncodeError, encodeErrorToString, maxSafeInt


# Decode a string into a list of integers

@docs decode, decodeWith, DecodeError, decodeErrorToString

-}

import Array exposing (Array)
import Array.Extra
import List.Extra
import Set exposing (Set)
import Shuffle
import Sqids.Context exposing (Context)


{-| Possible Error cases when trying to decode a string to integer numbers.

If you want to show these errors to the user, you can use the [encodeErrorToString](#encodeErrorToString) helper.

-}
type DecodeError
    = EmptyString
    | CharacterNotInAlphabet Char


{-| Convenience function to simplify giving feedback to users
-}
decodeErrorToString : DecodeError -> String
decodeErrorToString error =
    case error of
        EmptyString ->
            "An empty string is not allowed"

        CharacterNotInAlphabet char ->
            "The character '" ++ String.fromChar char ++ "' is not in the given alphabet"


{-| Decodes an ID back into a list of unsigned integer numbers using the [default Context](./Sqids-Context#default).
-}
decode : String -> Result DecodeError (List Int)
decode =
    decodeWith Sqids.Context.default


{-| Decodes an ID back into a list of unsigned integer numbers.

The list might be empty if

  - an empty string is passed
  - the string contains a character that is not part of the alphabet

-}
decodeWith : Context -> String -> Result DecodeError (List Int)
decodeWith context id =
    -- TODO add variant that returns an error
    case String.uncons id of
        Nothing ->
            -- string is empty, return an empty list
            Err EmptyString

        -- first character is always the `prefix`
        Just ( prefix_, idWithoutPrefix ) ->
            let
                initialAlphabet : List Char
                initialAlphabet =
                    Sqids.Context.getAlphabet context
                        |> Array.toList

                alphabetSet : Set Char
                alphabetSet =
                    Set.fromList initialAlphabet

                isInAlphabet : Char -> Bool
                isInAlphabet char =
                    Set.member char alphabetSet

                findProperAlphabet : List Char -> DecodeWithLoop -> Result DecodeError (List Char)
                findProperAlphabet chars acc =
                    case ( acc, chars ) of
                        ( SearchForPrefix { prefix }, [] ) ->
                            Err <| CharacterNotInAlphabet prefix

                        ( SearchForPrefix { prefix, beforePrefix }, first :: rest ) ->
                            if isInAlphabet first then
                                if first == prefix then
                                    ValidateAfterPrefix { chunk1 = beforePrefix, chunk2 = [ prefix ] }
                                        |> findProperAlphabet rest

                                else
                                    SearchForPrefix { prefix = prefix, beforePrefix = first :: beforePrefix }
                                        |> findProperAlphabet rest

                            else
                                CharacterNotInAlphabet first |> Err

                        ( ValidateAfterPrefix { chunk1, chunk2 }, [] ) ->
                            Ok (chunk1 ++ chunk2)

                        ( ValidateAfterPrefix { chunk1, chunk2 }, first :: rest ) ->
                            if isInAlphabet first then
                                ValidateAfterPrefix { chunk1 = chunk1, chunk2 = first :: chunk2 }
                                    |> findProperAlphabet rest

                            else
                                Err <| CharacterNotInAlphabet first
            in
            SearchForPrefix { prefix = prefix_, beforePrefix = [] }
                |> findProperAlphabet initialAlphabet
                |> Result.map
                    (\alphabet ->
                        decodeWithAlphabet (Array.fromList alphabet) idWithoutPrefix
                    )


type DecodeWithLoop
    = SearchForPrefix { prefix : Char, beforePrefix : List Char }
    | ValidateAfterPrefix { chunk1 : List Char, chunk2 : List Char }


decodeWithAlphabet : Array Char -> String -> List Int
decodeWithAlphabet alphabet id =
    decodeWithAlphabetHelper [] id alphabet


decodeWithAlphabetHelper : List Int -> String -> Array Char -> List Int
decodeWithAlphabetHelper reversedIdNumbers idString alphabet =
    let
        separator : String
        separator =
            arrayGetInBounds 0 alphabet |> String.fromChar
    in
    --  we need the first part to the left of the separator to decode the number
    case String.split separator idString of
        [] ->
            List.reverse reversedIdNumbers

        "" :: _ ->
            -- if chunk is empty, we are done (the rest are junk characters)
            List.reverse reversedIdNumbers

        chunk :: _ ->
            -- decode the number without using the `separator` character
            let
                alphabetWithoutSeparator : Array Char
                alphabetWithoutSeparator =
                    Array.slice 1 (Array.length alphabet) alphabet

                number : Int
                number =
                    toNumber (String.toList chunk) alphabetWithoutSeparator
            in
            decodeWithAlphabetHelper (number :: reversedIdNumbers)
                (String.dropLeft (String.length chunk + 1) idString)
                (Shuffle.shuffle alphabet)


toNumber : List Char -> Array Char -> Int
toNumber id alphabet =
    List.foldl (\v a -> a * Array.length alphabet + findIndexInArray v alphabet) 0 id


findIndexInArray : a -> Array a -> Int
findIndexInArray a array =
    let
        inner : Int -> Maybe Int
        inner index =
            Array.get index array
                |> Maybe.andThen
                    (\value ->
                        if value == a then
                            Just index

                        else
                            inner (index + 1)
                    )
    in
    inner 0
        |> Maybe.withDefault -1


{-| Possible Error cases when trying to encode integer numbers.

If you want to show these errors to the user, you can use the [encodeErrorToString](#encodeErrorToString) helper.

-}
type EncodeError
    = NegativeNumber Int
    | TooHighInteger Int
    | MaxRegenerateAttempts


{-| Convenience function to simplify giving feedback to users
-}
encodeErrorToString : EncodeError -> String
encodeErrorToString error =
    -- These texts are taken from
    -- https://github.com/sqids/sqids-spec/blob/40f407169fa0f555b93a197ff0a9e974efa9fba6/src/index.ts
    case error of
        NegativeNumber number ->
            "Encoding supports numbers between 0 and " ++ String.fromInt maxSafeInt ++ ", but " ++ String.fromInt number ++ " was given"

        TooHighInteger number ->
            "Encoding supports numbers between 0 and " ++ String.fromInt maxSafeInt ++ ", but " ++ String.fromInt number ++ " was given"

        MaxRegenerateAttempts ->
            "Reached max attempts to re-generate the ID"


{-| Encodes a list of unsigned integer numbers into a string using the [default Context](./Sqids-Context#default).
-}
encode : List Int -> Result EncodeError String
encode =
    encodeWith Sqids.Context.default


{-| Encodes a list of unsigned integer numbers into a string
-}
encodeWith : Context -> List Int -> Result EncodeError String
encodeWith context values =
    if values == [] then
        Ok ""

    else
        case validInput values of
            Ok () ->
                encodeNumbers context 0 values

            Err err ->
                Err err


validInput : List Int -> Result EncodeError ()
validInput list =
    case list of
        [] ->
            Ok ()

        first :: rest ->
            if first < 0 then
                Err <| NegativeNumber first

            else if first > maxSafeInt then
                Err <| TooHighInteger first

            else
                validInput rest


{-| The maximum safe integer in JavaScript (and Elm) is 9007199254740991 (2^53 – 1).
See <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/MAX_SAFE_INTEGER>
-}
maxSafeInt : Int
maxSafeInt =
    -- 2^53 - 1 (`Number.MAX_SAFE_INTEGER` in JS)
    9007199254740991


encodeNumbers : Context -> Int -> List Int -> Result EncodeError String
encodeNumbers context increment numbers =
    let
        initialAlphabet : Array Char
        initialAlphabet =
            Sqids.Context.getAlphabet context

        alphabetLength : Int
        alphabetLength =
            Array.length initialAlphabet
    in
    -- if increment is greater than alphabet length, we've reached max attempts
    if increment > alphabetLength then
        Err MaxRegenerateAttempts

    else
        let
            id : String
            id =
                let
                    offset : Int
                    offset =
                        -- get a semi-random offset from input numbers
                        generateOffsetFromInputs initialAlphabet numbers
                            + increment
                            |> modBy alphabetLength

                    reorderedAlphabet : Array Char
                    reorderedAlphabet =
                        --  re-arrange alphabet so that second-half goes in front of the first-half
                        Array.append (Array.slice offset alphabetLength initialAlphabet)
                            (Array.slice 0 offset initialAlphabet)

                    prefix : Char
                    prefix =
                        -- `prefix` is the first character in the generated ID, used for randomization
                        arrayGetInBounds 0 reorderedAlphabet

                    reversedAlphabet : Array Char
                    reversedAlphabet =
                        -- reverse alphabet (otherwise for [0, x] `offset` and `separator` will be the same char)
                        Array.Extra.reverse reorderedAlphabet

                    func : Int -> Int -> { alphabet : Array Char, id : List String } -> { alphabet : Array Char, id : List String }
                    func index num last =
                        let
                            alphabetWithoutSeparator : Array Char
                            alphabetWithoutSeparator =
                                Array.slice 1 alphabetLength last.alphabet

                            id_ : String
                            id_ =
                                toId num alphabetWithoutSeparator
                        in
                        if index < (List.length numbers - 1) then
                            let
                                separator : Char
                                separator =
                                    arrayGetInBounds 0 last.alphabet
                            in
                            { id = String.fromChar separator :: id_ :: last.id
                            , alphabet = Shuffle.shuffle last.alphabet
                            }

                        else
                            { id = id_ :: last.id
                            , alphabet = last.alphabet
                            }
                in
                List.Extra.indexedFoldl func { alphabet = reversedAlphabet, id = [ String.fromChar prefix ] } numbers
                    |> padId (Sqids.Context.getMinLength context)
        in
        if Sqids.Context.containsBlockedWord context id then
            encodeNumbers context (increment + 1) numbers

        else
            Ok id


{-| TESTED

    let alphabet = "abc"
    let numbers = [0,1,2]
    let offset =
        numbers.reduce((a, v, i) => {
            const cp = alphabet[v % alphabet.length].codePointAt(0)
            console.log({a, v, i, cp})
            return cp + i + a;
        }, numbers.length) % alphabet.length;

-}
generateOffsetFromInputs : Array Char -> List Int -> Int
generateOffsetFromInputs alphabet numbers =
    let
        alphabetLength : Int
        alphabetLength =
            Array.length alphabet
    in
    List.Extra.indexedFoldl
        (\index value acc ->
            case Array.get (value |> modBy alphabetLength) alphabet |> Maybe.map Char.toCode of
                Nothing ->
                    -1

                Just codePoint ->
                    codePoint + index + acc
        )
        (List.length numbers)
        numbers
        |> modBy alphabetLength


{-| TESTED

    function toId(num, alphabet) {
        const id = [];
        const chars = alphabet.split('');

        let result = num;

        do {
            id.unshift(chars[result % chars.length]);
            result = Math.floor(result / chars.length);
        } while (result > 0);

        return id.join('');
    }

-}
toId : Int -> Array Char -> String
toId num alphabet =
    -- TODO don't expose this function in package
    let
        charsLength : Int
        charsLength =
            Array.length alphabet

        rec : Int -> List Char -> List Char
        rec lastResult lastId =
            let
                nextId : List Char
                nextId =
                    arrayGetInBounds (lastResult |> modBy charsLength) alphabet :: lastId

                nextResult : Int
                nextResult =
                    -- Cannot use integer division `//` because Elm clamps it to 32 bit, see https://github.com/elm/core/issues/1003
                    toFloat lastResult
                        / toFloat charsLength
                        |> floor
            in
            if nextResult > 0 then
                rec nextResult nextId

            else
                nextId
    in
    rec num []
        |> String.fromList


{-| Only use this if you are sure that the index is between 0 and length of the Array
-}
arrayGetInBounds : Int -> Array Char -> Char
arrayGetInBounds index array =
    Array.get index array
        |> Maybe.withDefault 'ö'


padId : Int -> { alphabet : Array Char, id : List String } -> String
padId minLength { alphabet, id } =
    padIdIfNeeded minLength alphabet id
        |> List.reverse
        |> String.concat


padIdIfNeeded : Int -> Array Char -> List String -> List String
padIdIfNeeded minLength alphabet id =
    if minLength <= List.length id then
        id

    else
        let
            idWithSeparator : List String
            idWithSeparator =
                (arrayGetInBounds 0 alphabet |> String.fromChar)
                    :: id

            rec : Array Char -> List String -> List String
            rec abc currentId =
                let
                    diff : Int
                    diff =
                        minLength - List.length currentId
                in
                if diff < 1 then
                    currentId

                else
                    let
                        shuffled : Array Char
                        shuffled =
                            Shuffle.shuffle abc

                        nextId : List String
                        nextId =
                            Array.slice 0 diff shuffled
                                |> Array.foldl ((::) << String.fromChar) []
                                |> (\chars -> chars ++ currentId)
                    in
                    rec shuffled nextId
        in
        -- https://github.com/sqids/sqids-spec/blob/40f407169fa0f555b93a197ff0a9e974efa9fba6/src/index.ts#L152-L163
        rec alphabet idWithSeparator
