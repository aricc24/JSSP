import std/[random, unittest, algorithm]
import goldenball/[types, moves, problem, goldenball]

#Indepent test of jssp, just cost how many elements are misplaced

proc misplaced(chain: seq[int]): float =
  for i, x in chain:
    if x != i:
      result += 1.0

proc shuffled(rng: var Rand): seq[int] =
  result = @[0, 1, 2, 3, 4, 5, 6, 7]
  rng.shuffle(result)

proc tProblem(): Problem =
  Problem(cost: misplaced, newChain: shuffled,
          coaches: @[genericCoach(mkSwap), genericCoach(mkInsert),
                     genericCoach(mkReverse)])

suite "Initialization":
  test "teams have the right shape and every cost is computed":
    var rng = initRand(42)
    let problem = tProblem()
    let teams = initTeams(problem, rng, 4, 12)
    check teams.len == 4
    for team in teams:
      check team.players.len == 12
      check team.coach in 0 ..< problem.coaches.len
      check team.points == 0
      for p in team.players:
        check p.cost == misplaced(p.chain)
        check p.withoutImprovement == 0

  test "players are sorted, captain first":
    var rng = initRand(42)
    let teams = initTeams(tProblem(), rng, 4, 12)
    for team in teams:
      for i in 1 ..< team.players.len:
        check team.players[i - 1].cost <= team.players[i].cost

  test "the same seed builds the same teams":
    var rng1 = initRand(7)
    var rng2 = initRand(7)
    let problem = tProblem()
    let a = initTeams(problem, rng1, 4, 12)
    let b = initTeams(problem, rng2, 4, 12)
    for t in 0 ..< a.len:
      check a[t].coach == b[t].coach
      for i in 0 ..< a[t].players.len:
        check a[t].players[i].chain == b[t].players[i].chain

let smallParams = Params(numTeams: 4, playersPerTeam: 4, maxSeasons: 20,
                           maxTrainingFailures: 200, customTrainingAfter: 5,
                           specialTransferAfter: 10)

suite "Main algorithm":
  test "the result is a valid player with its real cost":
    var rng = initRand(42)
    let r = solve(tProblem(), smallParams, rng)
    check r.best.chain.sorted == @[0, 1, 2, 3, 4, 5, 6, 7]
    check r.best.cost == misplaced(r.best.chain)
    check r.seasons in 1 .. smallParams.maxSeasons

  test "with swap coaches the toy problem is solved":
    var rng = initRand(42)
    let problem = Problem(cost: misplaced, newChain: shuffled,
                          coaches: @[genericCoach(mkSwap)])
    check solve(problem, smallParams, rng).best.cost == 0.0

  test "maxSeasons caps the run":
    var rng = initRand(42)
    var params = smallParams
    params.maxSeasons = 1
    check solve(tProblem(), params, rng).seasons == 1

  test "the same seed gives the same run":
    var rng1 = initRand(7)
    var rng2 = initRand(7)
    let a = solve(tProblem(), smallParams, rng1)
    let b = solve(tProblem(), smallParams, rng2)
    check a.best.chain == b.best.chain
    check a.seasons == b.seasons