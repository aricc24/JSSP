import std/[random, unittest]
import jssp/models/[instance, solution, graph]
import jssp/cost
import ./fixtures

suite "Random feasible chain":
  test "it is a permutation and never has cycles":
    let inst = ft3x3()
    var rng = initRand(42)
    var g = initGraph(inst)
    var ws = initWorkspace(inst.numOps)
    for _ in 0 ..< 100:
      let chain = randomFeasibleChain(inst, rng)
      check chain.isPermutation(inst.numOps)
      g.rebuild(inst, chain)
      check evaluate(inst, g, ws).nodesInCycle == 0