class Player:
    def __init__(self, id, name):
        self.id = id
        self.name = name

    @staticmethod
    def of_dict(d):
        return Player(d['id'], d['name'])

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
        }

    def __eq__(self, player):
        return self.name == player.name

    def __hash__(self):
        return hash(self.name)


class Board:
    def __init__(self, id, name):
        self.id = id
        self.name = name

    @staticmethod
    def of_dict(d):
        return Board(d['id'], d['name'])

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name
        }