import std/random
import ../jssp/cost
import ../goldenball/[problem, goldenball]

type
  MultiRunResult* = object
    bestChain*: seq[int]
    bestCost*: float
    bestMakespan*: int
    bestNodesInCycle*: int
    bestSeed*: int
    bestSeasons*: int

proc runMultiple*(problem: Problem, params: Params, runs: int, baseSeed: int, processId: int,
                  evalChain: proc(chain: seq[int]): Evaluation): MultiRunResult =
  result.bestCost = Inf
  result.bestSeed = baseSeed

  for runIndex in 0 ..< runs:
    let seed = baseSeed + runIndex
    var rng = initRand(seed)
    let res = solve(problem, params, rng)
    let ev = evalChain(res.best.chain)

    if res.best.cost < result.bestCost:
      result.bestChain = res.best.chain
      result.bestCost = res.best.cost
      result.bestMakespan = ev.makespan
      result.bestNodesInCycle = ev.nodesInCycle
      result.bestSeed = seed
      result.bestSeasons = res.seasons

      echo "[Process ", processId, "] ",
           "New best: ", result.bestCost,
           " | Makespan: ", ev.makespan,
           " | Nodes in cycle: ", ev.nodesInCycle,
           " | Seed: ", seed,
           " | Seasons: ", res.seasons,
           " | Run: ", runIndex + 1, "/", runs