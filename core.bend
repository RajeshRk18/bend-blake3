import Base

type CV is Data:
  CV{v0: U32, v1: U32, v2: U32, v3: U32, v4: U32, v5: U32, v6: U32, v7: U32}

type W16 is Data:
  W16{w0: U32, w1: U32, w2: U32, w3: U32, w4: U32, w5: U32, w6: U32, w7: U32, w8: U32, w9: U32, w10: U32, w11: U32, w12: U32, w13: U32, w14: U32, w15: U32}

# The chunk counter is 64 bits wide, kept as a low and a high word.
type Ctr is Data:
  Ctr{lo: U32, hi: U32}

# A node's state just before it is either chained on or expanded into output.
type Out is Data:
  Out{key: CV, blk: W16, ctr: Ctr, len: U32, flags: U32}

def iv0() -> U32:
  1779033703

def iv1() -> U32:
  3144134277

def iv2() -> U32:
  1013904242

def iv3() -> U32:
  2773480762

def iv4() -> U32:
  1359893119

def iv5() -> U32:
  2600822924

def iv6() -> U32:
  528734635

def iv7() -> U32:
  1541459225

def iv() -> CV:
  CV{iv0(), iv1(), iv2(), iv3(), iv4(), iv5(), iv6(), iv7()}

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

def g(+a: U32, +b: U32, +c: U32, +d: U32, mx: U32, my: U32) ->
  U32 & U32 & U32 & U32:
  +a = U32.add(U32.add(a, b), mx)
  +d = rotr(U32.xor(d, a), 16n)
  +c = U32.add(c, d)
  +b = rotr(U32.xor(b, c), 12n)
  +a = U32.add(U32.add(a, b), my)
  +d = rotr(U32.xor(d, a), 8n)
  +c = U32.add(c, d)
  b = rotr(U32.xor(b, c), 7n)
  (a, b, c, d)

# Bend cannot destructure a computed tuple, so each mixing step hands its
# four lanes back through a parameter.
def mix0.put(r: U32 & U32 & U32 & U32, s1: U32, s2: U32, s3: U32, s5: U32, s6: U32, s7: U32, s9: U32, s10: U32, s11: U32, s13: U32, s14: U32, s15: U32) -> W16:
  (s0, s4, s8, s12) = r
  W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15}

def mix0(st: W16, mx: U32, my: U32) -> W16:
  W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15} = st
  mix0.put(g(s0, s4, s8, s12, mx, my), s1, s2, s3, s5, s6, s7, s9, s10, s11, s13, s14, s15)

def mix1.put(r: U32 & U32 & U32 & U32, s0: U32, s2: U32, s3: U32, s4: U32, s6: U32, s7: U32, s8: U32, s10: U32, s11: U32, s12: U32, s14: U32, s15: U32) -> W16:
  (s1, s5, s9, s13) = r
  W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15}

def mix1(st: W16, mx: U32, my: U32) -> W16:
  W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15} = st
  mix1.put(g(s1, s5, s9, s13, mx, my), s0, s2, s3, s4, s6, s7, s8, s10, s11, s12, s14, s15)

def mix2.put(r: U32 & U32 & U32 & U32, s0: U32, s1: U32, s3: U32, s4: U32, s5: U32, s7: U32, s8: U32, s9: U32, s11: U32, s12: U32, s13: U32, s15: U32) -> W16:
  (s2, s6, s10, s14) = r
  W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15}

def mix2(st: W16, mx: U32, my: U32) -> W16:
  W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15} = st
  mix2.put(g(s2, s6, s10, s14, mx, my), s0, s1, s3, s4, s5, s7, s8, s9, s11, s12, s13, s15)

def mix3.put(r: U32 & U32 & U32 & U32, s0: U32, s1: U32, s2: U32, s4: U32, s5: U32, s6: U32, s8: U32, s9: U32, s10: U32, s12: U32, s13: U32, s14: U32) -> W16:
  (s3, s7, s11, s15) = r
  W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15}

def mix3(st: W16, mx: U32, my: U32) -> W16:
  W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15} = st
  mix3.put(g(s3, s7, s11, s15, mx, my), s0, s1, s2, s4, s5, s6, s8, s9, s10, s12, s13, s14)

