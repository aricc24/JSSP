import std/[unittest, os]
import jssp/io/instance_file

const dataDir = currentSourcePath().parentDir / ".." / "instances"

suite "instance 40x40":
  let inst = loadInstance(dataDir / "JSSP_40_40.txt")

  test "header":
    check inst.numJobs == 40
    check inst.numMachines == 40
    check inst.upperBound == 205
    check inst.lowerBound == 103

  test "all operations loaded":
    check inst.ops.len == 1600

  test "first and last operations":
    check inst.op(0, 0) == Operation(machine: 23, duration: 8)
    check inst.op(0, 39) == Operation(machine: 10, duration: 1)
    check inst.op(39, 39) == Operation(machine: 6, duration: 1)

  test "index conversion":
    let idx = inst.opIndex(2, 5)
    check idx == 85
    check inst.jobOf(idx) == 2
    check inst.posOf(idx) == 5