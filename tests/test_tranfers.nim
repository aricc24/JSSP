import std/[random, sequtils, unittest]
import goldenball/[types, transfers]

proc teamOf(costs: seq[float]): Team =
  Team(players: costs.mapIt(Player(cost: it)))

func costs(team: Team): seq[float] =
  team.players.mapIt(it.cost)

suite "Transfers":
  test "standings sort by points and keep ties in index order":
    var teams = @[teamOf(@[0.0]), teamOf(@[0.0]), teamOf(@[0.0]), teamOf(@[0.0])]
    for t, p in [3, 9, 0, 6]:
      teams[t].points = p
    check standings(teams) == @[1, 3, 0, 2]
    for t, p in [3, 3, 0, 0]:
      teams[t].points = p
    check standings(teams) == @[0, 1, 2, 3]

  test "season transfers mirror the table":
    var teams = @[teamOf(@[0.0, 1.0, 2.0]), teamOf(@[10.0, 11.0, 12.0]),
                  teamOf(@[20.0, 21.0, 22.0]), teamOf(@[30.0, 31.0, 32.0])]
    seasonTransfers(teams, @[0, 1, 2, 3])
    
    check teams[0].costs == @[0.0, 1.0, 30.0]    
    check teams[3].costs == @[2.0, 31.0, 32.0]
    check teams[1].costs == @[10.0, 12.0, 21.0]  
    check teams[2].costs == @[11.0, 20.0, 22.0]

  test "only the bottom half changes coach, always to a different one":
    var rng = initRand(42)

    for _ in 0 ..< 100:
      var teams = @[teamOf(@[0.0]), teamOf(@[0.0]), teamOf(@[0.0]), teamOf(@[0.0])]
      dismissCoaches(teams, @[0, 1, 2, 3], 3, rng)
      
      check teams[0].coach == 0
      check teams[1].coach == 0
      check teams[2].coach in 1 .. 2
      check teams[3].coach in 1 .. 2

  test "a stuck player moves to another team and restarts its counter":
    var rng = initRand(42)
    var teams = @[teamOf(@[0.5, 1.0, 2.0]), teamOf(@[3.0, 4.0, 5.0])]
    teams[0].players[0].withoutImprovement = 10
    specialTransfers(teams, rng, 10)

    check 0.5 notin teams[0].costs
    check 0.5 in teams[1].costs
    check teams[0].players.len == 3
    check teams[1].players.len == 3

    for team in teams:
      for p in team.players:
        check p.withoutImprovement == 0