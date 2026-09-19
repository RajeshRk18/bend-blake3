import Base
import ./cli.bend as Q
import ./gpu.bend as G
import ./blake3.bend as B

def run(mode: Q.Mode, input: List<&2, U32>, key: List<&2, U32>,
  context: List<&2, U32>, +len: Nat) -> String:
  match mode:
    case Q.Hash{}:
      B.hex(G.hash_xof(input, len))
    case Q.Keyed{}:
      Q.run.keyed(G.keyed_hash(key, input, len))
    case Q.Derive{}:
      B.hex(G.derive_key(context, input, len))

def run_dir(+dir: String, mode: String, len: String) -> IO(Unit):
  do IO<Unit>:
    input : List<&2, U32> <- Q.read_file(dir ++ "/input")
    key : List<&2, U32> <- Q.read_file(dir ++ "/key")
    context : List<&2, U32> <- Q.read_file(dir ++ "/context")
    IO.print(run(Q.parse_mode(mode), input, key, context,
      Q.parse_len(Nat.read(len))))

def main() -> IO(Unit):
  do IO<Unit>:
    dir : String <- Q.env_or("B3_DIR", ".")
    mode : String <- Q.env_or("B3_MODE", "hash")
    len : String <- Q.env_or("B3_LEN", "32")
    run_dir(dir, mode, len)
