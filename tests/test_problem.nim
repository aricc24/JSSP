import std/[algorithm, random, unittest]
import goldenball/[moves, problem]

#Indepent test of jssp, just cost how many elements are misplaced

proc misplaced(chain: seq[int]): float =
  for i, x in chain:
    if x != i:
      result += 1.0

proc shuffled(rng: var Rand): seq[int] =
  result = @[0, 1, 2, 3]
  rng.shuffle(result)

suite "Problem":
  test "a generic coach proposes valid moves of its kind":
    var rng = initRand(42)
    var chain = @[0, 1, 2, 3, 4, 5, 6, 7]
    let original = chain

    for kind in MoveKind:
      let coach = genericCoach(kind)

      for _ in 0 ..< 1000:
        var mv: Move
        check coach(chain, rng, mv)
        check mv.kind == kind
        check mv.a in 0 ..< chain.len and mv.b in 0 ..< chain.len
        chain.apply(mv)
        chain.undo(mv)
        check chain == original

  test "a problem holds procedures defined outside goldenball":
    var rng = initRand(7)
    let problem = Problem(cost: misplaced, newChain: shuffled,
                          coaches: @[genericCoach(mkSwap)])

    check problem.cost(@[0, 1, 2, 3]) == 0.0
    check problem.cost(@[1, 0, 2, 3]) == 2.0
    check problem.newChain(rng).sorted == @[0, 1, 2, 3]
    check problem.coaches.len == 1