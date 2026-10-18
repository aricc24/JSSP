import ./models/graph

type
  Workspace* = object
    inDegree*: seq[int]
    finish*: seq[int]
    queue*: seq[int]
    critPred*: seq[int]
    lastNode*: int

func initWorkspace*(numNodes: int): Workspace = 
  Workspace(inDegree: newSeq[int](numNodes),
            finish: newSeq[int](numNodes),
            queue: newSeq[int](numNodes),
            critPred: newSeq[int](numNodes), 
            lastNode: NoNode 
  )

func nodesInCycle*(g: DisjunctiveGraph, ws: var Workspace): int =
  let n = g.numNodes
  var head, tail = 0

  for u in 0 ..< n: 
    ws.inDegree[u] = g.inDegree[u]
    if ws.inDegree[u] == 0: 
      ws.queue[tail]  = u 
      inc tail
    
  while head < tail: 
    let u = ws.queue[head]
    inc head
    for v in g.successors(u):
      dec ws.inDegree[v]
      if ws.inDegree[v] == 0: 
        ws.queue[tail] = v 
        inc tail
  
  n - tail

func isFeasible*(g: DisjunctiveGraph, ws: var Workspace): bool =
  g.nodesInCycle(ws) == 0


 