import std/random
import ./[types, moves, problem]

proc train*(player: var Player, coach: Coach, problem: Problem, 
            rng: var Rand, maxFailures: int): bool =
  var failures = 0
  var mv: Move

  while failures < maxFailures: 
    if not coach(player.chain, rng, mv): 
      break
    player.chain.apply(mv)
    
    let c = problem.cost(player.chain)

    if c < player.cost: 
      player.cost = c 
      failures = 0
      result = true
    else: 
      player.chain.undo(mv)
      inc failures

proc trainTeam*(team: var Team, problem: Problem, rng: var Rand, maxFailures: int) =
  let coach = problem.coaches[team.coach]

  for player in team.players.mitems: 
    if player.train(coach, problem, rng, maxFailures): 
      player.withoutImprovement = 0
    else: 
      inc player.withoutImprovement
      
  team.sortPlayers()