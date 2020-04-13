module Update exposing (..)

import Api
import Model exposing (..)
import Process
import Task

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of

    -- API responses

    GotPlayers response ->
      case response of
        Ok players ->
          ({ model | players = players }, Cmd.none)

        Err _ ->
          (addError model FetchBoardsError "error fetching players", Cmd.none)

    GotBoards response ->
      case response of
        Ok boards ->
          ({ model | boards = boards }, Cmd.none)

        Err _ ->
          (addError model FetchBoardsError "error fetching boards", Cmd.none)


    -- Form submissions

    PlayerAdd ->
      case playerAddFormToPlayer model.playerAddForm of
        Just player ->
          (clearPlayerAddForm model, Api.playerAdd player)

        Nothing ->
          (addError model PlayerAddError "invalid player add form input", Cmd.none)

    BoardAdd ->
      case boardAddFormToBoard model.boardAddForm of
        Just board ->
          (clearBoardAddForm model, Api.boardAdd board)

        Nothing ->
          (addError model BoardAddError "invalid board add form input", Cmd.none)

    BoardDelete board ->
      (showConfirmBoardDelete model board, Cmd.none)

    BoardDeleteConfirm ->
      case model.boardToDelete of
        Just board ->
          (clearConfirmBoardDelete model, Api.boardDelete board)

        Nothing ->
          ( addError model StateError "attempted to confirm with no staged board delete"
          , Cmd.none)

    ClearConfirmBoardDelete ->
      (clearConfirmBoardDelete model, Cmd.none)

    -- Form submission responses

    PlayerAdded response ->
      case response of
        Ok _ ->
          ( setNotification model "player added"
          , Cmd.batch
            [ Api.playersFetch
            , scheduleNotificationClear
            ]
          )

        Err _ ->
          (addError model PlayerAddError "error adding player" , Cmd.none)

    BoardAdded response ->
      case response of
        Ok _ ->
          ( setNotification model  "board added"
          , Cmd.batch
            [ Api.boardsFetch
            , scheduleNotificationClear
            ]
          )

        Err _ ->
          (addError model BoardAddError "error adding board", Cmd.none)

    BoardDeleted response ->
      case response of
        Ok _ ->
          ( setNotification model "board deleted"
          , Cmd.batch
            [ Api.boardsFetch
            , scheduleNotificationClear
            ]
          )

        Err _ ->
          (addError model BoardDeleteError "error deleting board", Cmd.none)


    -- Form updates

    UpdateNewPlayerName name ->
      (updatePlayerAddFormName model name, Cmd.none)

    UpdateNewBoardName name ->
      (updateBoardAddFormName model name, Cmd.none)


    -- Error/notification clearing

    ErrorClear errorId ->
      (clearError model errorId, Cmd.none)

    NotificationClear ->
      (clearNotification model, Cmd.none)


addError : Model -> ErrorType -> String -> Model
addError model errorType errorMessage =
  { model
  | errors = appendError model.errors model.errorId errorType errorMessage
  , errorId = model.errorId + 1
  }

clearError : Model -> ErrorId -> Model
clearError model errorId =
  { model | errors = List.filter (\error -> error.id /= errorId) model.errors }

setNotification : Model -> Notification -> Model
setNotification model notification =
  { model | notification = Just notification }

clearNotification : Model -> Model
clearNotification model =
  { model | notification = Nothing }

appendError : List Error -> ErrorId -> ErrorType -> String -> List Error
appendError errors id typ message =
  { id = id, typ = typ, message = message } :: errors

showConfirmBoardDelete : Model -> Board -> Model
showConfirmBoardDelete model board =
  { model | boardToDelete = Just board }

clearConfirmBoardDelete : Model -> Model
clearConfirmBoardDelete model =
  { model | boardToDelete = Nothing }

updatePlayerAddFormName : Model -> String -> Model
updatePlayerAddFormName model name =
  let playerAddForm = model.playerAddForm in
  { model | playerAddForm = { playerAddForm | name = if name == "" then Nothing else Just name } }

clearPlayerAddForm : Model -> Model
clearPlayerAddForm model =
  { model | playerAddForm = createPlayerAddForm }

updateBoardAddFormName : Model -> String -> Model
updateBoardAddFormName model name =
  let boardAddForm = model.boardAddForm in
  { model | boardAddForm = { boardAddForm | name = if name == "" then Nothing else Just name } }

clearBoardAddForm : Model -> Model
clearBoardAddForm model =
  { model | boardAddForm = createBoardAddForm }

scheduleNotificationClear : Cmd Msg
scheduleNotificationClear =
  delay 5000.0 NotificationClear

delay : Float -> Msg -> Cmd Msg
delay time msg =
  Process.sleep time
  |> Task.perform (\_ -> msg)