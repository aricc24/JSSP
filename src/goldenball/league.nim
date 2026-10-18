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



