import jssp/models/instance

func operation(machine, duration: int): Operation =
  Operation(machine: machine, duration: duration)

func ft3x3*(): Instance =
  Instance(
    numJobs: 3, numMachines: 3,
    upperBound: 24, lowerBound: 10,
    ops: @[operation(0, 3), operation(1, 3), operation(2, 3),    
           operation(0, 2), operation(2, 3), operation(1, 4),   
           operation(1, 3), operation(0, 2), operation(2, 1)])   

const ft3x3Text* = """
3 3 24 10
0 3 1 3 2 3
0 2 2 3 1 4
1 3 0 2 2 1
"""

const ganttChain* = @[0, 6, 3, 1, 7, 4, 2, 5, 8]

const cyclicChain* = @[7, 1, 0, 6, 3, 2, 4, 5, 8]
