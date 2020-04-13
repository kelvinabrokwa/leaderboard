package biz.kelvin.leaderboard

// TODO: turn this into a real static config file
object GCP {
    val PROJECT_NAME = "leaderboard-274103"
    val SECRET_DATABASE_PASSWORD_NAME = "projects/874377989060/secrets/database_password/versions/1"
    val SECRET_DATABASE_PASSWORD_VERSION = 1
    val DB_URL_SCHEME = "postgres+pg8000"
    val DB_USER = "postgres"
    val DB_NAME = "leaderboard"
    val DB_INSTANCE_CONNECTION_NAME = "leaderboard-274103:us-east1:leaderboard"
}