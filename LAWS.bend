# Claims about the implementation, stated against the executable
# specification. Each is proven by a definition of the same name in
# PROOF.bend.

import Base
import ./core.bend as C
import ./spec.bend as S
import ./blake3.bend as B

# The message of length n used by the concrete claims: byte i is i mod 251.
def next(+i: U32) -> U32:
  Bool.pick(U32, U32.is_eq(i, 250), 0, U32.add(i, 1))

def msg.go(n: Nat, +i: U32) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+p:
      i <> msg.go(p, next(i))

def msg(n: Nat) -> List<&2, U32>:
  msg.go(n, 0)

# Chunks the implementation puts in a left subtree, for a tree of n chunks.
def left_chunks(+n: Nat) -> Nat:
  C.ctr_nat(C.pow2_below(n, C.Ctr{1, 0}, n))

law iv_agrees:
  {C.cv_list(C.iv()) == S.iv() : List<&2, U32>}

law flags_agree:
  {[C.CHUNK_START(), C.CHUNK_END(), C.PARENT(), C.ROOT(), C.KEYED_HASH(),
    C.DERIVE_KEY_CONTEXT(), C.DERIVE_KEY_MATERIAL()] ==
    [S.CHUNK_START(), S.CHUNK_END(), S.PARENT(), S.ROOT(), S.KEYED_HASH(),
    S.DERIVE_KEY_CONTEXT(), S.DERIVE_KEY_MATERIAL()] : List<&2, U32>}

# The left subtree takes the largest power of two chunks below the total.
law split_rule:
  {[left_chunks(2n), left_chunks(3n), left_chunks(4n), left_chunks(5n),
    left_chunks(8n), left_chunks(9n), left_chunks(100n), left_chunks(1024n),
    left_chunks(1025n)] ==
    [1n, 2n, 2n, 4n, 4n, 8n, 64n, 512n, 1024n] : List<&2, Nat>}

# A parent node, whose counter the root output would otherwise hide.
law parent_agrees:
  {C.cv_list(C.out_cv(C.parent_out(C.CV{1, 2, 3, 4, 5, 6, 7, 8},
    C.CV{9, 10, 11, 12, 13, 14, 15, 16}, C.iv(), 0))) ==
    S.parent_cv([1, 2, 3, 4, 5, 6, 7, 8], [9, 10, 11, 12, 13, 14, 15, 16],
    S.iv(), 0) : List<&2, U32>}

law parent_agrees_keyed:
  {C.cv_list(C.out_cv(C.parent_out(C.CV{1, 2, 3, 4, 5, 6, 7, 8},
    C.CV{9, 10, 11, 12, 13, 14, 15, 16}, C.iv(), C.KEYED_HASH()))) ==
    S.parent_cv([1, 2, 3, 4, 5, 6, 7, 8], [9, 10, 11, 12, 13, 14, 15, 16],
    S.iv(), S.KEYED_HASH()) : List<&2, U32>}

law mix0_agrees:
  for s0: U32
  for s1: U32
  for s2: U32
  for s3: U32
  for s4: U32
  for s5: U32
  for s6: U32
  for s7: U32
  for s8: U32
  for s9: U32
  for s10: U32
  for s11: U32
  for s12: U32
  for s13: U32
  for s14: U32
  for s15: U32
  for mx: U32
  for my: U32
  {C.w16_list(C.mix0(C.W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15}, mx, my)) ==
    S.g([s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15], 0n, 4n, 8n, 12n, mx, my) : List<&2, U32>}

law mix1_agrees:
  for s0: U32
  for s1: U32
  for s2: U32
  for s3: U32
  for s4: U32
  for s5: U32
  for s6: U32
  for s7: U32
  for s8: U32
  for s9: U32
  for s10: U32
  for s11: U32
  for s12: U32
  for s13: U32
  for s14: U32
  for s15: U32
  for mx: U32
  for my: U32
  {C.w16_list(C.mix1(C.W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15}, mx, my)) ==
    S.g([s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15], 1n, 5n, 9n, 13n, mx, my) : List<&2, U32>}

law mix2_agrees:
  for s0: U32
  for s1: U32
  for s2: U32
  for s3: U32
  for s4: U32
  for s5: U32
  for s6: U32
  for s7: U32
  for s8: U32
  for s9: U32
  for s10: U32
  for s11: U32
  for s12: U32
  for s13: U32
  for s14: U32
  for s15: U32
  for mx: U32
  for my: U32
  {C.w16_list(C.mix2(C.W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15}, mx, my)) ==
    S.g([s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15], 2n, 6n, 10n, 14n, mx, my) : List<&2, U32>}

law mix3_agrees:
  for s0: U32
  for s1: U32
  for s2: U32
  for s3: U32
  for s4: U32
  for s5: U32
  for s6: U32
  for s7: U32
  for s8: U32
  for s9: U32
  for s10: U32
  for s11: U32
  for s12: U32
  for s13: U32
  for s14: U32
  for s15: U32
  for mx: U32
  for my: U32
  {C.w16_list(C.mix3(C.W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15}, mx, my)) ==
    S.g([s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15], 3n, 7n, 11n, 15n, mx, my) : List<&2, U32>}

