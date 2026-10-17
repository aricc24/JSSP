import std/[unittest, os, random]
import jssp/io/instance_file
import jssp/models/solution
import ./fixtures

const dataDir = currentSourcePath().parentDir / ".." / "instances"

suite "solution 3x3":
  let inst = ft3x3()

  test "gantt chain is a permutation":
    check ganttChain.isPermutation(inst.numOps)

  test "machine chain matches the gantt":
    let mc = inst.toMachineChain(ganttChain)
    check mc.order == @[0, 3, 7, 6, 1, 5, 4, 2, 8]
    check mc[1, 0] == 6   

  test "invalid chains are rejected":
    check not @[0, 1, 2].isPermutation(inst.numOps)
    check not @[0, 0, 1, 2, 3, 4, 5, 6, 7].isPermutation(inst.numOps)

suite "random solutions 40x40":
  let inst = loadInstance(dataDir / "JSSP_40_40.txt")
  var rng = initRand(42)

  test "random chains are permutations":
    for _ in 1 .. 100:
      check inst.randomOperationChain(rng).isPermutation(inst.numOps)

  test "each machine gets one operation of every job":
    let mc = inst.toMachineChain(inst.randomOperationChain(rng))

    for m in 0 ..< inst.numMachines:
      var seenJob = newSeq[bool](inst.numJobs)

      for pos in 0 ..< inst.numJobs:
        let opIdx = mc[m, pos]
        check inst.ops[opIdx].machine == m
        seenJob[inst.jobOf(opIdx)] = true

      check false notin seenJob