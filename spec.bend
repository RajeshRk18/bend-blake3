# An executable specification of BLAKE3, written against the published
# algorithm and independent of the implementation: it shares no code with it,
# keeps its own constants, and holds every array as a plain indexed list.

import Base

def get.go(m: Maybe<&2, U32>) -> U32:
  match m:
    case None{}:
      0
    case Some{v}:
      v

def get(xs: List<&2, U32>, i: Nat) -> U32:
  get.go(List.get(&2, U32, xs, i))

def put(xs: List<&2, U32>, i: Nat, v: U32) -> List<&2, U32>:
  List.set(&2, U32, xs, i, v)

def IV0() -> U32:
  1779033703

def IV1() -> U32:
  3144134277

def IV2() -> U32:
  1013904242

def IV3() -> U32:
  2773480762

def IV4() -> U32:
  1359893119

def IV5() -> U32:
  2600822924

def IV6() -> U32:
  528734635

def IV7() -> U32:
  1541459225

def CHUNK_START() -> U32:
  1

def CHUNK_END() -> U32:
  2

def PARENT() -> U32:
  4

def ROOT() -> U32:
  8

def KEYED_HASH() -> U32:
  16

def DERIVE_KEY_CONTEXT() -> U32:
  32

def DERIVE_KEY_MATERIAL() -> U32:
  64

def rotr(x: U32, +n: Nat) -> U32:
  +y = x
  U32.or(U32.shrn(y, n), U32.shln(y, Nat.sub(32n, n)))

def g(+st: List<&2, U32>, +a: Nat, +b: Nat, +c: Nat, +d: Nat, mx: U32,
  my: U32) -> List<&2, U32>:
  +st = put(st, a, U32.add(U32.add(get(st, a), get(st, b)), mx))
  +st = put(st, d, rotr(U32.xor(get(st, d), get(st, a)), 16n))
  +st = put(st, c, U32.add(get(st, c), get(st, d)))
  +st = put(st, b, rotr(U32.xor(get(st, b), get(st, c)), 12n))
  +st = put(st, a, U32.add(U32.add(get(st, a), get(st, b)), my))
  +st = put(st, d, rotr(U32.xor(get(st, d), get(st, a)), 8n))
  +st = put(st, c, U32.add(get(st, c), get(st, d)))
  put(st, b, rotr(U32.xor(get(st, b), get(st, c)), 7n))

def round(st: List<&2, U32>, +m: List<&2, U32>) -> List<&2, U32>:
  +st = g(st, 0n, 4n, 8n, 12n, get(m, 0n), get(m, 1n))
  +st = g(st, 1n, 5n, 9n, 13n, get(m, 2n), get(m, 3n))
  +st = g(st, 2n, 6n, 10n, 14n, get(m, 4n), get(m, 5n))
  +st = g(st, 3n, 7n, 11n, 15n, get(m, 6n), get(m, 7n))
  +st = g(st, 0n, 5n, 10n, 15n, get(m, 8n), get(m, 9n))
  +st = g(st, 1n, 6n, 11n, 12n, get(m, 10n), get(m, 11n))
  +st = g(st, 2n, 7n, 8n, 13n, get(m, 12n), get(m, 13n))
  g(st, 3n, 4n, 9n, 14n, get(m, 14n), get(m, 15n))

def permute(+m: List<&2, U32>) -> List<&2, U32>:
  [get(m, 2n), get(m, 6n), get(m, 3n), get(m, 10n), get(m, 7n), get(m, 0n),
   get(m, 4n), get(m, 13n), get(m, 1n), get(m, 11n), get(m, 12n), get(m, 5n),
   get(m, 9n), get(m, 14n), get(m, 15n), get(m, 8n)]

def feed(+st: List<&2, U32>, +cv: List<&2, U32>) -> List<&2, U32>:
  [U32.xor(get(st, 0n), get(st, 8n)), U32.xor(get(st, 1n), get(st, 9n)), U32.xor(get(st, 2n), get(st, 10n)), U32.xor(get(st, 3n), get(st, 11n)),
   U32.xor(get(st, 4n), get(st, 12n)), U32.xor(get(st, 5n), get(st, 13n)), U32.xor(get(st, 6n), get(st, 14n)), U32.xor(get(st, 7n), get(st, 15n)),
   U32.xor(get(st, 8n), get(cv, 0n)), U32.xor(get(st, 9n), get(cv, 1n)), U32.xor(get(st, 10n), get(cv, 2n)), U32.xor(get(st, 11n), get(cv, 3n)),
   U32.xor(get(st, 12n), get(cv, 4n)), U32.xor(get(st, 13n), get(cv, 5n)), U32.xor(get(st, 14n), get(cv, 6n)), U32.xor(get(st, 15n), get(cv, 7n))]

