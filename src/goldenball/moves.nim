import std/random

type
  MoveKind* = enum 
    mkswap
  
  Move* = object
    kind*: MoveKind
    a*: int
    b*: int


func apply*(chain: var seq[int], mv: Move) =
  case mv.kind
    of mkswap: swap(chain[mv.a], chain[mv.b])

