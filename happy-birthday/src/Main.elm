module Main exposing (..)

import Browser
import Html exposing (button, div, input, p, text)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onClick, onInput)


initModel : Model
initModel =
    { message = "Welcome", firstname = Nothing, age = Nothing }


main : Program () Model Msg
main =
    Browser.sandbox { init = initModel, view = view, update = update }


type Msg
    = MsgSuprise
    | MsgReset
    | MsgNewName String
    | MsgNewAgeAsString String


type alias Model =
    { message : String
    , firstname : Maybe String
    , age : Maybe Int
    }


view : Model -> Html.Html Msg
view model =
    div []
        [ viewMessage model.message
        , viewFirstNameInput model.firstname
        , viewAgeInput model.age
        , viewLength model.firstname
        , viewButton "Surprise" MsgSuprise
        , viewButton "Reset" MsgReset
        ]


viewMessage : String -> Html.Html Msg
viewMessage message =
    text message


viewFirstNameInput : Maybe String -> Html.Html Msg
viewFirstNameInput firstname =
    input [ onInput MsgNewName, value (Maybe.withDefault "" firstname) ] []


viewAgeInput : Maybe Int -> Html.Html Msg
viewAgeInput age =
    input [ type_ "number", onInput MsgNewAgeAsString, value (String.fromInt (Maybe.withDefault 0 age)) ] []


viewLength : Maybe String -> Html.Html msg
viewLength firstname =
    p [] [ text (" " ++ String.fromInt (String.length (Maybe.withDefault "" firstname))) ]


viewButton : String -> Msg -> Html.Html Msg
viewButton label action =
    button [ onClick action ] [ text label ]


update : Msg -> Model -> Model
update msg model =
    case msg of
        MsgSuprise ->
            case model.age of
                Just anAge ->
                    case model.firstname of
                        Just aName ->
                            { model
                                | message = "Happy Birthday " ++ aName ++ " with " ++ String.fromInt anAge ++ " years old !!"
                            }

                        Nothing ->
                            { model
                                | message = "The first name is required"
                            }

                Nothing ->
                    { model
                        | message = "The age is required"
                    }

        MsgReset ->
            initModel

        MsgNewName newName ->
            if String.trim newName == "" then
                { model
                    | firstname = Nothing
                }

            else
                { model
                    | firstname = Just newName
                }

        MsgNewAgeAsString newValue ->
            case String.toInt newValue of
                Just anInt ->
                    { model
                        | age = Just anInt
                    }

                Nothing ->
                    { model
                        | message = "The age is wrong"
                        , age = Nothing
                    }
