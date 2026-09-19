import Base
import ./core.bend as C

def hash(input: List<&2, U32>) -> List<&2, U32>:
  C.xof(C.hash_all(input, C.iv(), 0), 32n)

def hash_xof(input: List<&2, U32>, len: Nat) -> List<&2, U32>:
  C.xof(C.hash_all(input, C.iv(), 0), len)

# A key is exactly 32 bytes; anything else is rejected rather than trimmed.
def key_cv(bs: List<&2, U32>) -> Maybe<&2, C.CV>:
  match bs:
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Con{b25, Con{b26, Con{b27, Con{b28, Con{b29, Con{b30, Con{b31, Nil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      Some{C.CV{C.le_word(b0, b1, b2, b3),
        C.le_word(b4, b5, b6, b7),
        C.le_word(b8, b9, b10, b11),
        C.le_word(b12, b13, b14, b15),
        C.le_word(b16, b17, b18, b19),
        C.le_word(b20, b21, b22, b23),
        C.le_word(b24, b25, b26, b27),
        C.le_word(b28, b29, b30, b31)}}
    case _:
      None{}

def keyed_hash.go(key: Maybe<&2, C.CV>, input: List<&2, U32>, len: Nat) ->
  Maybe<&2, List<&2, U32>>:
  match key:
    case None{}:
      None{}
    case Some{k}:
      Some{C.xof(C.hash_all(input, k, C.KEYED_HASH()), len)}

# None unless the key is exactly 32 bytes.
def keyed_hash(key: List<&2, U32>, input: List<&2, U32>, len: Nat) ->
  Maybe<&2, List<&2, U32>>:
  keyed_hash.go(key_cv(key), input, len)

def derive_key(context: List<&2, U32>, material: List<&2, U32>, len: Nat) ->
  List<&2, U32>:
  ck = C.cv_of(C.root_words(C.hash_all(context, C.iv(), C.DERIVE_KEY_CONTEXT()),
    C.Ctr{0, 0}))
  C.xof(C.hash_all(material, ck, C.DERIVE_KEY_MATERIAL()), len)

def hex_digit(d: U32, small: Bool) -> Char:
  match small:
    case True{}:
      Chr{U32.add(48, d)}
    case False{}:
      Chr{U32.add(87, d)}

def hex_char(+d: U32) -> Char:
  hex_digit(d, U32.is_lt(d, 10))

def hex(bs: List<&2, U32>) -> String:
  match bs:
    case Nil{}:
      SNil{}
    case Con{b, rest}:
      +b = b
      SCon{hex_char(U32.shrn(b, 4n)), SCon{hex_char(U32.and(b, 15)), hex(rest)}}

def ascii(s: String) -> List<&2, U32>:
  match s:
    case SNil{}:
      Nil{}
    case SCon{Chr{c}, t}:
      c <> ascii(t)
