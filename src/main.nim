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

##pros n5 y n7

proc main() = 
  inst = loadInstance("instances/JSSP_40_40.txt")
  g = initGraph(inst)
  ws = initWorkspace(inst.numOps)

  let problem = 
          Problem(cost: jsspCost, 
                  newChain: feasibleChain,  
                  coaches: @[genericCoach(mkSwap), genericCoach(mkInsert), 
                              genericCoach(mkReverse), genericCoach(mkAdjacentSwap)]
                  )
  
  let params = Params(numTeams: 4,
                     playersPerTeam: 12,
                      maxSeasons: 5,   
                      maxTrainingFailures: 500, 
                      customTrainingAfter: 5,
                      specialTransferAfter: 10)

  var rng = initRand(9433578794396893)
  let start = getMonoTime()
  let res = solve(problem, params, rng)
  let elapsed = (getMonoTime() - start).inMilliseconds

  let ev = evaluateChain(res.best.chain)
  echo "seasons:  ", res.seasons
  echo "cost:     ", res.best.cost
  echo "makespan: ", ev.makespan, " (nodes in cycle: ", ev.nodesInCycle, ")"
  echo "time:     ", elapsed.float / 1000.0, " s"

main()



