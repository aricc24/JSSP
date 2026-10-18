import std/unittest
import goldenball/types

func player(cost: float): Player =
  Player(chain: @[], cost: cost)

suite "Team basics":
  var team = Team(players: @[player(5.0), player(2.0), player(9.0), player(1.0)])
  team.sortPlayers()

  test "players are sorted best first":
    check team.players[0].cost == 1.0
    check team.players[1].cost == 2.0
    check team.players[2].cost == 5.0
    check team.players[3].cost == 9.0

  test "captain is the best player":
    check team.captain.cost == 1.0

  test "quality is the average cost":
    check team.quality == (1.0 + 2.0 + 5.0 + 9.0) / 4.0