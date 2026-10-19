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
    customTrainingAfter*: int
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

proc playSeason(teams: var seq[Team], problem: Problem, params: Params, 
                schedule: seq[seq[(int, int)]], buf: var HelpBuffer,
                rng: var Rand) =
  for team in teams.mitems: 
    team.points = 0
  
  for half in 0 ..< 2: 
    for matches in schedule: 
      for team in teams.mitems: 
        trainTeam(team, problem, rng, params.maxTrainingFailures)
        customTrain(team, problem, buf, params.customTrainingAfter)
      specialTransfers(teams, rng, params.specialTransferAfter)
      playMatchday(teams, matches)

    let order = standings(teams)
    seasonTransfers(teams, order)
    dismissCoaches(teams, order, problem.coaches.len, rng)

proc solve*(problem: Problem, params: Params, rng: var Rand): RunResult =
  var teams = initTeams(problem, rng, params.numTeams, params.playersPerTeam)
  let schedule = roundRobin(params.numTeams)
  var buf = initHelpBuffer(teams[0].players[0].chain.len)
  var before = snapshot(teams)

  while result.seasons < params.maxSeasons: 
    playSeason(teams, problem, params, schedule, buf, rng)
    inc result.seasons
    let now = snapshot(teams)
    if not now.improves(before): 
      break 
    before = now
  
  var b = 0
  for t in 1 ..< teams.len: 
    if teams[t].captain.cost < teams[b].captain.cost: 
      b = t
  result.best = teams[b].captain