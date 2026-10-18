import std/random

type
  MoveKind* = enum 
    mkswap
    mkInsert
    mkReverse
   # mkAdjacentSwap
  
  Move* = object
    kind*: MoveKind
    a*: int
    b*: int


func insert(chain: var seq[int], src: int, dst: int) =
  let x = chain[src]

  if src < dst: 
    for p in src ..< dst: 
      chain[p] = chain[p + 1]
  else: 
    for p in countdown(src, dst + 1): 
      chain[p] = chain[p - 1]
  
  chain[dst] = x

func reverseSegment(chain: var seq[int], a: int, b: int) = 
  var i = min(a, b)
  var j = max(a, b)

  while i < j: 
    swap(chain[i], chain[j])
    inc i
    dec j

func apply*(chain: var seq[int], mv: Move) =
  case mv.kind
    of mkswap: swap(chain[mv.a], chain[mv.b])
    of mkInsert: chain.insert(mv.a, mv.b)
    of mkReverse: chain.reverseSegment(mv.a, mv.b)

func undo*(chain: var seq[int], mv: Move) =
  case mv.kind
    of mkswap: swap(chain[mv.a], chain[mv.b])
    of mkInsert: chain.insert(mv.b, mv.a)
    of mkReverse: chain.reverseSegment(mv.a, mv.b)

proc randomPair(rng: var Rand, n: int): (int, int) =
  let a = rng.rand(n - 1)
  var b = rng.rand(n - 2)
  if b >= a: 
    inc b 
  (a, b)

proc randomMove*(rng: var Rand, kind: MoveKind, n: int): Move = 
  let (a, b) = rng.randomPair(n)
  Move(kind: kind, a: a, b: b)



