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
    stallSeasons*: int
  
  RunResult* = object
    best*: Player
    seasons*: int
    standings*: seq[Standing]

  ImproveProc* = proc(season: int, best: Player)

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

func bestCaptain(teams: seq[Team]): Player =
  var b = 0
  for t in 1 ..< teams.len: 
    if teams[t].captain.cost < teams[b].captain.cost: 
      b = t
  teams[b].captain

proc playSeason(teams: var seq[Team], problem: Problem, params: Params, 
                schedule: seq[seq[(int, int)]], buf: var HelpBuffer,
                rng: var Rand) =
  for team in teams.mitems: 
    team.points = 0
    team.wins = 0
    team.draws = 0
    team.losses = 0
  
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

func finalStandings(teams: seq[Team]): seq[Standing] =
  for t in standings(teams):
    result.add Standing(team: t + 1,
                        points: teams[t].points,
                        wins: teams[t].wins,
                        draws: teams[t].draws,
                        losses: teams[t].losses,
                        captainCost: teams[t].captain.cost)

proc solve*(problem: Problem, params: Params, rng: var Rand,
            onImprove: ImproveProc = nil): RunResult =
  var teams = initTeams(problem, rng, params.numTeams, params.playersPerTeam)
  let schedule = roundRobin(params.numTeams)
  var buf = initHelpBuffer(teams[0].players[0].chain.len)
  var before = snapshot(teams)
  var stall = 0
  var bestCost = before.best

  while result.seasons < params.maxSeasons: 
    playSeason(teams, problem, params, schedule, buf, rng)
    inc result.seasons
    let now = snapshot(teams)

    if now.best < bestCost:
      bestCost = now.best
      if onImprove != nil:
        onImprove(result.seasons, teams.bestCaptain)

    if now.improves(before):
      stall = 0 
      before = now
    else: 
      inc stall
      if stall >= params.stallSeasons:
        break
  
  result.best = teams.bestCaptain
  result.standings = finalStandings(teams)