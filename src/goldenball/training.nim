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

type
  HelpBuffer* = object
    child: seq[int]
    taken: seq[bool]

func initHelpBuffer*(n: int): HelpBuffer =
  HelpBuffer(child: newSeq[int](n), taken: newSeq[bool](n))

func goldenHelp*(chain: var seq[int], captain: seq[int], buf: var HelpBuffer) =
  let n = chain.len
  let half = n div 2

  for x in 0 ..< n: 
    buf.taken[x]  = false

  for i in 0 ..< half:     
    let x = captain[i]
    buf.child[i] = x
    buf.taken[x] = true

  var k = half

  for x in chain: 
    if not buf.taken[x]: 
      buf.child[k] = x
      inc k 

  swap(chain, buf.child) 

proc customTrain*(team: var Team, problem: Problem, buf: var HelpBuffer, 
                  customAfter: int) =
  for i in 1 ..< team.players.len: 
    if team.players[i].withoutImprovement >= customAfter: 
      goldenHelp(team.players[i].chain, team.players[0].chain, buf)
      team.players[i].cost = problem.cost(team.players[i].chain)
  
  team.sortPlayers()