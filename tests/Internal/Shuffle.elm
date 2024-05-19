module Internal.Shuffle exposing (..)

import Array exposing (Array)
import Expect
import Test exposing (Test)


defaultOptions : { alphabet : String }
defaultOptions =
    { alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    }


{-| From <https://github.com/sqids/sqids-spec/blob/40f407169fa0f555b93a197ff0a9e974efa9fba6/tests/internal/shuffle.test.ts>

const shuffle = (alphabet: string): string => {
const chars = alphabet.split('');

for (let i = 0, j = chars.length - 1; j > 0; i++, j--) {
const r = (i \* j + chars[i].codePointAt(0) + chars[j].codePointAt(0)) % chars.length;
[chars[i], chars[r]] = [chars[r], chars[i]];
}

return chars.join('');
};

-}
shuffleTest =
    [ test "default shuffle, checking for randomness"
        defaultOptions.alphabet
        "fwjBhEY2uczNPDiloxmvISCrytaJO4d71T0W3qnMZbXVHg6eR8sAQ5KkpLUGF9"
    , test "numbers in the front, another check for randomness"
        "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "ec38UaynYXvoxSK7RV9uZ1D2HEPw6isrdzAmBNGT5OCJLk0jlFbtqWQ4hIpMgf"
    , test "swapping front 2 characters"
        "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "ec38UaynYXvoxSK7RV9uZ1D2HEPw6isrdzAmBNGT5OCJLk0jlFbtqWQ4hIpMgf"
    , test "swapping front 2 characters (2)"
        "1023456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "xI3RUayk1MSolQK7e09zYmFpVXPwHiNrdfBJ6ZAT5uCWbntgcDsEqjv4hLG28O"
    , test "swapping last 2 characters"
        "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "ec38UaynYXvoxSK7RV9uZ1D2HEPw6isrdzAmBNGT5OCJLk0jlFbtqWQ4hIpMgf"
    , test "swapping last 2 characters (2)"
        "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY"
        "x038UaykZMSolIK7RzcbYmFpgXEPHiNr1d2VfGAT5uJWQetjvDswqn94hLC6BO"
    , test "short alphabet"
        "0123456789"
        "4086517392"
    , test "really short alphabet"
        "12345"
        "24135"
    , test "lowercase alphabet"
        "abcdefghijklmnopqrstuvwxyz"
        "lbfziqvscptmyxrekguohwjand"
    , test "uppercase alphabet"
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "ZXBNSIJQEDMCTKOHVWFYUPLRGA"
    ]
        |> Test.concat


test : String -> String -> String -> Test
test title input output =
    Test.test title <|
        \() ->
            shuffle input
                |> Expect.equal (Ok output)


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
shuffle : String -> Result ShuffleError String
shuffle input =
    let
        length =
            String.length input

        chars =
            input |> String.toList |> Array.fromList
    in
    shuf 0 (length - 1) length chars
        |> Result.map (Array.toList >> String.fromList)


type ShuffleError
    = CharDoesNotExist Int (Array Char)


charArray : Array Char -> Result ShuffleError (Array Char)
charArray input =
    let
        length =
            Array.length input
    in
    shuf 0 (length - 1) length input


shuf : Int -> Int -> Int -> Array Char -> Result ShuffleError (Array Char)
shuf i j length chars =
    case
        ( Array.get i chars |> Maybe.map Char.toCode
        , Array.get j chars |> Maybe.map Char.toCode
        )
    of
        ( Just iCharCode, Just jCharCode ) ->
            let
                r =
                    (i * j + iCharCode + jCharCode)
                        |> modBy length
            in
            case Array.get r chars of
                Just rChar ->
                    let
                        arr =
                            Array.set i rChar chars
                                |> Array.set r (Char.fromCode iCharCode)
                    in
                    if j > 1 then
                        shuf (i + 1) (j - 1) length arr

                    else
                        Ok arr

                Nothing ->
                    CharDoesNotExist r chars |> Err

        ( Nothing, _ ) ->
            CharDoesNotExist i chars |> Err

        ( _, Nothing ) ->
            CharDoesNotExist j chars |> Err
