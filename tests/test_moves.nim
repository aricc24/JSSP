import std/[unittest, random]
import goldenball/moves

suite "Apply":
  test "swap":
    var chain = @[0, 1, 2, 3, 4]
    chain.apply(Move(kind: mkSwap, a: 1, b: 3))
    check chain == @[0, 3, 2, 1, 4]

  test "insert forward":
    var chain = @[0, 1, 2, 3, 4]
    chain.apply(Move(kind: mkInsert, a: 1, b: 3))
    check chain == @[0, 2, 3, 1, 4]

  test "insert backward":
    var chain = @[0, 1, 2, 3, 4]
    chain.apply(Move(kind: mkInsert, a: 3, b: 1))
    check chain == @[0, 3, 1, 2, 4]

suite "Undo":
  test "random moves are undone exactly":
    var rng = initRand(42)
    var chain = newSeq[int](1600)
    for i in 0 ..< chain.len:
      chain[i] = i
    let original = chain
    for _ in 0 ..< 1000:
      for kind in MoveKind:
        let mv = rng.randomMove(kind, chain.len)
        check mv.a != mv.b
        check mv.a in 0 ..< chain.len and mv.b in 0 ..< chain.len
        chain.apply(mv)
        chain.undo(mv)
        check chain == original