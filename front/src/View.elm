module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (..)


view : Model -> Html Msg
view model =
  let
    titleView =
      div
        []
        [ h1 [] [ text "leaderboard" ] ]

    notificationView =
      case model.notification of
        Just message ->
          div
            []
            [ div [] [ text message ]
            , button [ onClick NotificationClear ] [ text "clear notification" ]
            ]
        Nothing -> text ""

    fetchErrorsView =
      div
        []
        (List.filter (\error -> List.member error.typ [FetchPlayersError, FetchBoardsError]) model.errors
        |> List.map (\error ->
          div
            []
            [ div [] [ text error.message ]
            , button [ onClick (ErrorClear error.id) ] [ text "clear error" ]
            ]))

    newPlayerErrorView =
      div
        []
        (List.filter (\error -> error.typ == PlayerAddError) model.errors
        |> List.map (\error ->
          div
            []
            [ div [] [ text error.message ]
            , button [ onClick (ErrorClear error.id) ] [ text "clear error" ]
            ]))

    playersView =
      div
        []
        (List.map
          (\player -> div [] [ text player.name ])
          model.players)

    addPlayerView =
      div
        []
        [ input
            [ type_ "text"
            , placeholder "Player Name"
            , value (Maybe.withDefault "" model.playerAddForm.name)
            , onInput UpdateNewPlayerName
            ]
            []
        , button [ onClick PlayerAdd ] [ text "add player" ]
        ]

    boardsView =
      div
        []
        (List.map
          (\board ->
            div
              []
              [ div [] [ text board.name]
              , button [ onClick (BoardDelete board) ] [ text "delete board" ]
              ])
          model.boards)

    deleteBoardConfirmationView =
      case model.boardToDelete of
        Just board ->
          div
            []
            [ div [] [ text ("are you sure you want to delete the " ++ board.name ++ " board?") ]
            , button [ onClick BoardDeleteConfirm ] [ text "yes" ]
            , button [ onClick ClearConfirmBoardDelete ] [ text "no" ]
            ]
        Nothing ->
          div [] []

    addBoardView =
      div
        []
        [ input
          [ type_ "text"
          , placeholder "Board Name"
          , value (Maybe.withDefault "" model.boardAddForm.name)
          , onInput UpdateNewBoardName
          ]
          []
        , button [ onClick BoardAdd ] [ text "add board" ]
        ]

    newBoardErrorView =
      div
        []
        (List.filter (\error -> error.typ == BoardAddError) model.errors
        |> List.map (\error ->
          div
            []
            [ div [] [text error.message]
            , button [ onClick (ErrorClear error.id) ] [ text "clear error" ]
            ]))
  in
  div
    [ style "padding" "50px" ]
    ([ titleView
    , hr [] []
    , notificationView
    , fetchErrorsView
    , newPlayerErrorView
    , playersView
    , addPlayerView
    , hr [] []
    , deleteBoardConfirmationView
    , newBoardErrorView
    , boardsView
    , addBoardView
    ] |> List.map (pad 10))


pad : Int -> Html msg -> Html msg
pad amount element =
  div
    [ style "padding" (String.fromInt amount ++ "px") ]
    [ element ]