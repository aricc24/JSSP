import std/random
import ./moves

type
  CostProc* = proc(chain: seq[int]): float
  ChainProc* = proc(rng: var Rand): seq[int]
  Coach* = proc(chain: seq[int], rng: var Rand, mv: var Move): bool

  Problem* = object
    cost*: CostProc
    newChain*: ChainProc
    coaches*: seq[Coach]

proc genericCoach*(kind: MoveKind): Coach =
  result = proc(chain: seq[int], rng: var Rand, mv: var Move): bool =
    mv = randomMove(rng, kind, chain.len)