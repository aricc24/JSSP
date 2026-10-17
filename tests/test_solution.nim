import std/[unittest, os, random]
import jssp/io/instance_file
import jssp/models/solution

const dataDir = currentSourcePath().parentDir / ".." / "instances"

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