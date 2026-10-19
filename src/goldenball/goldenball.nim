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