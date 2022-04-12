module Main exposing (..)

import Browser
import Browser.Events
import Element
import Element.Background
import Element.Border
import Element.Font
import Element.Input
import Html
import Http exposing (Error(..))
import Json.Decode
import Svg
import Svg.Attributes


type alias Model =
    { searchText : String
    , results : List Book
    , errorMessage : Maybe String
    , loading : Bool
    }


type alias Book =
    { title : String
    , thumbnail : Maybe String
    , link : String
    , pages : Maybe Int
    , publisher : Maybe String
    }


type Msg
    = MsgSearch
    | MsgGotResults (Result Http.Error (List Book))
    | MsgInputTextField String
    | MsgKeyPressed String


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initModel, cmdSearch initModel )


initModel : Model
initModel =
    { searchText = "Elm sucks"
    , results = []
    , errorMessage = Nothing
    , loading = False
    }


view : Model -> Html.Html Msg
view model =
    viewLayout model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgInputTextField newTextInput ->
            ( { model | searchText = newTextInput }, Cmd.none )

        MsgSearch ->
            updateStartSearch model

        MsgKeyPressed key ->
            if key == "Enter" then
                updateStartSearch model

            else
                ( model, Cmd.none )

        MsgGotResults result ->
            let
                newModel =
                    { model | loading = False }
            in
            case result of
                Ok data ->
                    ( { newModel | results = data, errorMessage = Nothing }, Cmd.none )

                Err error ->
                    let
                        errorMessage =
                            case error of
                                NetworkError ->
                                    "Network Error"

                                BadUrl _ ->
                                    "Bad URL"

                                Timeout ->
                                    "Timeout"

                                BadStatus _ ->
                                    "Bad status"

                                BadBody reason ->
                                    reason
                    in
                    ( { newModel | errorMessage = Just errorMessage }, Cmd.none )


updateStartSearch : Model -> ( Model, Cmd Msg )
updateStartSearch model =
    ( { model | loading = True }, cmdSearch model )


subscriptions : model -> Sub Msg
subscriptions _ =
    Browser.Events.onKeyPress keyPressed


keyPressed : Json.Decode.Decoder Msg
keyPressed =
    Json.Decode.map MsgKeyPressed (Json.Decode.field "key" Json.Decode.string)


viewLayout : Model -> Html.Html Msg
viewLayout model =
    Element.layoutWith
        { options =
            [ Element.focusStyle
                { borderColor = Just (Element.rgb255 0x00 0x33 0x66)
                , backgroundColor = Nothing
                , shadow = Nothing
                }
            ]
        }
        []
        (Element.column [ Element.padding 20 ]
            [ viewSearchBar model
            , viewErrorMessage model
            , viewResults model
            ]
        )


viewSearchBar : Model -> Element.Element Msg
viewSearchBar model =
    Element.row [ Element.spacing 10, Element.padding 12 ]
        [ Element.Input.search []
            { onChange = MsgInputTextField
            , text = model.searchText
            , placeholder = Nothing
            , label = Element.Input.labelLeft [] (Element.text "Search books:")
            }
        , viewSearchButton
        , if model.loading then
            Element.html loadingImage

          else
            Element.none
        ]


loadingImage : Html.Html msg
loadingImage =
    Svg.svg
        [ Svg.Attributes.width "64px"
        , Svg.Attributes.height "64px"
        , Svg.Attributes.viewBox "0 0 48 48"
        ]
        [ Svg.circle
            [ Svg.Attributes.cx "24"
            , Svg.Attributes.cy "24"
            , Svg.Attributes.stroke "#6699AA"
            , Svg.Attributes.strokeWidth "4"
            , Svg.Attributes.r "8"
            , Svg.Attributes.fill "none"
            ]
            [ Svg.animate
                [ Svg.Attributes.attributeName "opacity"
                , Svg.Attributes.values "0;.8;0"
                , Svg.Attributes.dur "2s"
                , Svg.Attributes.repeatCount "indefinite"
                ]
                []
            ]
        ]


