module Main exposing (..)

import AboutPage
import Browser
import Browser.Navigation
import Element
import HomePage
import Html
import Router
import UI exposing (link)
import Url


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = onUrlChange
        , onUrlRequest = onUrlRequest
        }


type alias Model =
    { url : Url.Url
    , navigationKey : Browser.Navigation.Key
    , modelAboutPage : AboutPage.Model
    , modelHomePage : HomePage.Model
    }


type Msg
    = MsgAboutPage AboutPage.Msg
    | MsgHomePage HomePage.Msg
    | MsgUrlChanged Url.Url
    | MsgUrlRequested Browser.UrlRequest


init : () -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init _ url navigationKey =
    ( initModel url navigationKey, Cmd.none )


initModel : Url.Url -> Browser.Navigation.Key -> Model
initModel url navigationKey =
    { url = url
    , navigationKey = navigationKey
    , modelAboutPage = AboutPage.initModel
    , modelHomePage = HomePage.initModel
    }


view : Model -> Browser.Document Msg
view model =
    { title = getTitle model.url
    , body = [ viewContent model ]
    }


getTitle : Url.Url -> String
getTitle url =
    if String.startsWith "/about" url.path then
        "About"

    else
        "My Blog"


viewContent : Model -> Html.Html Msg
viewContent model =
    Element.layout []
        (Element.column [ Element.padding 22 ]
            [ viewHeader
            , viewPage model
            , viewFooter
            ]
        )


viewHeader : Element.Element msg
viewHeader =
    Element.row [ Element.spacing 10 ]
        [ link (Router.asPath Router.RouteHomePage) "Home" []
        , link (Router.asPath Router.RouteAboutPage) "About" []
        ]


viewFooter : Element.Element msg
viewFooter =
    Element.row [ Element.spacing 10 ]
        [ link "https://www.duckduckgo.com" "DuckDuckGo" []
        , link "https://www.ecosia.org" "Ecosia" []
        ]


viewPage : Model -> Element.Element Msg
viewPage model =
    case Router.fromUrl model.url of
        Just Router.RouteAboutPage ->
            Element.map MsgAboutPage (AboutPage.view model.modelAboutPage)

        Just Router.RouteHomePage ->
            Element.map MsgHomePage (HomePage.view model.modelHomePage)

        Nothing ->
            Element.text "Not found 404"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgUrlChanged url ->
            ( { model | url = url }, Cmd.none )

        MsgUrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    if url.path == "/about/hide-detail" then
                        let
                            hiddenDetailModel =
                                { showDetail = False
                                }
                        in
                        ( { model | modelAboutPage = hiddenDetailModel }, Cmd.none )

                    else
                        ( model
                        , Browser.Navigation.pushUrl model.navigationKey (Url.toString url)
                        )

                Browser.External url ->
                    ( model, Browser.Navigation.load url )

        MsgAboutPage msgAboutPage ->
            let
                ( newAboutPageModel, cmdAboutPage ) =
                    AboutPage.update msgAboutPage model.modelAboutPage
            in
            ( { model | modelAboutPage = newAboutPageModel }, Cmd.map MsgAboutPage cmdAboutPage )

        MsgHomePage msgHomePage ->
            let
                ( newHomePageModel, cmdHomePage ) =
                    HomePage.update msgHomePage model.modelHomePage
            in
            ( { model | modelHomePage = newHomePageModel }, Cmd.map MsgHomePage cmdHomePage )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map MsgAboutPage (AboutPage.subscriptions model.modelAboutPage)
        , Sub.map MsgHomePage (HomePage.subscriptions model.modelHomePage)
        ]


onUrlChange : Url.Url -> Msg
onUrlChange url =
    MsgUrlChanged url


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest urlRequest =
    MsgUrlRequested urlRequest
