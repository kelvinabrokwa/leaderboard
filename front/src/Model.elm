module Model exposing (..)

import Http

type Msg =
    GotPlayers (Result Http.Error (List Player))
  | GotBoards (Result Http.Error (List Board))
  | PlayerAdd
  | BoardAdd
  | BoardDelete Board
  | BoardDeleteConfirm
  | PlayerAdded (Result Http.Error PlayerAddResponse)
  | BoardAdded (Result Http.Error BoardAddResponse)
  | BoardDeleted (Result Http.Error BoardDeleteResponse)
  | UpdateNewPlayerName String
  | UpdateNewBoardName String
  | ErrorClear ErrorId
  | NotificationClear
  | ClearConfirmBoardDelete

type alias Model =
  { players: List Player
  , errors: List Error
  , errorId: Int
  , boards: List Board
  , notification: Maybe Notification
  , boardToDelete: Maybe Board
  , playerAddForm: PlayerAddForm
  , boardAddForm: BoardAddForm
  }

type alias Player =
  { id: Int
  , name: String
  }

type alias PlayerAddForm =
  { name: Maybe String }

type alias Board =
  { id: Int
  , name: String
  }

type alias BoardAddForm =
  { name: Maybe String }

type alias Notification = String

type ErrorType =
    StateError
  | FetchPlayersError
  | FetchBoardsError
  | PlayerAddError
  | BoardAddError
  | BoardDeleteError
  | NetworkError
  | ApiError

type alias ErrorId = Int

type alias Error =
  { id: ErrorId
  , typ: ErrorType
  , message: String
  }

-- Requests

type alias PlayerAddRequest =
  { player: Player }

type alias BoardAddRequest =
  { board: Board }

createPlayerAddRequest : Player -> PlayerAddRequest
createPlayerAddRequest player =
  { player = player }

createBoardAddRequest : Board -> BoardAddRequest
createBoardAddRequest board =
  { board = board }


-- Responses

type alias PlayerAddResponse =
  { message: String }

type alias BoardAddResponse =
  { message: String }

type alias BoardDeleteResponse =
  { message: String }


-- Constructors

createPlayerAddForm : PlayerAddForm
createPlayerAddForm  =
  { name = Nothing }

createBoardAddForm : BoardAddForm
createBoardAddForm =
  { name = Nothing }

isPlayerAddFormValid : PlayerAddForm -> Bool
isPlayerAddFormValid playerAddForm =
  playerAddForm.name /= Nothing


-- Aux

playerAddFormToPlayer : PlayerAddForm -> Maybe Player
playerAddFormToPlayer playerAddForm =
  Maybe.map (\name -> { id = 0, name = name }) playerAddForm.name

boardAddFormToBoard : BoardAddForm -> Maybe Board
boardAddFormToBoard boardAddForm =
  Maybe.map (\name -> { id = 0, name = name }) boardAddForm.name