def mix4.put(r: U32 & U32 & U32 & U32, s1: U32, s2: U32, s3: U32, s4: U32, s6: U32, s7: U32, s8: U32, s9: U32, s11: U32, s12: U32, s13: U32, s14: U32) -> W16:
  (s0, s5, s10, s15) = r
  W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15}

def mix4(st: W16, mx: U32, my: U32) -> W16:
  W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15} = st
  mix4.put(g(s0, s5, s10, s15, mx, my), s1, s2, s3, s4, s6, s7, s8, s9, s11, s12, s13, s14)

def mix5.put(r: U32 & U32 & U32 & U32, s0: U32, s2: U32, s3: U32, s4: U32, s5: U32, s7: U32, s8: U32, s9: U32, s10: U32, s13: U32, s14: U32, s15: U32) -> W16:
  (s1, s6, s11, s12) = r
  W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15}

def mix5(st: W16, mx: U32, my: U32) -> W16:
  W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15} = st
  mix5.put(g(s1, s6, s11, s12, mx, my), s0, s2, s3, s4, s5, s7, s8, s9, s10, s13, s14, s15)

def mix6.put(r: U32 & U32 & U32 & U32, s0: U32, s1: U32, s3: U32, s4: U32, s5: U32, s6: U32, s9: U32, s10: U32, s11: U32, s12: U32, s14: U32, s15: U32) -> W16:
  (s2, s7, s8, s13) = r
  W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15}

def mix6(st: W16, mx: U32, my: U32) -> W16:
  W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15} = st
  mix6.put(g(s2, s7, s8, s13, mx, my), s0, s1, s3, s4, s5, s6, s9, s10, s11, s12, s14, s15)

def mix7.put(r: U32 & U32 & U32 & U32, s0: U32, s1: U32, s2: U32, s5: U32, s6: U32, s7: U32, s8: U32, s10: U32, s11: U32, s12: U32, s13: U32, s15: U32) -> W16:
  (s3, s4, s9, s14) = r
  W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15}

def mix7(st: W16, mx: U32, my: U32) -> W16:
  W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15} = st
  mix7.put(g(s3, s4, s9, s14, mx, my), s0, s1, s2, s5, s6, s7, s8, s10, s11, s12, s13, s15)

def round(st: W16, m: W16) -> W16:
  W16{m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15} = m
  st = mix0(st, m0, m1)
  st = mix1(st, m2, m3)
  st = mix2(st, m4, m5)
  st = mix3(st, m6, m7)
  st = mix4(st, m8, m9)
  st = mix5(st, m10, m11)
  st = mix6(st, m12, m13)
  st = mix7(st, m14, m15)
  st

def permute(m: W16) -> W16:
  W16{m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15} = m
  W16{m2, m6, m3, m10, m7, m0, m4, m13, m1, m11, m12, m5, m9, m14, m15, m8}

def feed(st: W16, cv: CV) -> W16:
  W16{t0, t1, t2, t3, t4, t5, t6, t7, +t8, +t9, +t10, +t11, +t12, +t13, +t14, +t15} = st
  CV{c0, c1, c2, c3, c4, c5, c6, c7} = cv
  W16{
    U32.xor(t0, t8), U32.xor(t1, t9), U32.xor(t2, t10), U32.xor(t3, t11), U32.xor(t4, t12), U32.xor(t5, t13), U32.xor(t6, t14), U32.xor(t7, t15),
    U32.xor(t8, c0), U32.xor(t9, c1), U32.xor(t10, c2), U32.xor(t11, c3), U32.xor(t12, c4), U32.xor(t13, c5), U32.xor(t14, c6), U32.xor(t15, c7)
  }

def compress(+cv: CV, blk: W16, ctr: Ctr, len: U32, flags: U32) -> W16:
  CV{c0, c1, c2, c3, c4, c5, c6, c7} = cv
  Ctr{lo, hi} = ctr
  st = {W16{c0, c1, c2, c3, c4, c5, c6, c7, iv0(), iv1(), iv2(), iv3(), lo, hi, len, flags} : W16}
  +m = blk
  st = round(st, m)
  +m = permute(m)
  st = round(st, m)
  +m = permute(m)
  st = round(st, m)
  +m = permute(m)
  st = round(st, m)
  +m = permute(m)
  st = round(st, m)
  +m = permute(m)
  st = round(st, m)
  +m = permute(m)
  st = round(st, m)
  feed(st, cv)

