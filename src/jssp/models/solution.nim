import std/random
import ./instance

type 
  OperationChain* = seq[int]

  MachineChain* = object
    numJobs*: int
    order*: seq[int]

func `[]`*(mc: MachineChain, machine, pos: int): int {.inline.} =
  mc.order[machine * mc.numJobs + pos]

proc randomOperationChain*(inst: Instance, rng: var Rand): OperationChain =
  result = newSeq[int](inst.numOps)

  for i in 0 ..< inst.numOps:
    result[i] = i

  rng.shuffle(result)

func isPermutation*(chain: OperationChain, numOps:int): bool = 
  if chain.len != numOps: 
    return false

  var seen = newSeq[bool](numOps)
  for opIdx in chain: 
    if opIdx < 0 or opIdx >= numOps or seen[opIdx]: 
      return false
    seen[opIdx] = true

  return true

func toMachineChain*(inst: Instance, chain: OperationChain): MachineChain =
  result.numJobs = inst.numJobs
  result.order = newSeq[int](inst.numOps)
  var filled = newSeq[int](inst.numMachines)   
  
  for opIdx in chain:
    let machine = inst.ops[opIdx].machine
    result.order[machine * inst.numJobs + filled[machine]] = opIdx
    inc filled[machine]