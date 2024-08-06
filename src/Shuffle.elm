module Shuffle exposing (shuffle)

import Array exposing (Array)


{-| consistent shuffle (always produces the same result given the input)
From <https://github.com/sqids/sqids-spec/blob/40f407169fa0f555b93a197ff0a9e974efa9fba6/src/index.ts#L244>

    function shuffle(alphabet) {
        const chars = alphabet.split('');

        for (let i = 0, j = chars.length - 1; j > 0; i++, j--) {
            const r = (i * j + chars[i].codePointAt(0) + chars[j].codePointAt(0)) % chars.length;
            [chars[i], chars[r]] = [chars[r], chars[i]];
        }

        return chars.join('');
    }

-}
shuffle : Array Char -> Array Char
shuffle input =
    let
        length : Int
        length =
            Array.length input
    in
    shuf 0 (length - 1) length input


{-| Trusting the algorithm and ignoring out-of-bounds array access errors
-}
shuf : Int -> Int -> Int -> Array Char -> Array Char
shuf i j length chars =
    case
        ( Array.get i chars |> Maybe.map Char.toCode
        , Array.get j chars |> Maybe.map Char.toCode
        )
    of
        ( Just iCharCode, Just jCharCode ) ->
            let
                r : Int
                r =
                    (i * j + iCharCode + jCharCode)
                        |> modBy length
            in
            case Array.get r chars of
                Just rChar ->
                    let
                        arr : Array Char
                        arr =
                            Array.set i rChar chars
                                |> Array.set r (Char.fromCode iCharCode)
                    in
                    if j > 1 then
                        shuf (i + 1) (j - 1) length arr

                    else
                        arr

                Nothing ->
                    Array.empty

        ( Nothing, _ ) ->
            Array.empty

        ( _, Nothing ) ->
            Array.empty
