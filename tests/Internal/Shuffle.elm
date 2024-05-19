module Internal.Shuffle exposing (..)

import Shuffle
import Expect
import Test exposing (Test)


defaultOptions : { alphabet : String }
defaultOptions =
    { alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    }


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
            Shuffle.string input
                |> Expect.equal (Ok output)
