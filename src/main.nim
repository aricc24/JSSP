import std/[random, times, monotimes]
import jssp/io/instance_file
import jssp/models/[solution, graph]
import jssp/[cost, critical_path, neighborhoods]
import goldenball/[moves, problem, goldenball]

var inst: Instance
var g: DisjunctiveGraph
var ws: Workspace

proc evaluateChain(chain: seq[int]): Evaluation = 
  g.rebuild(inst, chain)
  evaluate(inst, g, ws)

proc jsspCost(chain: seq[int]): float = 
  cost(inst, evaluateChain(chain))

proc feasibleChain(rng: var Rand): seq[int] =
  randomFeasibleChain(inst, rng)

proc n5Coach(chain: seq[int], rng: var Rand, mv: var Move): bool =
  if evaluateChain(chain).nodesInCycle > 0:
    return false
  let path = criticalPath(ws)
  let moves = n5Moves(inst, path, criticalBlocks(inst, path), positionsOf(chain))
  if moves.len == 0:
    return false
  let s = moves[rng.rand(moves.high)]
  mv = Move(kind: mkSwap, a: s.i, b: s.j)
  true

proc n7Coach(chain: seq[int], rng: var Rand, mv: var Move): bool =
  if evaluateChain(chain).nodesInCycle > 0:
    return false
  let path = criticalPath(ws)
  let moves = n7Moves(inst, path, criticalBlocks(inst, path), positionsOf(chain))
  if moves.len == 0:
    return false
  let s = moves[rng.rand(moves.high)]
  mv = Move(kind: mkInsert, a: s.src, b: s.dst)
  true

  
proc printMachines(inst: Instance, chain: seq[int]) =
  let mc = toMachineChain(inst, chain)
  for machine in 0 ..< inst.numMachines:
    stdout.write "M", machine, ":"
    for pos in 0 ..< inst.numJobs:
      stdout.write " ", mc[machine, pos]
    stdout.write "\n"

proc main() = 
  inst = loadInstance("instances/JSSP_100_100.txt")
  inst.upperBound = inst.computeUpperBound   
  inst.lowerBound = inst.computeLowerBound 
  g = initGraph(inst)
  ws = initWorkspace(inst.numOps)

  let problem = 
          Problem(cost: jsspCost, 
                  newChain: feasibleChain,  
                  coaches: @[genericCoach(mkSwap), genericCoach(mkInsert), 
                              genericCoach(mkReverse), genericCoach(mkAdjacentSwap), 
                              n5Coach, n7Coach]
                  )
  
  let params = Params(numTeams: 5,
                     playersPerTeam: 12,
                      maxSeasons: 20,   
                      maxTrainingFailures: 550, 
                      customTrainingAfter: 10,
                      specialTransferAfter: 20)

  var rng = initRand(2411303423523123)
  let start = getMonoTime()
  let res = solve(problem, params, rng)
  let elapsed = (getMonoTime() - start).inMilliseconds

  let ev = evaluateChain(res.best.chain)
  echo "seasons:  ", res.seasons
  echo "cost:     ", res.best.cost
  echo "makespan: ", ev.makespan, " (nodes in cycle: ", ev.nodesInCycle, ")"
  echo "time:     ", elapsed.float / 1000.0, " s"

main()



