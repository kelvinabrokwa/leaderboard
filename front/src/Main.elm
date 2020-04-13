module  Main exposing (..)

import Browser

import Api exposing (playersFetch, boardsFetch)
import Model exposing (..)
import View exposing (view)
import Update exposing (update)


main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = \_ -> Sub.none
    , view = view
    }


init : () -> (Model, Cmd Msg)
init _ =
  ({ players = []
   , playerAddForm = createPlayerAddForm
   , errors = []
   , errorId = 0
   , boards = []
   , boardAddForm = createBoardAddForm
   , notification = Nothing
   , boardToDelete = Nothing
   }
  , Cmd.batch
    [ playersFetch
    , boardsFetch
    ]
  )