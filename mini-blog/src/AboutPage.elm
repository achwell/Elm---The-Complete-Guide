module AboutPage exposing (..)

import Element
import Element.Font
import Element.Input
import UI exposing (link, linkWithAction)


type alias Model =
    { showDetail : Bool
    }


type Msg
    = MsgShowDetailClicked


initModel : Model
initModel =
    { showDetail = False
    }


view : Model -> Element.Element Msg
view model =
    Element.column [ Element.padding 20, Element.Font.size 14 ]
        [ Element.el [ Element.Font.size 22 ] (Element.text "About page")
        , Element.paragraph
            [ Element.paddingXY 0 20
            ]
            [ Element.text "This is a web site for learning about navigation"
            ]
        , Element.paragraph []
            [ viewDetail model.showDetail
            ]
        ]


viewDetail : Bool -> Element.Element Msg
viewDetail showDetail =
    if showDetail then
        Element.column [ Element.spacing 10, Element.padding 20 ]
            [ Element.text "The authors of this web site are amazing"
            , link "/about/hide-detail" "Hide" [ Element.Font.size 12, Element.Font.bold ]
            ]

    else
        linkWithAction MsgShowDetailClicked "Show more" [ Element.Font.underline ]


update : Msg -> Model -> ( Model, Cmd.Cmd Msg )
update msg model =
    case msg of
        MsgShowDetailClicked ->
            ( { model | showDetail = True }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
