import ./models/instance
import ./cost

type
  ScheduledOp* = object
    job*: int
    machine*: int
    start*: int
    finish*: int

func schedule*(inst: Instance, ws: Workspace): seq[ScheduledOp] =
  result = newSeq[ScheduledOp](inst.numOps)
  for u in 0 ..< inst.numOps:
    let d = inst.ops[u].duration
    result[u] = ScheduledOp(job: u div inst.numMachines,
                            machine: inst.ops[u].machine,
                            start: ws.finish[u] - d,
                            finish: ws.finish[u])