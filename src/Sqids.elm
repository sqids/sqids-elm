module Sqids exposing
    ( EncodeError(..)
    , decode
    , decodeWith
    , encodeList
    , encodeListWith
    , errToString
    , maxSafeInt
    , toId
    )

import Array exposing (Array)
import Array.Extra
import Defaults exposing (Context)
import List.Extra
import Shuffle
import Sqids.Context


type EncodeError
    = NegativeNumber Int
    | TooHighInteger Int
    | MaxRegenerateAttempts


{-| These texts are taken from
<https://github.com/sqids/sqids-spec/blob/40f407169fa0f555b93a197ff0a9e974efa9fba6/src/index.ts>
-}
errToString : EncodeError -> String
errToString error =
    case error of
        NegativeNumber _ ->
            "Encoding supports numbers between 0 and " ++ String.fromInt maxSafeInt

        TooHighInteger _ ->
            "Encoding supports numbers between 0 and " ++ String.fromInt maxSafeInt

        MaxRegenerateAttempts ->
            "Reached max attempts to re-generate the ID"


decode : String -> List Int
decode =
    decodeWith Defaults.context


decodeWith : Context -> String -> List Int
decodeWith context string =
    if string == "" then
        []

    else if Sqids.Context.allInAlphabet context string then
        Debug.todo "implement decodeWith"

    else
        []


encodeList : List Int -> Result EncodeError String
encodeList =
    encodeListWith Defaults.context


encodeListWith : Context -> List Int -> Result EncodeError String
encodeListWith context values =
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

        minLength =
            0

        alphabetLength =
            Array.length initialAlphabet
    in
    -- if increment is greater than alphabet length, we've reached max attempts
    if increment > alphabetLength then
        Err MaxRegenerateAttempts

    else
        let
            -- get a semi-random offset from input numbers
            offset =
                generateOffsetFromInputs initialAlphabet numbers
                    + increment
                    |> modBy alphabetLength
                    |> Debug.log "offset"

            --  re-arrange alphabet so that second-half goes in front of the first-half
            reorderedAlphabet =
                Array.append (Array.slice offset alphabetLength initialAlphabet)
                    (Array.slice 0 offset initialAlphabet)
                    |> Debug.log "reordered alphabet"

            -- `prefix` is the first character in the generated ID, used for randomization
            prefix =
                arrayGetInBounds 0 reorderedAlphabet

            -- reverse alphabet (otherwise for [0, x] `offset` and `separator` will be the same char)
            reversedAlphabet =
                Array.Extra.reverse reorderedAlphabet
                    |> Debug.log "reversed alphabet"

            {- TODO list
                // final ID will always have the `prefix` character at the beginning
               const ret = [prefix];

               // encode input array
               for (let i = 0; i != numbers.length; i++) {
                   const num = numbers[i];

                   // the first character of the alphabet is going to be reserved for the `separator`
                   const alphabetWithoutSeparator = alphabet.slice(1);
                   ret.push(this.toId(num, alphabetWithoutSeparator));

                   // if not the last number
                   if (i < numbers.length - 1) {
                       // `separator` character is used to isolate numbers within the ID
                       ret.push(alphabet.slice(0, 1));

                       // shuffle on every iteration
                       alphabet = this.shuffle(alphabet);
                   }
               }

               // join all the parts to form an ID
               let id = ret.join('');
            -}
            id =
                let
                    func : Int -> Int -> { alphabet : Array Char, id : List String } -> { alphabet : Array Char, id : List String }
                    func index num last =
                        let
                            _ =
                                Debug.log ("step " ++ String.fromInt index) { num = num, last = last }

                            alphabetWithoutSeparator =
                                Array.slice 1 alphabetLength last.alphabet

                            separator =
                                arrayGetInBounds 0 last.alphabet

                            id_ : String
                            id_ =
                                toId num alphabetWithoutSeparator

                            ids =
                                if index < (List.length numbers - 1) then
                                    String.fromChar separator :: id_ :: last.id

                                else
                                    id_ :: last.id
                        in
                        case Shuffle.charArray last.alphabet of
                            Ok alphabet ->
                                { alphabet = alphabet, id = ids }

                            Err err ->
                                -- last
                                Debug.todo <| "Shuffle error: " ++ Debug.toString err
                in
                List.Extra.indexedFoldl func { alphabet = reversedAlphabet, id = [ String.fromChar prefix ] } numbers
                    |> .id
                    |> List.reverse
                    |> String.join ""

            {-
               // handle `minLength` requirement, if the ID is too short
               if (this.minLength > id.length) {
                   // append a separator
                   id += alphabet.slice(0, 1);

                   // keep appending `separator` + however much alphabet is needed
                   // for decoding: two separators next to each other is what tells us the rest are junk characters
                   while (this.minLength - id.length > 0) {
                       alphabet = this.shuffle(alphabet);
                       id += alphabet.slice(0, Math.min(this.minLength - id.length, alphabet.length));
                   }
               }

               // if ID has a blocked word anywhere, restart with a +1 increment
               if (this.isBlockedId(id)) {
                   id = this.encodeNumbers(numbers, increment + 1);
               }
            -}
        in
        if String.length id < minLength then
            -- https://github.com/sqids/sqids-spec/blob/40f407169fa0f555b93a197ff0a9e974efa9fba6/src/index.ts#L152-L163
            Debug.todo "Append random characters if minimum length is not met"

        else
            -- TODO handle blocked words
            -- https://github.com/sqids/sqids-spec/blob/40f407169fa0f555b93a197ff0a9e974efa9fba6/src/index.ts#L165-L168
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
        charsLength =
            Array.length alphabet

        rec : Int -> List Char -> List Char
        rec lastResult lastId =
            let
                nextId =
                    arrayGetInBounds (lastResult |> modBy charsLength) alphabet :: lastId

                nextResult =
                    lastResult // charsLength
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
