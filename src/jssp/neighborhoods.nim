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

type
  InsertMove* = object
    src*: int
    dst*: int

func addBlockMove(moves: var seq[InsertMove], path, pos: seq[int], 
                  blk: Block, a, t: int) = 

  var (a, t) = (a, t)

  if a == t: 
    return

  if t == a - 1: 
    swap(a, t)
  
  let u = path[blk.first + a]
  let v = path[blk.first + t]
  let mv = InsertMove(src: pos[u], dst: pos[v])

  if mv notin moves: 
    moves.add mv

func n7Moves*(inst: Instance, path: seq[int], blocks: seq[Block], 
              pos: seq[int]): seq[InsertMove] =

  for b, blk in blocks: 
    let size = blk.last - blk.first + 1

    if size < 2: 
      continue

    let lastIdx = size - 1
    for a in 0 .. lastIdx: 
      if b != 0: 
        result.addBlockMove(path, pos, blk, a, 0)
      if b != blocks.high: 
        result.addBlockMove(path, pos, blk, a, lastIdx)
        
      for t in 1 ..< lastIdx: 
        result.addBlockMove(path, pos, blk, 0, t)
        result.addBlockMove(path, pos, blk, lastIdx, t)