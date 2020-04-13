import flask_cors
import flask_json
import flask_sqlalchemy
import sqlalchemy
import os
import urllib
from flask import Flask, request
from google.cloud import secretmanager
from typing import List

from leaderboard import models, errors, config


app = Flask(__name__)

# Enable CORS
flask_cors.CORS(app)

# Setup JSON handling
flask_json.FlaskJSON(app)

# Setup database
def get_db_url(gcp_from_local=False):
    if 'GOOGLE_CLOUD_PROJECT' not in os.environ and not gcp_from_local:
        return 'postgresql://kelvin@localhost:5432/leaderboard'

    # Fetch the database password from the GCP secret manager
    client = secretmanager.SecretManagerServiceClient()
    name = client.secret_version_path(
        config.GCP.PROJECT_NAME,
        config.GCP.SECRET_DATABASE_PASSWORD_ID,
        config.GCP.SECRET_DATABASE_PASSWORD_VERSION
    )
    response = client.access_secret_version(name)
    password = response.payload.data.decode('UTF-8')

    scheme = config.GCP.DB_URL_SCHEME
    user = config.GCP.DB_USER
    db_name = config.GCP.DB_NAME
    instance_connection_name = config.GCP.DB_INSTANCE_CONNECTION_NAME

    if gcp_from_local:
        # This assumes we are running the proxy with
        # $ ./cloud_sql_proxy -instances=leaderboard-274103:us-east1:leaderboard=tcp:5433
        # https://cloud.google.com/sql/docs/postgres/connect-external-app
        return f'postgres://{user}:{password}@localhost:5433/{db_name}'

    return f'{scheme}://{user}:{password}@/{db_name}?unix_sock=/cloudsql/{instance_connection_name}/.s.PGSQL.5432'

app.config['SQLALCHEMY_DATABASE_URI'] = get_db_url(gcp_from_local=True)
app.config['SQLALCHEMY_ECHO'] = True
db = flask_sqlalchemy.SQLAlchemy(app)


class Player(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String, unique=True, nullable=False)

    def to_model(self):
        return models.Player(id=self.id, name=self.name)

    @staticmethod
    def from_model(player : models.Player, omit_id : bool = False):
        return Player(id=None if omit_id else player.id, name=player.name)

    @staticmethod
    def add(player : models.Player):
        db.session.add(Player.from_model(player, omit_id=True))
        db.session.commit()

    def __repr__(self):
        return f'<Player {self.name}>'


class Board(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String, unique=True, nullable=False)

    def to_model(self):
        return models.Board(id=self.id, name=self.name)

    @staticmethod
    def from_model(board : models.Board, omit_id : bool = False):
        return Board(id=None if omit_id else board.id, name=board.name)

    @staticmethod
    def add(board : models.Board):
        db.session.add(Board.from_model(board, omit_id=True))
        db.session.commit()

    @staticmethod
    def delete(id_ : int):
        db.session.query(Board).filter(Board.id == id_).delete(synchronize_session=False)
        db.session.commit()

    def __repr__(self):
        return f'<Board {self.name}>'


class PostgresStore:
    def __init__(self):
        pass

    def list_players(self) -> List[models.Player]:
        return [Player.to_model(player) for player in Player.query.all()]

    def list_boards(self) -> List[models.Board]:
        return [Board.to_model(board) for board in Board.query.all()]

    def player_add(self, player : models.Player):
        Player.add(player)

    def board_add(self, board : models.Board):
        Board.add(board)

    def board_delete(self, board_id : int):
        Board.delete(board_id)



store = PostgresStore()

# Create database tables
# TODO: Remove this once we do provisioning correctly
db.create_all()
db.session.commit()


#
# Route handlers
#

@app.route('/players', methods=['GET'])
@flask_json.as_json
def players_get():
    return {
        'players': [player.to_dict() for player in store.list_players()]
    }


@app.route('/players', methods=['POST'])
@flask_json.as_json
def player_post():
    try:
        store.player_add(models.Player.of_dict(request.get_json()['player']))
    except errors.PlayerExistsException:
        raise flask_json.JsonError(message='player already exists')

    return {
        'message': 'ok'
    }


@app.route('/boards', methods=['GET'])
@flask_json.as_json
def boards_get():
    return {
        'boards': [board.to_dict() for board in store.list_boards()]
    }


@app.route('/boards', methods=['POST'])
@flask_json.as_json
def boards_post():
    try:
        store.board_add(models.Board.of_dict(request.get_json()['board']))
    except errors.BoardExistsException:
        raise flask_json.JsonError(message='board already exists')

    return {
        'message': 'ok'
    }


@app.route('/boards/<int:board_id>', methods=['DELETE'])
@flask_json.as_json
def boards_delete(board_id):
    store.board_delete(board_id)

    return {
        'message': 'ok'
    }