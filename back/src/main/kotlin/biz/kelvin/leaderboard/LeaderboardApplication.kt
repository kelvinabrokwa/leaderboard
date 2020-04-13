package biz.kelvin.leaderboard

import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.web.bind.annotation.*

data class Player(val id: Int, val name: String)

data class Board(val id: Int, val name: String)

object Players : Table() {
    val id = integer("id").autoIncrement()
    val name = varchar("name", length = 50)

    override val primaryKey = PrimaryKey(id)
}

object Boards : Table() {
    val id = integer("id").autoIncrement()
    val name = varchar("name", length = 100)

    override val primaryKey = PrimaryKey(id)
}

fun rowToPlayer(row: ResultRow) =
        Player(id = row[Players.id], name = row[Players.name])

fun rowToBoard(row: ResultRow) =
        Board(id = row[Boards.id], name = row[Boards.name])

@RestController
@CrossOrigin
class AppController {
    //
    // Players
    //

    @GetMapping("/players")
    fun playersList() = transaction {
        Players.selectAll().map { rowToPlayer(it) }
    }

    @PostMapping("/players")
    fun playersAdd(@RequestBody player: Player) {
        transaction {
            Players.insert {
                it[name] = player.name
            }
        }
    }

    //
    // Boards
    //

    @GetMapping("/boards")
    fun boardList() = transaction {
        Boards.selectAll().map { rowToBoard(it) }
    }
}

@SpringBootApplication
class LeaderboardApplication

fun main(args: Array<String>) {
    Database.connect(
            url = "jdbc:postgresql://localhost:5433/${GCP.DB_NAME}",
            driver = "org.postgresql.Driver",
            user = GCP.DB_USER,
            password = getGcpDbPassword())

    transaction {
        addLogger(StdOutSqlLogger)

        // TODO: Should this be removed at some point?
        SchemaUtils.create(Players, Boards)
    }

    runApplication<LeaderboardApplication>(*args)
}
