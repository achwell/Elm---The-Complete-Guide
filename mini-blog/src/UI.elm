module UI exposing (..)

import Element
import Element.Font
import Element.Input


link : String -> String -> List (Element.Attribute msg) -> Element.Element msg
link url caption attrs =
    Element.link
        ([ Element.Font.color (Element.rgb255 0x11 0x55 0xFF)
         , Element.Font.underline
         ]
            ++ attrs
        )
        { url = url
        , label = Element.text caption
        }


linkWithAction : msg -> String -> List (Element.Attribute msg) -> Element.Element msg
linkWithAction msg caption attrs =
    Element.Input.button
        ([ Element.Font.color (Element.rgb255 0x11 0x55 0xFF)
         , Element.Font.underline
         ]
            ++ attrs
        )
        { onPress = Just msg
        , label = Element.text caption
        }
