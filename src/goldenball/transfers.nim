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