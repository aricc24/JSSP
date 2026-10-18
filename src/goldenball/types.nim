type 
  Player* = object
    chain*: seq[int]
    cost*: float
    withoutImprovement*: int

  Team* = object
    players*: seq[Player]
    coach*: int 
    points*: int

func sortPlayers*(team: var Team) =
  for i in 1 ..< team.players.len: 
    var j = i
    while j > 0 and team.players[j].cost < team.players[j - 1].cost: 
      swap(team.players[j], team.players[j - 1])
      dec j 

func capitan*(team: Team): lent Player = 
  team.players[0]

func quality*(team: Team): float =
  for p in team.players: 
    result += p.cost
  
  result / team.players.len.float
