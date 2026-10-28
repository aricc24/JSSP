import std/[random, times, monotimes, parseopt, strutils, os]
import jssp/io/instance_file
import jssp/models/[solution, graph]
import jssp/[cost, critical_path, neighborhoods]
import goldenball/[moves, problem, goldenball]
import runner/runner

var inst: Instance
var g: DisjunctiveGraph
var ws: Workspace

type
  CliOptions = object
    instancePath: string
    runs: int
    seed: int
    processId: int

    numTeams: int
    playersPerTeam: int
    maxSeasons: int
    maxTrainingFailures: int
    customTrainingAfter: int
    specialTransferAfter: int

proc parseArguments(): CliOptions =
  result.runs = 1
  result.seed = 1
  result.processId = 0

  result.numTeams = 5
  result.playersPerTeam = 24
  result.maxSeasons = 30
  result.maxTrainingFailures = 750
  result.customTrainingAfter = 15
  result.specialTransferAfter = 25

  var parser = initOptParser()
  for kind, key, value in parser.getopt():
    case kind
    of cmdLongOption, cmdShortOption:
      case key
      of "instance", "i":           result.instancePath = value
      of "runs", "r":               result.runs = parseInt(value)
      of "seed", "s":               result.seed = parseInt(value)
      of "process", "p":            result.processId = parseInt(value)
      of "num-teams":               result.numTeams = parseInt(value)
      of "players-per-team":        result.playersPerTeam = parseInt(value)
      of "max-seasons":             result.maxSeasons = parseInt(value)
      of "max-training-failures":   result.maxTrainingFailures = parseInt(value)
      of "custom-training-after":   result.customTrainingAfter = parseInt(value)
      of "special-transfer-after":  result.specialTransferAfter = parseInt(value)
      else:
        raise newException(ValueError, "Unknown flag: " & key)
    of cmdArgument: discard
    of cmdEnd: discard

proc validateArguments(options: CliOptions) =
  if options.instancePath.len == 0:
    raise 
      newException(ValueError, "Missing required option: --instance")
  if not fileExists(options.instancePath):
    raise 
      newException(ValueError, "Instance file not found: " & options.instancePath)
  if options.runs <= 0:
    raise 
      newException(ValueError, "Runs must be greater than zero")
  if options.processId < 0:
    raise 
      newException(ValueError, "Process ID cannot be negative")
  if options.numTeams <= 0:
    raise 
      newException(ValueError, "Num teams must be greater than zero")
  if options.playersPerTeam <= 0:
    raise 
      newException(ValueError, "Players per team must be greater than zero")
  if options.maxSeasons <= 0:
    raise 
      newException(ValueError, "Max seasons must be greater than zero")
  if options.maxTrainingFailures <= 0:
    raise 
      newException(ValueError, "Max training failures must be greater than zero")
  if options.customTrainingAfter <= 0:
    raise 
      newException(ValueError, "Custom training after must be greater than zero")
  if options.specialTransferAfter <= 0:
    raise 
      newException(ValueError, "Special transfer after must be greater than zero")

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

proc main() = 
  let options = parseArguments()
  validateArguments(options)

  inst = loadInstance(options.instancePath)
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
  
  let params = Params(numTeams: options.numTeams,
                      playersPerTeam: options.playersPerTeam,
                      maxSeasons: options.maxSeasons,   
                      maxTrainingFailures: options.maxTrainingFailures, 
                      customTrainingAfter: options.customTrainingAfter,
                      specialTransferAfter: options.specialTransferAfter)


  let start = getMonoTime()
  let res = runMultiple(problem, params,  
                        runs = options.runs, 
                        baseSeed = options.seed, 
                        processId = options.processId, 
                        evalChain = evaluateChain)
  let elapsed = (getMonoTime() - start).inMilliseconds

  echo ""
  echo "========================================"
  echo " Process ", options.processId, " finished"
  echo "========================================"
  echo "Instance:         ", options.instancePath
  echo "Base seed:        ", options.seed
  echo "Runs:             ", options.runs
  echo "Best cost:        ", res.bestCost
  echo "Best makespan:    ", res.bestMakespan, " (nodes in cycle: ", res.bestNodesInCycle, ")"
  echo "Best seed:        ", res.bestSeed
  echo "Best seasons:     ", res.bestSeasons
  echo "Time:             ", elapsed.float / 1000.0, " s"
  echo "========================================"
  echo "Solution:"
  echo formatSolution(inst, res.bestChain)

when isMainModule:
  main()



