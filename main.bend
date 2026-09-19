import Base
import ./blake3.bend as B

def keyed_line(r: Maybe<&2, List<&2, U32>>) -> String:
  match r:
    case None{}:
      "key must be 32 bytes"
    case Some{bs}:
      B.hex(bs)

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print("hash        " ++ B.hex(B.hash(B.ascii("abc"))))
    IO.print("xof 64      " ++ B.hex(B.hash_xof(B.ascii("abc"), 64n)))
    IO.print("keyed_hash  " ++ keyed_line(B.keyed_hash(
      B.ascii("whats the Elvish word for friend"), B.ascii("abc"), 32n)))
    IO.print("derive_key  " ++ B.hex(B.derive_key(
      B.ascii("BLAKE3 2019-12-27 16:29:52 test vectors context"),
      B.ascii("abc"), 32n)))