def cv_of(w: W16) -> CV:
  W16{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15} = w
  CV{w0, w1, w2, w3, w4, w5, w6, w7}


def zeros16() -> W16:
  W16{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

def ctr_double(c: Ctr) -> Ctr:
  Ctr{lo, hi} = c
  +lo = lo
  Ctr{U32.shl(lo), U32.or(U32.shl(hi), U32.shrn(lo, 31n))}

def ctr_add(a: Ctr, b: Ctr) -> Ctr:
  Ctr{al, ah} = a
  Ctr{bl, bh} = b
  +al = al
  +s = U32.add(al, bl)
  Ctr{s, U32.add(U32.add(ah, bh), Bool.pick(U32, U32.is_lt(s, al), 1, 0))}

def ctr_inc(c: Ctr) -> Ctr:
  ctr_add(c, Ctr{1, 0})

def ctr_nat(c: Ctr) -> Nat:
  Ctr{lo, hi} = c
  Nat.add(U32.to_nat(lo), Nat.mul(U32.to_nat(hi), Nat.add(4294967295n, 1n)))

def le_word(b0: U32, b1: U32, b2: U32, b3: U32) -> U32:
  U32.or(U32.or(b0, U32.shln(b1, 8n)), U32.or(U32.shln(b2, 16n),
    U32.shln(b3, 24n)))

# Input reaches both splitters padded to a whole number of blocks, so the
# short-group case is unreachable.
def le_words(bs: List<&2, U32>) -> List<&2, U32>:
  match bs:
    case Nil{}:
      Nil{}
    case Con{b0, Con{b1, Con{b2, Con{b3, rest}}}}:
      le_word(b0, b1, b2, b3) <> le_words(rest)
    case _:
      Nil{}

def pack16(ws: List<&2, U32>) -> List<&2, W16>:
  match ws:
    case Nil{}:
      Nil{}
    case Con{x0, Con{x1, Con{x2, Con{x3, Con{x4, Con{x5, Con{x6, Con{x7, Con{x8, Con{x9, Con{x10, Con{x11, Con{x12, Con{x13, Con{x14, Con{x15, rest}}}}}}}}}}}}}}}}:
      W16{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15} <> pack16(rest)
    case _:
      Nil{}

def word_bytes(+w: U32) -> List<&2, U32>:
  [U32.and(w, 255), U32.and(U32.shrn(w, 8n), 255),
   U32.and(U32.shrn(w, 16n), 255), U32.and(U32.shrn(w, 24n), 255)]

def w16_bytes(b: W16) -> List<&2, U32>:
  W16{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15} = b
  List.concat(&2, U32, [word_bytes(w0), word_bytes(w1), word_bytes(w2), word_bytes(w3), word_bytes(w4), word_bytes(w5), word_bytes(w6), word_bytes(w7), word_bytes(w8), word_bytes(w9), word_bytes(w10), word_bytes(w11), word_bytes(w12), word_bytes(w13), word_bytes(w14), word_bytes(w15)])

def blocks_of(input: List<&2, U32>, +n: Nat) -> List<&2, W16>:
  pad = Nat.mod(Nat.sub(64n, Nat.mod(n, 64n)), 64n)
  pack16(le_words(List.append(&2, U32, input, List.replicate(U32, pad, 0))))

def tail_len.go(n: Nat, empty: Bool) -> U32:
  match empty:
    case True{}:
      0
    case False{}:
      U32.from_nat(Nat.add(Nat.mod(Nat.sub(n, 1n), 64n), 1n))

def tail_len(+n: Nat) -> U32:
  tail_len.go(n, Nat.is_eq(n, 0n))

def chunk_out(blocks: List<&2, W16>, key: CV, +ctr: Ctr, +flags: U32,
  start: U32, tail: U32) -> Out:
  match blocks:
    case Nil{}:
      Out{key, zeros16(), ctr, 0, U32.or(U32.or(flags, start), CHUNK_END())}
    case Con{b, Nil{}}:
      Out{key, b, ctr, tail, U32.or(U32.or(flags, start), CHUNK_END())}
    case Con{b, rest}:
      chunk_out(rest, cv_of(compress(key, b, ctr, 64, U32.or(flags, start))),
        ctr, flags, 0, tail)

def parent_out(l: CV, r: CV, key: CV, flags: U32) -> Out:
  CV{l0, l1, l2, l3, l4, l5, l6, l7} = l
  CV{r0, r1, r2, r3, r4, r5, r6, r7} = r
  Out{key, W16{l0, l1, l2, l3, l4, l5, l6, l7, r0, r1, r2, r3, r4, r5, r6, r7}, Ctr{0, 0}, 64,
    U32.or(flags, PARENT())}

def out_cv(o: Out) -> CV:
  Out{key, blk, ctr, len, flags} = o
  cv_of(compress(key, blk, ctr, len, flags))

# Root output replaces the node's own counter with the output block index.
def root_words(o: Out, ctr: Ctr) -> W16:
  Out{key, blk, own, len, flags} = o
  compress(key, blk, ctr, len, U32.or(flags, ROOT()))

def root_bytes(nblk: Nat, +o: Out, +ctr: Ctr) -> List<&2, U32>:
  match nblk:
    case 0n:
      Nil{}
    case 1n+p:
      List.append(&2, U32, w16_bytes(root_words(o, ctr)),
        root_bytes(p, o, ctr_inc(ctr)))

# Chunks in the left subtree: the largest power of two below the total.
def pow2_below(fuel: Nat, +k: Ctr, +n: Nat) -> Ctr:
  match fuel:
    case 0n:
      k
    case 1n+f:
      pow2_below(f, Bool.pick(Ctr, Nat.is_lt(Nat.double(ctr_nat(k)), n),
        ctr_double(k), k), n)

# depth bounds the tree height; hash_all passes the block count, which is
# always larger. It reaches zero only for empty input, where the chunk path
# is already the right answer.
def tree(depth: Nat, single: Bool, +blocks: List<&2, W16>, +nblocks: Nat,
  +key: CV, +ctr: Ctr, +flags: U32, tail: U32) -> Out:
  match depth:
    case 0n:
      chunk_out(blocks, key, ctr, flags, CHUNK_START(), tail)
    case 1n+p:
      match single:
        case True{}:
          chunk_out(blocks, key, ctr, flags, CHUNK_START(), tail)
        case False{}:
          +q = p
          +nchunks = Nat.div(Nat.add(nblocks, 15n), 16n)
          +left = pow2_below(nchunks, Ctr{1, 0}, nchunks)
          +lb = Nat.mul(ctr_nat(left), 16n)
          +rb = Nat.sub(nblocks, lb)
          a b = tree(q, Nat.is_le(lb, 16n), List.take(&2, W16, blocks, lb),
                  lb, key, ctr, flags, 64)
                tree(q, Nat.is_le(rb, 16n), List.drop(&2, W16, blocks, lb),
                  rb, key, ctr_add(ctr, left), flags, tail)
          parent_out(out_cv(a), out_cv(b), key, flags)

def hash_all(+input: List<&2, U32>, key: CV, flags: U32) -> Out:
  +n = List.length(&2, U32, input)
  +nb = Nat.div(Nat.add(n, 63n), 64n)
  tree(nb, Nat.is_le(nb, 16n), blocks_of(input, n), nb, key, Ctr{0, 0}, flags,
    tail_len(n))

def xof(o: Out, +len: Nat) -> List<&2, U32>:
  List.take(&2, U32, root_bytes(Nat.div(Nat.add(len, 63n), 64n), o,
    Ctr{0, 0}), len)


def w16_list(b: W16) -> List<&2, U32>:
  W16{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15} = b
  [w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15]

def cv_list(v: CV) -> List<&2, U32>:
  CV{v0, v1, v2, v3, v4, v5, v6, v7} = v
  [v0, v1, v2, v3, v4, v5, v6, v7]
