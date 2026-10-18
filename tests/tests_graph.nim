import std/[unittest, os, random, sequtils]
import jssp/io/instance_file
import jssp/models/[solution, graph]
import ./fixtures

const dataDir = currentSourcePath().parentDir / ".." / "instances"

suite "Graph 3x3":
  let inst = ft3x3()
  let g = inst.buildGraph(inst.toMachineChain(ganttChain))

  test "machine arcs":
    check g.machineNext == @[3, 5, 8, 7, 2, NoNode, 1, NoNode, NoNode]

  test "job arcs":
    check g.jobNext(0) == 1
    check g.jobNext(1) == 2
    check g.jobNext(2) == NoNode   

  test "in-degrees":
    check g.inDegree == @[0, 2, 2, 1, 1, 2, 0, 2, 2]

  test "successors":
    check toSeq(g.successors(4)) == @[5, 2]  
    check toSeq(g.successors(8)).len == 0    

suite "Graph 40x40":
  let inst = loadInstance(dataDir / "JSSP_40_40.txt")
  var rng = initRand(7)

  test "number of arcs":
    let g = inst.buildGraph(inst.toMachineChain(inst.randomOperationChain(rng)))
    let expected = inst.numJobs * (inst.numMachines - 1) +
                   inst.numMachines * (inst.numJobs - 1)
    check g.inDegree.foldl(a + b) == expected   