type 
  Operation* = object
    machine*: int
    duration*: int

  Instance* = object
    numJobs*: int
    numMachines*: int
    upperBound*: int
    lowerBound*: int
    ops*: seq[Operation]

func numOps*(inst: Instance): int {.inline.} =
  inst.numJobs * inst.numMachines

func opIndex*(inst: Instance, job, k: int): int {.inline.} =
  job * inst.numMachines + k

func jobOf*(inst: Instance, idx: int): int {.inline.} =
  idx div inst.numMachines

func posOf*(inst: Instance, idx: int): int {.inline.} =
  idx mod inst.numMachines

func op*(inst: Instance, job, k: int): Operation {.inline.} =
  inst.ops[inst.opIndex(job, k)]