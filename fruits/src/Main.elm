module Main exposing (..)

import Chart
import Chart.Attributes
import Dict
import Svg

main =
    Chart.chart
        [ Chart.Attributes.width 900
        , Chart.Attributes.height 300
        , Chart.Attributes.margin { top = 50, right = 50, bottom = 50, left = 50 }
        ]
        [ Chart.bars []
            [ Chart.bar .calories [Chart.Attributes.color "#336699"]
            , Chart.bar .kj [Chart.Attributes.color "#339966"]
            ]
            data
          , Chart.xLabels [Chart.Attributes.format labelFor]
          , Chart.yLabels [ Chart.Attributes.withGrid ]
          , Chart.labelAt Chart.Attributes.middle
            .max
            [
                Chart.Attributes.moveUp 20
                ,Chart.Attributes.fontSize 24
            ]
            [Svg.text "Fruits"]
        ]


data =
    [ { x = 1, calories = 52.0, kj = 218.0 }
    , { x = 2, calories = 160.0, kj = 672.0 }
    , { x = 3, calories = 47.0, kj = 197.0 }
    ]

labels =
    Dict.fromList
        [ ( 1, "Apple" )
        , ( 2, "Avocado" )
        , ( 3, "Clementine" )
        , ( 4, "Chirimoya" )
        ]
        
labelFor x =
    Maybe.withDefault "" (Dict.get x labels)