module Defaults exposing
    ( Context
    , abc
    , context
    )

import Result.Extra
import Sqids.Context


type alias Context =
    Sqids.Context.Context


context : Context
context =
    Sqids.Context.default


{-| TODO remove this example context after first tests
-}
abc : Context
abc =
    Sqids.Context.new
        |> Sqids.Context.withAlphabet "abc"
        |> Sqids.Context.build
        |> Result.Extra.extract (Debug.todo << Debug.toString)
