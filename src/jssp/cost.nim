import ./models/[instance, graph]
import ./feasibility
export feasibility

type 
  Evaluation* = object
    makespan*: int
    nodesInCycle*: int

func evaluate*(inst: Instance, g: DisjunctiveGraph, ws: var Workspace): Evaluation =
  let n = g.numNodes
  var head, tail = 0
  ws.lastNode = NoNode

  for u in 0 ..< n:
    ws.inDegree[u] = g.inDegree[u]
    ws.finish[u] = 0
    ws.critPred[u] = NoNode

    if ws.inDegree[u] == 0: 
      ws.finish[u] = inst.ops[u].duration
      ws.queue[tail] = u 
      inc tail
  
  while head < tail: 
    let u = ws.queue[head]
    inc head

    if ws.finish[u] > result.makespan:
      result.makespan = max(result.makespan, ws.finish[u])
      ws.lastNode = u

    for v in g.successors(u): 
      let candidate = ws.finish[u] + inst.ops[v].duration

      if candidate > ws.finish[v]:
        ws.finish[v] = candidate
        ws.critPred[v] = u 
      dec ws.inDegree[v]
      
      if ws.inDegree[v] == 0: 
        ws.queue[tail] = v 
        inc tail
  
  result.nodesInCycle = n - tail

func computeUpperBound*(inst: Instance): int =
  for op in inst.ops: 
    result += op.duration

func computeLowerBound*(inst: Instance): int = 
  var machineLoad = newSeq[int](inst.numMachines)

  for job in 0 ..< inst.numJobs: 
    var jobLoad = 0

    for k in 0 ..< inst.numMachines: 
      let o = inst.op(job, k)
      jobLoad += o.duration
      machineLoad[o.machine] += o.duration
    result = max(result, jobLoad)

  result = max(result, max(machineLoad))

func cost*(inst: Instance, ev: Evaluation): float = 
  let lb = inst.lowerBound.float
  let ub = inst.upperBound.float
  (ev.makespan.float - lb) / (ub - lb) + lb * ev.nodesInCycle.float  
