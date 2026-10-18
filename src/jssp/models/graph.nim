import ./instance
import ./solution

const NoNode* = -1

type
  DisjunctiveGraph* = object
    numMachines*: int
    machineNext*: seq[int]
    inDegree*: seq[int]
    lastOnMachine: seq[int]

func numNodes*(g: DisjunctiveGraph): int {.inline.} =
  g.machineNext.len

func jobNext*(g: DisjunctiveGraph, u: int): int {.inline.} =
  if (u + 1) mod g.numMachines == 0: 
    NoNode 
  else: 
    u + 1

iterator successors*(g: DisjunctiveGraph, u: int): int =
  let j = g.jobNext(u)

  if j != NoNode: 
    yield j

  let m = g.machineNext[u]
  
  if m != NoNode: 
    yield m
  
func buildGraph*(inst: Instance, mc: MachineChain): DisjunctiveGraph = 
  result.numMachines = inst.numMachines
  result.machineNext = newSeq[int](inst.numOps)
  result.inDegree = newSeq[int](inst.numOps)

  for u in 0 ..< inst.numOps: 
    if inst.posOf(u) > 0: 
      inc result.inDegree[u]

  for machine in 0 ..< inst.numMachines: 
    for pos in 0 ..< inst.numJobs: 
      let u = mc[machine, pos]
      
      if pos + 1 < inst.numJobs: 
        let v = mc[machine, pos + 1]
        result.machineNext[u] = v
        inc result.inDegree[v]
      else: 
        result.machineNext[u] = NoNode

func initGraph*(inst: Instance): DisjunctiveGraph =
  DisjunctiveGraph(numMachines: inst.numMachines,
                   machineNext: newSeq[int](inst.numOps),
                   inDegree: newSeq[int](inst.numOps),
                   lastOnMachine: newSeq[int](inst.numMachines))

func rebuild*(g: var DisjunctiveGraph, inst: Instance, chain: OperationChain) =
  for machine in 0 ..< inst.numMachines:
    g.lastOnMachine[machine] = NoNode

  for u in 0 ..< inst.numOps:
    g.machineNext[u] = NoNode
    g.inDegree[u] = if inst.posOf(u) > 0: 1 else: 0

  for u in chain:
    let machine = inst.ops[u].machine
    let prev = g.lastOnMachine[machine]
    if prev != NoNode:
      g.machineNext[prev] = u
      inc g.inDegree[u]
    g.lastOnMachine[machine] = u