module Main exposing (..)

import Browser
import Browser.Events
import Element
import Element.Font
import Html


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Size =
    { w : Int
    , h : Int
    }


type alias Model =
    { windowSize : Size
    }


type Msg
    = MsgWindowSizeChanged Int Int


type alias Flags =
    Size


initModel : Flags -> Model
initModel windowSize =
    { windowSize = windowSize }


init : Flags -> ( Model, Cmd.Cmd Msg )
init windowSize =
    ( initModel windowSize, Cmd.none )


view : Model -> Html.Html Msg
view model =
    let
        direction =
            if model.windowSize.w > 800 then
                Element.row

            else
                Element.column

        fontSize =
            if model.windowSize.w > 1024 then
                32

            else if model.windowSize.w > 800 then
                28

            else
                22
    in
    Element.layout []
        (Element.column [ Element.Font.size fontSize ]
            [ direction
                [ Element.spacing 10 ]
                [ Element.text
                    (String.fromInt model.windowSize.w
                        ++ "x"
                        ++ String.fromInt model.windowSize.h
                    )
                , Element.text "Item A"
                , Element.text "Item B"
                , Element.text "Item C"
                , Element.text "Item D"
                , Element.text "Item E"
                ]
            , viewWrappedRow
            ]
        )


viewWrappedRow : Element.Element msg
viewWrappedRow =
    Element.wrappedRow [ Element.spacing 10 ]
        [ Element.text "Wrapped 1"
        , Element.text "Wrapped 2"
        , Element.text "Wrapped 3"
        , Element.text "Wrapped 4"
        , Element.text "Wrapped 5"
        , Element.text "Wrapped 6"
        , Element.text "Wrapped 7"
        , Element.text "Wrapped 8"
        , Element.text "Wrapped 9"
        , Element.text "Wrapped 10"
        ]


update : Msg -> Model -> ( Model, Cmd.Cmd Msg )
update msg model =
    case msg of
        MsgWindowSizeChanged w h ->
            let
                newWindowSize =
                    { w = w
                    , h = h
                    }
            in
            ( { model | windowSize = newWindowSize }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Browser.Events.onResize MsgWindowSizeChanged