def compress(+cv: List<&2, U32>, blk: List<&2, U32>, lo: U32, hi: U32,
  len: U32, flags: U32) -> List<&2, U32>:
  st = {[get(cv, 0n), get(cv, 1n), get(cv, 2n), get(cv, 3n), get(cv, 4n), get(cv, 5n), get(cv, 6n), get(cv, 7n),
    IV0(), IV1(), IV2(), IV3(), lo, hi, len, flags] : List<&2, U32>}
  +m = blk
  +st = round(st, m)
  +m = permute(m)
  +st = round(st, m)
  +m = permute(m)
  +st = round(st, m)
  +m = permute(m)
  +st = round(st, m)
  +m = permute(m)
  +st = round(st, m)
  +m = permute(m)
  +st = round(st, m)
  +m = permute(m)
  +st = round(st, m)
  feed(st, cv)


type Out is Data:
  Out{cv: List<&2, U32>, blk: List<&2, U32>, lo: U32, hi: U32, len: U32,
    flags: U32}

def first8(+ws: List<&2, U32>) -> List<&2, U32>:
  [get(ws, 0n), get(ws, 1n), get(ws, 2n), get(ws, 3n), get(ws, 4n), get(ws, 5n), get(ws, 6n), get(ws, 7n)]

def iv() -> List<&2, U32>:
  [IV0(), IV1(), IV2(), IV3(), IV4(), IV5(), IV6(), IV7()]

def le(b0: U32, b1: U32, b2: U32, b3: U32) -> U32:
  U32.or(U32.or(b0, U32.shln(b1, 8n)), U32.or(U32.shln(b2, 16n),
    U32.shln(b3, 24n)))

# A block buffer is zeroed before use, so bytes past the end read as zero.
def block_words(+bs: List<&2, U32>) -> List<&2, U32>:
  [le(get(bs, 0n), get(bs, 1n), get(bs, 2n), get(bs, 3n)), le(get(bs, 4n), get(bs, 5n), get(bs, 6n), get(bs, 7n)), le(get(bs, 8n), get(bs, 9n), get(bs, 10n), get(bs, 11n)), le(get(bs, 12n), get(bs, 13n), get(bs, 14n), get(bs, 15n)),
   le(get(bs, 16n), get(bs, 17n), get(bs, 18n), get(bs, 19n)), le(get(bs, 20n), get(bs, 21n), get(bs, 22n), get(bs, 23n)), le(get(bs, 24n), get(bs, 25n), get(bs, 26n), get(bs, 27n)), le(get(bs, 28n), get(bs, 29n), get(bs, 30n), get(bs, 31n)),
   le(get(bs, 32n), get(bs, 33n), get(bs, 34n), get(bs, 35n)), le(get(bs, 36n), get(bs, 37n), get(bs, 38n), get(bs, 39n)), le(get(bs, 40n), get(bs, 41n), get(bs, 42n), get(bs, 43n)), le(get(bs, 44n), get(bs, 45n), get(bs, 46n), get(bs, 47n)),
   le(get(bs, 48n), get(bs, 49n), get(bs, 50n), get(bs, 51n)), le(get(bs, 52n), get(bs, 53n), get(bs, 54n), get(bs, 55n)), le(get(bs, 56n), get(bs, 57n), get(bs, 58n), get(bs, 59n)), le(get(bs, 60n), get(bs, 61n), get(bs, 62n), get(bs, 63n))]

def to_bytes(+w: U32) -> List<&2, U32>:
  [U32.and(w, 255), U32.and(U32.shrn(w, 8n), 255),
   U32.and(U32.shrn(w, 16n), 255), U32.and(U32.shrn(w, 24n), 255)]

def word_bytes16(+ws: List<&2, U32>) -> List<&2, U32>:
  List.concat(&2, U32, [to_bytes(get(ws, 0n)), to_bytes(get(ws, 1n)), to_bytes(get(ws, 2n)), to_bytes(get(ws, 3n)), to_bytes(get(ws, 4n)), to_bytes(get(ws, 5n)), to_bytes(get(ws, 6n)), to_bytes(get(ws, 7n)),
    to_bytes(get(ws, 8n)), to_bytes(get(ws, 9n)), to_bytes(get(ws, 10n)), to_bytes(get(ws, 11n)), to_bytes(get(ws, 12n)), to_bytes(get(ws, 13n)), to_bytes(get(ws, 14n)), to_bytes(get(ws, 15n))])

def out_cv(o: Out) -> List<&2, U32>:
  Out{cv, blk, lo, hi, len, flags} = o
  first8(compress(cv, blk, lo, hi, len, flags))

def parent_out(l: List<&2, U32>, r: List<&2, U32>, key: List<&2, U32>,
  flags: U32) -> Out:
  Out{key, List.append(&2, U32, l, r), 0, 0, 64, U32.or(flags, PARENT())}

def parent_cv(l: List<&2, U32>, r: List<&2, U32>, key: List<&2, U32>,
  flags: U32) -> List<&2, U32>:
  out_cv(parent_out(l, r, key, flags))

def chunk_out(blocks: List<&2, List<&2, U32>>, cv: List<&2, U32>, +lo: U32,
  +hi: U32, +flags: U32, start: U32) -> Out:
  match blocks:
    case Nil{}:
      Out{cv, block_words(Nil{}), lo, hi, 0,
        U32.or(U32.or(flags, start), CHUNK_END())}
    case Con{b, Nil{}}:
      +b = b
      Out{cv, block_words(b), lo, hi, U32.from_nat(List.length(&2, U32, b)),
        U32.or(U32.or(flags, start), CHUNK_END())}
    case Con{b, rest}:
      chunk_out(rest,
        first8(compress(cv, block_words(b), lo, hi, 64, U32.or(flags, start))),
        lo, hi, flags, 0)