law mix4_agrees:
  for s0: U32
  for s1: U32
  for s2: U32
  for s3: U32
  for s4: U32
  for s5: U32
  for s6: U32
  for s7: U32
  for s8: U32
  for s9: U32
  for s10: U32
  for s11: U32
  for s12: U32
  for s13: U32
  for s14: U32
  for s15: U32
  for mx: U32
  for my: U32
  {C.w16_list(C.mix4(C.W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15}, mx, my)) ==
    S.g([s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15], 0n, 5n, 10n, 15n, mx, my) : List<&2, U32>}

law mix5_agrees:
  for s0: U32
  for s1: U32
  for s2: U32
  for s3: U32
  for s4: U32
  for s5: U32
  for s6: U32
  for s7: U32
  for s8: U32
  for s9: U32
  for s10: U32
  for s11: U32
  for s12: U32
  for s13: U32
  for s14: U32
  for s15: U32
  for mx: U32
  for my: U32
  {C.w16_list(C.mix5(C.W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15}, mx, my)) ==
    S.g([s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15], 1n, 6n, 11n, 12n, mx, my) : List<&2, U32>}

law mix6_agrees:
  for s0: U32
  for s1: U32
  for s2: U32
  for s3: U32
  for s4: U32
  for s5: U32
  for s6: U32
  for s7: U32
  for s8: U32
  for s9: U32
  for s10: U32
  for s11: U32
  for s12: U32
  for s13: U32
  for s14: U32
  for s15: U32
  for mx: U32
  for my: U32
  {C.w16_list(C.mix6(C.W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15}, mx, my)) ==
    S.g([s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15], 2n, 7n, 8n, 13n, mx, my) : List<&2, U32>}

law mix7_agrees:
  for s0: U32
  for s1: U32
  for s2: U32
  for s3: U32
  for s4: U32
  for s5: U32
  for s6: U32
  for s7: U32
  for s8: U32
  for s9: U32
  for s10: U32
  for s11: U32
  for s12: U32
  for s13: U32
  for s14: U32
  for s15: U32
  for mx: U32
  for my: U32
  {C.w16_list(C.mix7(C.W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15}, mx, my)) ==
    S.g([s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15], 3n, 4n, 9n, 14n, mx, my) : List<&2, U32>}

law round_agrees:
  for s0: U32
  for s1: U32
  for s2: U32
  for s3: U32
  for s4: U32
  for s5: U32
  for s6: U32
  for s7: U32
  for s8: U32
  for s9: U32
  for s10: U32
  for s11: U32
  for s12: U32
  for s13: U32
  for s14: U32
  for s15: U32
  for m0: U32
  for m1: U32
  for m2: U32
  for m3: U32
  for m4: U32
  for m5: U32
  for m6: U32
  for m7: U32
  for m8: U32
  for m9: U32
  for m10: U32
  for m11: U32
  for m12: U32
  for m13: U32
  for m14: U32
  for m15: U32
  {C.w16_list(C.round(C.W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15}, C.W16{m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15})) ==
    S.round([s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15], [m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15]) : List<&2, U32>}

law permute_agrees:
  for m0: U32
  for m1: U32
  for m2: U32
  for m3: U32
  for m4: U32
  for m5: U32
  for m6: U32
  for m7: U32
  for m8: U32
  for m9: U32
  for m10: U32
  for m11: U32
  for m12: U32
  for m13: U32
  for m14: U32
  for m15: U32
  {C.w16_list(C.permute(C.W16{m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15})) == S.permute([m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15]) :
    List<&2, U32>}

law feed_agrees:
  for s0: U32
  for s1: U32
  for s2: U32
  for s3: U32
  for s4: U32
  for s5: U32
  for s6: U32
  for s7: U32
  for s8: U32
  for s9: U32
  for s10: U32
  for s11: U32
  for s12: U32
  for s13: U32
  for s14: U32
  for s15: U32
  for c0: U32
  for c1: U32
  for c2: U32
  for c3: U32
  for c4: U32
  for c5: U32
  for c6: U32
  for c7: U32
  {C.w16_list(C.feed(C.W16{s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15}, C.CV{c0, c1, c2, c3, c4, c5, c6, c7})) ==
    S.feed([s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15], [c0, c1, c2, c3, c4, c5, c6, c7]) : List<&2, U32>}

law cv_of_agrees:
  for w0: U32
  for w1: U32
  for w2: U32
  for w3: U32
  for w4: U32
  for w5: U32
  for w6: U32
  for w7: U32
  for w8: U32
  for w9: U32
  for w10: U32
  for w11: U32
  for w12: U32
  for w13: U32
  for w14: U32
  for w15: U32
  {C.cv_list(C.cv_of(C.W16{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15})) == S.first8([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15]) :
    List<&2, U32>}

law le_word_agrees:
  for b0: U32
  for b1: U32
  for b2: U32
  for b3: U32
  {C.le_word(b0, b1, b2, b3) == S.le(b0, b1, b2, b3) : U32}

