module Main exposing (main)

import Html exposing (Html)
import Sqids


main =
    let
        encode =
            [ 1, 2, 3 ]

        decode =
            "86Rf07"
    in
    Html.main_ []
        [ Html.h1 []
            [ Html.text "Sqids with default settings" ]
        , Html.div []
            [ "Sqids.encode " ++ Debug.toString encode |> code
            , returns
            , Sqids.encode encode |> result
            ]
        , Html.div []
            [ "Sqids.decode " ++ decode |> code
            , returns
            , Sqids.decode decode |> result
            ]
        ]


returns : Html msg
returns =
    Html.strong [] [ Html.text " --> " ]


code : String -> Html msg
code string =
    Html.code [] [ Html.text string ]


result : a -> Html msg
result =
    Debug.toString >> code
