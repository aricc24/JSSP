import std/random
import ./types

func standings*(teams: seq[Team]): seq[int] = 
  result = newSeq[int](teams.len)

  for t in 0 ..< teams.len: 
    result[t] = t
  
  for i in 1 ..< result.len: 
    var j = i
    while j > 0 and teams[result[j]].points > teams[result[j - 1]].points: 
      swap(result[j], result[j - 1])

func seasonTransfers*(teams: var seq[Team], order: seq[int]) =
  let last = teams[0].players.high

  for k in 0 ..< teams.len div 2: 
    let top = order[k]
    let bottom = order[teams.len - 1 - k]
    swap(teams[top].players[last - k], teams[bottom].players[k])
    teams[top].sortPlayers()
    teams[bottom].sortPlayers()

proc dismissCoaches*(teams: var seq[Team], order: seq[int], 
                      numCoaches: int, rng: var Rand) = 
  if numCoaches < 2: 
    return

  for k in (teams.len + 1) div 2 ..< teams.len: 
    let t = order[k]
    var c = rng.rand(numCoaches)
    if c >= teams[t].coach: 
      inc c
    teams[t].coach = c

proc specialTransfers*(teams: var seq[Team], rng: var Rand, specialAfter: int) = 
  if teams.len < 2: 
    return

  for t in 0 ..< teams.len: 
    for i in 0 ..< teams[t].players.len: 
      if teams[t].players[i].withoutImprovement >= specialAfter: 
        var other = rng.rand(teams.len - 2)
        if other >= t: 
          inc other
        let j = rng.rand(teams[other].players.high)
        teams[t].players[i].withoutImprovement = 0
        swap(teams[t].players[i], teams[other].players[j])
    
    for team in teams.mitems: 
      team.sortPlayers