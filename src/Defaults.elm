module Defaults exposing
    ( Context
    , context
    )

import Sqids.Context


type alias Context =
    Sqids.Context.Context


context : Context
context =
    Sqids.Context.default
