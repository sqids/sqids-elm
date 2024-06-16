module Internal.Alphabet exposing (..)

import Expect
import Fuzz
import String.UTF8
import Test exposing (Test)


invalidCharacters : Test
invalidCharacters =
    Test.todo "fuzz test alphabets and compare their length with String.UTF8.length"
