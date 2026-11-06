import ../schedule
export schedule

proc writeSchedule*(path: string, sched: seq[ScheduledOp]) =
  var f = open(path, fmWrite)
  defer: f.close()
  f.writeLine "job,machine,start,finish"
  for op in sched:
    f.writeLine op.job, ",", op.machine, ",", op.start, ",", op.finish