viewErrorMessage : Model -> Element.Element msg
viewErrorMessage model =
    case model.errorMessage of
        Just errorMessage ->
            Element.text errorMessage

        Nothing ->
            Element.none


viewResults : Model -> Element.Element msg
viewResults model =
    Element.wrappedRow [ Element.spacing 5, Element.centerX ]
        (List.map viewBook model.results)


viewBook : Book -> Element.Element msg
viewBook book =
    let
        titleE =
            Element.paragraph [ Element.Font.bold, Element.Font.underline, Element.paddingXY 0 12 ] [ Element.text book.title ]

        thumbnailE =
            case book.thumbnail of
                Just thumbnail ->
                    viewBookCover thumbnail book.title

                Nothing ->
                    Element.none

        pagesE =
            case book.pages of
                Just pages ->
                    Element.paragraph [ Element.Font.size 12 ]
                        [ Element.text ("(" ++ String.fromInt pages ++ " pages)") ]

                Nothing ->
                    Element.none

        publisherE =
            case book.publisher of
                Just publisher ->
                    Element.paragraph [ Element.Font.size 16 ]
                        [ Element.text publisher ]

                Nothing ->
                    Element.none
    in
    Element.newTabLink
        [ Element.width (Element.px 360)
        , Element.height (Element.px 300)
        , Element.Background.color (Element.rgb255 0xE3 0xEA 0xED)
        , Element.Border.rounded 20
        , Element.padding 10
        , Element.mouseOver
            [ Element.Background.color (Element.rgb255 0x33 0x66 0x99)
            ]
        , Element.focused
            [ Element.Background.color (Element.rgb255 0x33 0x66 0x99)
            ]
        ]
        { url = book.link
        , label =
            Element.row [ Element.centerX ]
                [ thumbnailE
                , Element.column [ Element.padding 20 ]
                    [ titleE
                    , pagesE
                    , publisherE
                    ]
                ]
        }


viewBookCover : String -> String -> Element.Element msg
viewBookCover thumbnail title =
    Element.image []
        { src = thumbnail
        , description = title
        }


viewSearchButton : Element.Element Msg
viewSearchButton =
    Element.Input.button
        [ Element.Background.color (Element.rgb255 0x00 0x33 0x66)
        , Element.Font.color (Element.rgb255 0xEE 0xEE 0xEE)
        , Element.Border.rounded 5
        , Element.padding 12
        , Element.mouseOver
            [ Element.Background.color (Element.rgb255 0x33 0x66 0x99)
            , Element.Font.color (Element.rgb255 0xDD 0xDD 0xDD)
            ]
        , Element.focused
            [ Element.Background.color (Element.rgb255 0x33 0x66 0x99)
            , Element.Font.color (Element.rgb255 0xDD 0xDD 0xDD)
            ]
        ]
        { onPress = Just MsgSearch
        , label = Element.text "Search"
        }


cmdSearch : Model -> Cmd Msg
cmdSearch model =
    Http.get
        { url = "https://www.googleapis.com/books/v1/volumes?q=" ++ model.searchText
        , expect = Http.expectJson MsgGotResults decodeJson
        }


decodeJson : Json.Decode.Decoder (List Book)
decodeJson =
    Json.Decode.field "items" decodeItems


decodeItems : Json.Decode.Decoder (List Book)
decodeItems =
    Json.Decode.list decodeItem


decodeItem : Json.Decode.Decoder Book
decodeItem =
    Json.Decode.field "volumeInfo" decodeVolumeInfo


decodeVolumeInfo : Json.Decode.Decoder Book
decodeVolumeInfo =
    Json.Decode.map5 Book
        (Json.Decode.field "title" Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.field "imageLinks" decodeImageLinks))
        (Json.Decode.field "canonicalVolumeLink" Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.field "pageCount" Json.Decode.int))
        (Json.Decode.maybe (Json.Decode.field "publisher" Json.Decode.string))


decodeImageLinks : Json.Decode.Decoder String
decodeImageLinks =
    Json.Decode.field "thumbnail" Json.Decode.string
