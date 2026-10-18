import std/algorithm
import ./models/[instance, graph]
import ./feasibility

type
  Block* = object
    first*: int
    last*: int   

func criticalPath*(ws: Workspace): seq[int] =
  var u = ws.lastNode

  while u != NoNode:
    result.add u
    u = ws.critPred[u]

  result.reverse()

func criticalBlocks*(inst: Instance, path: seq[int]): seq[Block] =
  var start = 0
  
  for i in 1 .. path.len:
    if i == path.len or inst.ops[path[i]].machine != inst.ops[path[start]].machine:
      result.add Block(first: start, last: i - 1)
      start = i