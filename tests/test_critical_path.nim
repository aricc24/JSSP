import std/unittest
import jssp/models/[instance, solution, graph]
import jssp/[cost, critical_path]
import ./fixtures

suite "Critical path 3x3":
  let inst = ft3x3()
  var ws = initWorkspace(inst.numOps)
  discard inst.evaluate(inst.buildGraph(inst.toMachineChain(ganttChain)), ws)

  test "path O11 - O21 - O22 - O23":
    check ws.criticalPath == @[0, 3, 4, 5]

  test "its length is the makespan":
    var total = 0

    for u in ws.criticalPath:
      total += inst.ops[u].duration

    check total == 12

  test "blocks":
    check inst.criticalBlocks(ws.criticalPath) ==
      @[Block(first: 0, last: 1), Block(first: 2, last: 2), Block(first: 3, last: 3)]