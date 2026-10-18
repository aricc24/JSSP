import std/[unittest, os]
import jssp/io/instance_file
import jssp/models/[solution, graph]
import jssp/[cost, critical_path, neighborhoods]
import ./fixtures

const dataDir = currentSourcePath().parentDir / ".." / "instances"

proc evalChain(inst: Instance, chain: OperationChain, ws: var Workspace): Evaluation =
  inst.evaluate(inst.buildGraph(inst.toMachineChain(chain)), ws)

suite "N5 3x3":
  let inst = ft3x3()
  var ws = initWorkspace(inst.numOps)
  discard inst.evalChain(ganttChain, ws)
  let path = ws.criticalPath
  let moves = inst.n5Moves(path, inst.criticalBlocks(path), ganttChain.positionsOf)

  test "positions are the inverse of the chain":
    let pos = ganttChain.positionsOf
    
    for position, op in ganttChain:
      check pos[op] == position

  test "single move: O11 - O21":
    check moves == @[SwapMove(i: 0, j: 2)]

  test "the move keeps the solution feasible":
    var chain = ganttChain
    swap(chain[moves[0].i], chain[moves[0].j])
    check inst.evalChain(chain, ws).nodesInCycle == 0

suite "N5 40x40":
  let inst = loadInstance(dataDir / "JSSP_40_40.txt")
  var ws = initWorkspace(inst.numOps)
  var chain: OperationChain
  
  for k in 0 ..< inst.numMachines:        
    for job in 0 ..< inst.numJobs:
      chain.add inst.opIndex(job, k)

  test "every N5 move keeps feasibility and undo restores the chain":
    discard inst.evalChain(chain, ws)
    let path = ws.criticalPath
    let moves = inst.n5Moves(path, inst.criticalBlocks(path), chain.positionsOf)

    check moves.len > 0
    let original = chain

    for mv in moves:
      swap(chain[mv.i], chain[mv.j])                       
      check inst.evalChain(chain, ws).nodesInCycle == 0    
      swap(chain[mv.i], chain[mv.j])  

    check chain == original

proc applyInsert(chain: var OperationChain, src, dst: int) =
  let x = chain[src]
  if src < dst:
    for p in src ..< dst: chain[p] = chain[p + 1]
  else:
    for p in countdown(src, dst + 1): chain[p] = chain[p - 1]
  chain[dst] = x

suite "N7 3x3":
  let inst = ft3x3()
  var ws = initWorkspace(inst.numOps)
  discard inst.evalChain(ganttChain, ws)
  let path = ws.criticalPath
  let moves = inst.n7Moves(path, inst.criticalBlocks(path), ganttChain.positionsOf)

  test "single move: O11 goes after O21":
    check moves == @[InsertMove(src: 0, dst: 2)]

  test "same machine order as the N5 swap":
    var inserted = ganttChain
    inserted.applyInsert(moves[0].src, moves[0].dst)
    var swapped = ganttChain
    swap(swapped[0], swapped[2])
    check inst.evalChain(inserted, ws) == inst.evalChain(swapped, ws)

suite "N7 40x40":
  let inst = loadInstance(dataDir / "JSSP_40_40.txt")
  var ws = initWorkspace(inst.numOps)
  var chain: OperationChain

  for k in 0 ..< inst.numMachines:
    for job in 0 ..< inst.numJobs:
      chain.add inst.opIndex(job, k)

  test "undo restores the chain after every move":
    discard inst.evalChain(chain, ws)
    let path = ws.criticalPath
    let moves = inst.n7Moves(path, inst.criticalBlocks(path), chain.positionsOf)

    check moves.len > 0
    
    let original = chain

    for mv in moves:
      chain.applyInsert(mv.src, mv.dst)     
      discard inst.evalChain(chain, ws)     
      chain.applyInsert(mv.dst, mv.src)     
    check chain == original