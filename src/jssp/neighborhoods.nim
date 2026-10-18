import ./models/[instance, solution]
import ./critical_path

type
  SwapMove* = object
    i*: int 
    j*: int 

func positionsOf*(chain: OperationChain): seq[int] =
  result = newSeq[int] (chain.len)
  for position, op in chain: 
    result[op] = position

func n5Moves*(inst: Instance, path: seq[int], blocks: seq[Block], 
              pos: seq[int]) : seq[SwapMove] =
  
  for b, blk in blocks: 
    let size = blk.last - blk.first + 1
    
    if size < 2: 
      continue

    let isFirst = b == 0
    let isLast = b == blocks.high

    if not isFirst: 
      result.add SwapMove(i: pos[path[blk.first]], 
                          j: pos[path[blk.first + 1]])

    if not isLast and not (size == 2 and not isFirst): 
      result.add SwapMove(i: pos[path[blk.last - 1]], 
                          j: pos[path[blk.last]])

