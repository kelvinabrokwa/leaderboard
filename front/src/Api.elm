module Api exposing (..)

import Http
import Json.Decode as D
import Json.Encode as E
import Url

import Model exposing (..)


createUrl : List String -> String
createUrl path =
  { protocol = Url.Http
  , host = "localhost"
  , port_ = Just 8080
  , path = "/" ++ String.join "/" path
  , query = Nothing
  , fragment = Nothing
  }
  |> Url.toString

playersFetch : Cmd Msg
playersFetch =
  Http.get
    { url = createUrl ["players"]
    , expect = Http.expectJson GotPlayers playersDecoder
    }

boardsFetch : Cmd Msg
boardsFetch =
  Http.get
    { url = createUrl ["boards"]
    , expect = Http.expectJson GotBoards boardsDecoder
    }

playerAdd : Player -> Cmd Msg
playerAdd player =
  Http.post
    { url = createUrl ["players"]
    , body = createPlayerAddRequest player |> encodePlayerAddRequest |> Http.jsonBody
    , expect = Http.expectJson PlayerAdded addPlayerResponseDecoder
    }


boardAdd : Board -> Cmd Msg
boardAdd board =
  Http.post
    { url = createUrl ["boards"]
    , body = createBoardAddRequest board |> encodeAddBoardRequest |> Http.jsonBody
    , expect = Http.expectJson BoardAdded addBoardResponseDecoder
    }

httpRequest : { url: String, expect: Http.Expect msg, method: String } -> Cmd msg
httpRequest { url, expect, method } =
  Http.request
    { method = method
    , headers = []
    , url = url
    , body = Http.emptyBody
    , expect = expect
    , timeout = Nothing
    , tracker = Nothing
    }

httpDelete : { url: String, expect: Http.Expect msg } -> Cmd msg
httpDelete { url, expect } =
  httpRequest
    { url = url
    , expect = expect
    , method = "DELETE"
    }

boardDelete : Board -> Cmd Msg
boardDelete board =
  httpDelete
    { url = createUrl ["boards", String.fromInt board.id]
    , expect = Http.expectJson BoardDeleted deleteBoardResponseDecoder
    }


-- JSON encoders

encodePlayer : Player -> E.Value
encodePlayer player =
  E.object
    [ ("id", E.int player.id)
    , ("name", E.string player.name)
    ]

encodeBoard : Board -> E.Value
encodeBoard board =
  E.object
    [ ("id", E.int board.id)
    , ("name", E.string board.name)]

encodePlayerAddRequest : PlayerAddRequest -> E.Value
encodePlayerAddRequest addPlayerRequest =
  E.object
    [("player", encodePlayer addPlayerRequest.player)]


encodeAddBoardRequest : BoardAddRequest -> E.Value
encodeAddBoardRequest addBoardRequest =
  E.object
    [("board", encodeBoard addBoardRequest.board)]


-- JSON decoders

playersDecoder : D.Decoder (List Player)
playersDecoder =
  D.field
    "players"
    (D.list
      (D.map2 Player
        (D.field "id" D.int)
        (D.field "name" D.string)))

boardsDecoder : D.Decoder (List Board)
boardsDecoder =
  D.field
    "boards"
    (D.list
      (D.map2 Board
        (D.field "id" D.int)
        (D.field "name" D.string)))

addPlayerResponseDecoder : D.Decoder PlayerAddResponse
addPlayerResponseDecoder =
  D.map
    PlayerAddResponse
    (D.field "message" D.string)

addBoardResponseDecoder : D.Decoder BoardAddResponse
addBoardResponseDecoder =
  D.map
    BoardAddResponse
    (D.field "message" D.string)

deleteBoardResponseDecoder : D.Decoder BoardDeleteResponse
deleteBoardResponseDecoder =
  D.map
    BoardDeleteResponse
    (D.field "message" D.string)