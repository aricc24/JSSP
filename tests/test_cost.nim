import std/[unittest, os, random]
import jssp/io/instance_file
import jssp/models/[solution, graph]
import jssp/cost
import ./fixtures

const dataDir = currentSourcePath().parentDir / ".." / "instances"

proc graphOf(inst: Instance, chain: OperationChain): DisjunctiveGraph =
  inst.buildGraph(inst.toMachineChain(chain))

suite "cost 3x3":
  let inst = ft3x3()
  var ws = initWorkspace(inst.numOps)

  test "bounds from the known formulas":
    check inst.computeUpperBound == 24
    check inst.computeLowerBound == 10

  test "makespan 12, feasible":
    let ev = inst.evaluate(inst.graphOf(ganttChain), ws)
    check ev.makespan == 12
    check ev.nodesInCycle == 0
    check abs(inst.cost(ev) - 2.0 / 14.0) < 1e-9  

  test "cyclic solution is detected and penalized":
    let g = inst.graphOf(cyclicChain)
    check g.nodesInCycle(ws) == 9
    let ev = inst.evaluate(g, ws)
    check ev.nodesInCycle == 9
    check inst.cost(ev) > 1.0   

suite "cost 40x40":
  let inst = loadInstance(dataDir / "JSSP_40_40.txt")
  var ws = initWorkspace(inst.numOps)

  test "chain that respects job order is always feasible":
    var chain: OperationChain
    for k in 0 ..< inst.numMachines:
      for job in 0 ..< inst.numJobs:
        chain.add inst.opIndex(job, k)
    let ev = inst.evaluate(inst.graphOf(chain), ws)
    check ev.nodesInCycle == 0
    check ev.makespan >= inst.computeLowerBound
    check ev.makespan <= inst.computeUpperBound

  test "both Kahn versions agree on random solutions":
    var rng = initRand(123)
    for _ in 1 .. 100:
      let g = inst.graphOf(inst.randomOperationChain(rng))
      let cycles = g.nodesInCycle(ws)
      check inst.evaluate(g, ws).nodesInCycle == cycles