def chunk_cv(blocks: List<&2, List<&2, U32>>, cv: List<&2, U32>, lo: U32,
  hi: U32, flags: U32) -> List<&2, U32>:
  out_cv(chunk_out(blocks, cv, lo, hi, flags, CHUNK_START()))

def shr64_lo(+lo: U32, +hi: U32) -> U32:
  U32.or(U32.shrn(lo, 1n), U32.shln(hi, 31n))

# One completed subtree is merged for each trailing zero bit of the chunk
# total, so the stack never holds two subtrees of the same size.
def add_cv(fuel: Nat, even: Bool, stack: List<&2, List<&2, U32>>,
  cv: List<&2, U32>, +lo: U32, +hi: U32, +key: List<&2, U32>,
  +flags: U32) -> List<&2, List<&2, U32>>:
  match fuel:
    case 0n:
      cv <> stack
    case 1n+f:
      match even:
        case False{}:
          cv <> stack
        case True{}:
          match stack:
            case Nil{}:
              [cv]
            case Con{top, rest}:
              +lo2 = shr64_lo(lo, hi)
              add_cv(f, U32.is_even(lo2), rest, parent_cv(top, cv, key, flags),
                lo2, U32.shrn(hi, 1n), key, flags)

def finalize(stack: List<&2, List<&2, U32>>, o: Out, +key: List<&2, U32>,
  +flags: U32) -> Out:
  match stack:
    case Nil{}:
      o
    case Con{top, rest}:
      finalize(rest, parent_out(top, out_cv(o), key, flags), key, flags)

def run(chunks: List<&2, List<&2, List<&2, U32>>>,
  stack: List<&2, List<&2, U32>>, +lo: U32, +hi: U32, +key: List<&2, U32>,
  +flags: U32) -> Out:
  match chunks:
    case Nil{}:
      chunk_out(Nil{}, key, lo, hi, flags, CHUNK_START())
    case Con{c, Nil{}}:
      finalize(stack, chunk_out(c, key, lo, hi, flags, CHUNK_START()), key,
        flags)
    case Con{c, rest}:
      +lo2 = U32.add(lo, 1)
      +hi2 = U32.add(hi, Bool.pick(U32, U32.is_eq(lo2, 0), 1, 0))
      run(rest, add_cv(54n, U32.is_even(lo2), stack,
        chunk_cv(c, key, lo, hi, flags), lo2, hi2, key, flags), lo2, hi2, key,
        flags)

def split(-A: Data, fuel: Nat, empty: Bool, +n: Nat, +xs: List<&2, A>) ->
  List<&2, List<&2, A>>:
  match fuel:
    case 0n:
      Nil{}
    case 1n+f:
      match empty:
        case True{}:
          Nil{}
        case False{}:
          List.take(&2, A, xs, n) <>
            split(A, f, List.is_empty(&2, A, List.drop(&2, A, xs, n)), n,
              List.drop(&2, A, xs, n))

def hash_all(+input: List<&2, U32>, key: List<&2, U32>, flags: U32) -> Out:
  +n = List.length(&2, U32, input)
  +blocks = split(U32, n, List.is_empty(&2, U32, input), 64n, input)
  run(split(List<&2, U32>, n, List.is_empty(&2, List<&2, U32>, blocks), 16n,
    blocks), Nil{}, 0, 0, key, flags)

def root_bytes(nblk: Nat, +o: Out, +lo: U32, +hi: U32) -> List<&2, U32>:
  match nblk:
    case 0n:
      Nil{}
    case 1n+p:
      Out{cv, blk, own_lo, own_hi, len, flags} = o
      +lo2 = U32.add(lo, 1)
      List.append(&2, U32,
        word_bytes16(compress(cv, blk, lo, hi, len, U32.or(flags, ROOT()))),
        root_bytes(p, o, lo2,
          U32.add(hi, Bool.pick(U32, U32.is_eq(lo2, 0), 1, 0))))

def xof(o: Out, +len: Nat) -> List<&2, U32>:
  List.take(&2, U32, root_bytes(Nat.div(Nat.add(len, 63n), 64n), o, 0, 0), len)

def hash(input: List<&2, U32>, len: Nat) -> List<&2, U32>:
  xof(hash_all(input, iv(), 0), len)

def keyed(key: List<&2, U32>, input: List<&2, U32>, len: Nat) ->
  List<&2, U32>:
  xof(hash_all(input, first8(block_words(key)), KEYED_HASH()), len)

def derive(context: List<&2, U32>, material: List<&2, U32>,
  len: Nat) -> List<&2, U32>:
  ck = xof(hash_all(context, iv(), DERIVE_KEY_CONTEXT()), 32n)
  xof(hash_all(material, first8(block_words(ck)), DERIVE_KEY_MATERIAL()), len)
