import Base
import ./core.bend as C
import ./blake3.bend as B

# The same pipeline as blake3.bend, with the chunk tree handed to the GPU.
# Marking the top call is enough: every parallel call under it follows.
def hash_all(+input: List<&2, U32>, key: C.CV, flags: U32) -> C.Out:
  +n = List.length(&2, U32, input)
  +nb = Nat.div(Nat.add(n, 63n), 64n)
  C.tree!(nb, Nat.is_le(nb, 16n), C.blocks_of(input, n), nb, key, C.Ctr{0, 0},
    flags, C.tail_len(n))

def hash(input: List<&2, U32>) -> List<&2, U32>:
  C.xof(hash_all(input, C.iv(), 0), 32n)

def hash_xof(input: List<&2, U32>, len: Nat) -> List<&2, U32>:
  C.xof(hash_all(input, C.iv(), 0), len)

def keyed_hash.go(key: Maybe<&2, C.CV>, input: List<&2, U32>, len: Nat) ->
  Maybe<&2, List<&2, U32>>:
  match key:
    case None{}:
      None{}
    case Some{k}:
      Some{C.xof(hash_all(input, k, C.KEYED_HASH()), len)}

def keyed_hash(key: List<&2, U32>, input: List<&2, U32>, len: Nat) ->
  Maybe<&2, List<&2, U32>>:
  keyed_hash.go(B.key_cv(key), input, len)

def derive_key(context: List<&2, U32>, material: List<&2, U32>, len: Nat) ->
  List<&2, U32>:
  ck = C.cv_of(C.root_words(hash_all(context, C.iv(), C.DERIVE_KEY_CONTEXT()),
    C.Ctr{0, 0}))
  C.xof(hash_all(material, ck, C.DERIVE_KEY_MATERIAL()), len)