law word_bytes_agrees:
  for w: U32
  {C.word_bytes(w) == S.to_bytes(w) : List<&2, U32>}

law block_bytes_agrees:
  for w0: U32
  for w1: U32
  for w2: U32
  for w3: U32
  for w4: U32
  for w5: U32
  for w6: U32
  for w7: U32
  for w8: U32
  for w9: U32
  for w10: U32
  for w11: U32
  for w12: U32
  for w13: U32
  for w14: U32
  for w15: U32
  {C.w16_bytes(C.W16{w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15}) == S.word_bytes16([w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15]) :
    List<&2, U32>}

law block_words_agrees:
  for b0: U32
  for b1: U32
  for b2: U32
  for b3: U32
  for b4: U32
  for b5: U32
  for b6: U32
  for b7: U32
  for b8: U32
  for b9: U32
  for b10: U32
  for b11: U32
  for b12: U32
  for b13: U32
  for b14: U32
  for b15: U32
  for b16: U32
  for b17: U32
  for b18: U32
  for b19: U32
  for b20: U32
  for b21: U32
  for b22: U32
  for b23: U32
  for b24: U32
  for b25: U32
  for b26: U32
  for b27: U32
  for b28: U32
  for b29: U32
  for b30: U32
  for b31: U32
  for b32: U32
  for b33: U32
  for b34: U32
  for b35: U32
  for b36: U32
  for b37: U32
  for b38: U32
  for b39: U32
  for b40: U32
  for b41: U32
  for b42: U32
  for b43: U32
  for b44: U32
  for b45: U32
  for b46: U32
  for b47: U32
  for b48: U32
  for b49: U32
  for b50: U32
  for b51: U32
  for b52: U32
  for b53: U32
  for b54: U32
  for b55: U32
  for b56: U32
  for b57: U32
  for b58: U32
  for b59: U32
  for b60: U32
  for b61: U32
  for b62: U32
  for b63: U32
  {C.le_words([b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16, b17, b18, b19, b20, b21, b22, b23, b24, b25, b26, b27, b28, b29, b30, b31, b32, b33, b34, b35, b36, b37, b38, b39, b40, b41, b42, b43, b44, b45, b46, b47, b48, b49, b50, b51, b52, b53, b54, b55, b56, b57, b58, b59, b60, b61, b62, b63]) ==
    S.block_words([b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16, b17, b18, b19, b20, b21, b22, b23, b24, b25, b26, b27, b28, b29, b30, b31, b32, b33, b34, b35, b36, b37, b38, b39, b40, b41, b42, b43, b44, b45, b46, b47, b48, b49, b50, b51, b52, b53, b54, b55, b56, b57, b58, b59, b60, b61, b62, b63]) : List<&2, U32>}

law hash_0:
  {B.hash(msg(0n)) == S.hash(msg(0n), 32n) : List<&2, U32>}

law hash_1:
  {B.hash(msg(1n)) == S.hash(msg(1n), 32n) : List<&2, U32>}

law hash_63:
  {B.hash(msg(63n)) == S.hash(msg(63n), 32n) : List<&2, U32>}

law hash_64:
  {B.hash(msg(64n)) == S.hash(msg(64n), 32n) : List<&2, U32>}

law hash_65:
  {B.hash(msg(65n)) == S.hash(msg(65n), 32n) : List<&2, U32>}

law hash_127:
  {B.hash(msg(127n)) == S.hash(msg(127n), 32n) : List<&2, U32>}

law hash_128:
  {B.hash(msg(128n)) == S.hash(msg(128n), 32n) : List<&2, U32>}

law hash_129:
  {B.hash(msg(129n)) == S.hash(msg(129n), 32n) : List<&2, U32>}

law hash_1023:
  {B.hash(msg(1023n)) == S.hash(msg(1023n), 32n) : List<&2, U32>}

law hash_1024:
  {B.hash(msg(1024n)) == S.hash(msg(1024n), 32n) : List<&2, U32>}

law hash_1025:
  {B.hash(msg(1025n)) == S.hash(msg(1025n), 32n) : List<&2, U32>}

law xof_131:
  {B.hash_xof(msg(64n), 131n) == S.hash(msg(64n), 131n) : List<&2, U32>}

law keyed_agrees:
  {B.keyed_hash(msg(32n), msg(64n), 32n) ==
    Some{S.keyed(msg(32n), msg(64n), 32n)} : Maybe<&2, List<&2, U32>>}

law keyed_rejects_short_key:
  {B.keyed_hash(msg(31n), msg(64n), 32n) == None{} :
    Maybe<&2, List<&2, U32>>}

law keyed_rejects_long_key:
  {B.keyed_hash(msg(33n), msg(64n), 32n) == None{} :
    Maybe<&2, List<&2, U32>>}

law derive_agrees:
  {B.derive_key(msg(16n), msg(64n), 32n) ==
    S.derive(msg(16n), msg(64n), 32n) : List<&2, U32>}
