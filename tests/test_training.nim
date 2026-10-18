import std/[algorithm, random, unittest]
import goldenball/[types, moves, problem, training]

proc misplaced(chain: seq[int]): float =
  for i, x in chain:
    if x != i:
      result += 1.0

proc noMoves(chain: seq[int], rng: var Rand, mv: var Move): bool =
  false

proc playerOf(chain: seq[int]): Player =
  Player(chain: chain, cost: misplaced(chain))

let tproblem = Problem(cost: misplaced, coaches: @[genericCoach(mkSwap)])

suite "Conventional training":
  test "training improves a player and keeps its cost up to date":
    var rng = initRand(42)
    var p = playerOf(@[7, 6, 5, 4, 3, 2, 1, 0])
    check p.train(tproblem.coaches[0], tproblem, rng, 1000)
    check p.cost == misplaced(p.chain)
    check p.chain.sorted == @[0, 1, 2, 3, 4, 5, 6, 7]
    check p.cost == 0.0

  test "a coach without moves leaves the player untouched":
    var rng = initRand(42)
    var p = playerOf(@[1, 0, 2, 3])
    check not p.train(noMoves, tproblem, rng, 1000)
    check p.chain == @[1, 0, 2, 3]
    check p.cost == 2.0

  test "trainTeam counts sessions without improvement and sorts the team":
    var rng = initRand(42)
    var team = Team(coach: 0, players: @[playerOf(@[0, 1, 2, 3]),
                                         playerOf(@[3, 2, 1, 0])])
    trainTeam(team, tproblem, rng, 1000)
    for p in team.players:
      check p.cost == 0.0
    check team.players[0].withoutImprovement == 1   
    check team.players[1].withoutImprovement == 0   