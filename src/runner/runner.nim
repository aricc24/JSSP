import std/random
import ../goldenball/[problem, goldenball]

type
  MultiRunResult* = object
    bestChain*: seq[int]
    bestCost*: float
    bestSeed*: int
    bestSeasons*: int
    feasibleRuns*: int

proc runMultiple*(problem: Problem, params: Params, runs: int, baseSeed: int, processId: int,
                  isFeasible: proc(chain: seq[int]): bool): MultiRunResult =
  result.bestCost = Inf
  result.bestSeed = baseSeed

  for runIndex in 0 ..< runs:
    let seed = baseSeed + runIndex
    var rng = initRand(seed)
    let res = solve(problem, params, rng)
    let feasible = isFeasible(res.best.chain)

    if feasible:
      inc result.feasibleRuns

    if res.best.cost < result.bestCost:
      result.bestChain = res.best.chain
      result.bestCost = res.best.cost
      result.bestSeed = seed
      result.bestSeasons = res.seasons

      echo "[Process ", processId, "] ",
           "New best: ", result.bestCost,
           " | Seed: ", seed,
           " | Seasons: ", res.seasons,
           " | Feasible runs: ", result.feasibleRuns, "/", runIndex + 1,
           " | Run: ", runIndex + 1, "/", runs,
           " | Is feasible: ", (if feasible: "YES" else: "NO")