import std/strutils
import ../models/instance
export instance

proc parseInstance*(text: string): Instance =
  let tokens = text.splitWhitespace()

  if tokens.len < 4: 
    raise newException(ValueError, 
      "Invalide instance: missing header, must have: n m cu ci")

  result.numJobs = parseInt(tokens[0])
  result.numMachines = parseInt(tokens[1])
  result.upperBound = parseInt(tokens[2])
  result.lowerBound = parseInt(tokens[3])

  if result.numJobs <= 0 or result.numMachines <= 0: 
    raise newException(ValueError, 
      "Invalide instance: jobs and machines must be positive")

  let expected = 4 + 2 * result.numOps
  if tokens.len != expected: 
    raise newException(ValueError, 
      "expected" & $expected & "values, found" & $tokens.len)

  result.ops = newSeq[Operation](result.numOps)
  for idx in 0 ..< result.numOps: 
    let machine = parseInt(tokens[4 + 2 * idx])
    let duration = parseInt(tokens[5 + 2 * idx])

    if machine < 0 or machine >= result.numMachines: 
      raise newException(ValueError, 
        "Invalid machine index " & $machine & " at operation " & $idx)
    
    if duration <= 0:
      raise newException(ValueError,
        "Invalid duration " & $duration & " at operation " & $idx)
  
    result.ops[idx] = Operation(
      machine: machine,
      duration: duration
    )

proc loadInstance*(path: string): Instance = 
  parseInstance(readFile(path))