import ./types

func roundRobin*(numTeams: int): seq[seq[(int, int)]] = 
  let n = 
    if numTeams mod 2 == 0: 
      numTeams
    else: 
      numTeams + 1
  var ring = newSeq[int](n)

  for i in 0 ..< n: 
    ring[i] = i 
  
  for day in 0 ..< n - 1: 
    var matches: seq[(int, int)]
    for i in 0 ..< n div 2: 
      let rm = ring[i]
      let brc = ring[n - 1 - i]
      if rm < numTeams and brc < numTeams: 
        matches.add((rm, brc))
    result.add matches
  
  let last = ring[n - 1]

  for i in countdown(n - 1, 2): 
    ring[i] = ring[i - 1]
  ring[1] = last

func playMatch*(teams: var seq[Team], p1: int, p2: int) = 
  var goalsP1 = 0
  var goalsP2 = 0

  for i in 0 ..< teams[p1].players.len: 
    let cp1 = teams[p1].players[i].cost
    let cp2 = teams[p2].players[i].cost

    if cp1 < cp2: 
      inc goalsP1
    elif cp2 < cp1:
      inc goalsP2
    
  if goalsP1 > goalsP2: 
    teams[p1].points += 3
  elif goalsP2 > goalsP1: 
    teams[p2].points += 3
  else:
    teams[p1].points += 1
    teams[p2].points += 1 
      
func playMatchday*(teams: var seq[Team], matches: seq[(int, int)]) =
  for (p1, p2) in matches: 
    playMatch(teams, p1, p2)
