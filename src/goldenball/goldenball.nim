import std/random
import ./[types, problem, training, league, transfers]

proc newPlayer(problem: Problem, rng: var Rand): Player = 
  result.chain = problem.newChain(rng)
  result.cost = problem.cost(result.chain)

proc initTeams*(problem: Problem, rng: var Rand, numTeams: int, 
                playersPerTeam: int): seq[Team] =
  result = newSeq[Team](numTeams)

  for team in result.mitems: 
    team.coach = rng.rand(problem.coaches.high)
    team.players = newSeq[Player](playersPerTeam)
    for player in team.players.mitems: 
      player = newPlayer(problem, rng)
    team.sortPlayers()

type
  Params* = object
    numTeams*: int
    playersPerTeam*: int
    maxSeasons*: int
    maxTrainingFailures*: int
    custumTrainingAfter*: int
    specialTransferAfter*: int
  
  RunResult* = object
    best*: Player
    seasons*: int

  Snapshot = object
    sumQuality: float
    sumCaptains: float
    best: float

func snapshot(teams: seq[Team]): Snapshot = 
  result.best = Inf 
  for team in teams: 
    result.sumQuality += team.quality
    result.sumCaptains += team.captain.cost
    result.best = min(result.best, team.captain.cost)

func improves(now, before: Snapshot): bool =
  now.sumQuality < before.sumQuality or
    now.sumCaptains < before.sumCaptains or
      now.best < before.best

