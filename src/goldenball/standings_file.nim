import std/strformat
import ./types

proc writeStandings*(path: string, rows: seq[Standing]) =
  let f = open(path, fmWrite)
  defer: f.close()
  f.writeLine "pos,team,points,wins,draws,losses,captain_cost"
  for i, r in rows:
    f.writeLine &"{i + 1},Team {r.team},{r.points},{r.wins},{r.draws},{r.losses},{r.captainCost}"