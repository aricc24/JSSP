import std/[sequtils, unittest]
import goldenball/[types, league]

proc teamOf(costs: seq[float]): Team =
  Team(players: costs.mapIt(Player(cost: it)))

proc checkRoundRobin(numTeams: int) =
  let days = roundRobin(numTeams)
  var count = newSeq[int](numTeams * numTeams)

  for day in days:
    var plays = newSeq[int](numTeams)
    for (a, b) in day:
      inc count[min(a, b) * numTeams + max(a, b)]
      inc plays[a]
      inc plays[b]
    for p in plays:
      check p <= 1
      
  for a in 0 ..< numTeams:
    for b in a + 1 ..< numTeams:
      check count[a * numTeams + b] == 1

suite "League":
  test "round robin with an even number of teams":
    check roundRobin(4).len == 3
    check roundRobin(4).allIt(it.len == 2)
    checkRoundRobin(4)

  test "round robin with an odd number of teams (one rests)":
    check roundRobin(5).len == 5
    check roundRobin(5).allIt(it.len == 2)
    checkRoundRobin(5)

  test "lower cost wins the duel and the match gives 3 points":
    var teams = @[teamOf(@[1.0, 2.0, 3.0]), teamOf(@[2.0, 3.0, 1.0])]
    playMatch(teams, 0, 1)                 
    check teams[0].points == 3
    check teams[1].points == 0

  test "equal costs score nothing and a draw gives 1 point each":
    var teams = @[teamOf(@[1.0, 2.0, 3.0]), teamOf(@[2.0, 2.0, 1.0])]
    playMatch(teams, 0, 1)                 
    check teams[0].points == 1
    check teams[1].points == 1

  test "points accumulate over matchdays":
    var teams = @[teamOf(@[1.0]), teamOf(@[2.0]), teamOf(@[3.0]), teamOf(@[4.0])]
    for day in roundRobin(4):
      playMatchday(teams, day)
    check teams.mapIt(it.points) == @[9, 6, 3, 0]