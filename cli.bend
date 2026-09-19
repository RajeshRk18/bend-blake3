import Base
import ./blake3.bend as B
import ./spec.bend as S

type Mode is Data:
  Hash{}
  Keyed{}
  Derive{}

type Src is Data:
  Impl{}
  Spec{}

def read_file.after(fr: File & Result<&1, &1, U32 & String, List<&2, U32>>) ->
  IO(List<&2, U32>):
  (f, r) = fr
  do IO<List<&2, U32>>:
    bs : List<&2, U32> <- IO.pass(List<&2, U32>, r)
    File.close(f)
    return bs

def read_file.go(f: File) -> IO(List<&2, U32>):
  do IO<List<&2, U32>>:
    fr : File & Result<&1, &1, U32 & String, List<&2, U32>> <-
      File.read_bytes(f, 4000000)
    read_file.after(fr)

def read_file(path: String) -> IO(List<&2, U32>):
  do IO<List<&2, U32>>:
    f : File <- IO.try(File, File.open(path, "r"))
    read_file.go(f)

def env_or.go(r: Result<&1, &1, U32 & String, String>, d: String) -> String:
  match r:
    case Fail{e}:
      d
    case Done{v}:
      v

def env_or(name: String, d: String) -> IO(String):
  do IO<String>:
    r : Result<&1, &1, U32 & String, String> <- IO.get_env(name)
    return env_or.go(r, d)

def parse_mode.go(keyed: Bool, derive: Bool) -> Mode:
  match keyed:
    case True{}:
      Keyed{}
    case False{}:
      match derive:
        case True{}:
          Derive{}
        case False{}:
          Hash{}

def parse_mode(+s: String) -> Mode:
  parse_mode.go(String.eq(s, "keyed"), String.eq(s, "derive"))

def parse_src.go(spec: Bool) -> Src:
  match spec:
    case True{}:
      Spec{}
    case False{}:
      Impl{}

def parse_src(s: String) -> Src:
  parse_src.go(String.eq(s, "spec"))

def parse_len(m: Maybe<&2, Nat>) -> Nat:
  match m:
    case None{}:
      32n
    case Some{n}:
      n

def run.keyed(r: Maybe<&2, List<&2, U32>>) -> String:
  match r:
    case None{}:
      "error: key must be 32 bytes"
    case Some{bs}:
      B.hex(bs)

def run.impl(mode: Mode, input: List<&2, U32>, key: List<&2, U32>,
  context: List<&2, U32>, +len: Nat) -> String:
  match mode:
    case Hash{}:
      B.hex(B.hash_xof(input, len))
    case Keyed{}:
      run.keyed(B.keyed_hash(key, input, len))
    case Derive{}:
      B.hex(B.derive_key(context, input, len))

def run.spec(mode: Mode, input: List<&2, U32>, key: List<&2, U32>,
  context: List<&2, U32>, +len: Nat) -> String:
  match mode:
    case Hash{}:
      B.hex(S.hash(input, len))
    case Keyed{}:
      B.hex(S.keyed(key, input, len))
    case Derive{}:
      B.hex(S.derive(context, input, len))

def run(src: Src, mode: Mode, input: List<&2, U32>, key: List<&2, U32>,
  context: List<&2, U32>, len: Nat) -> String:
  match src:
    case Impl{}:
      run.impl(mode, input, key, context, len)
    case Spec{}:
      run.spec(mode, input, key, context, len)

def run_dir(+dir: String, src: String, mode: String, len: String) -> IO(Unit):
  do IO<Unit>:
    input : List<&2, U32> <- read_file(dir ++ "/input")
    key : List<&2, U32> <- read_file(dir ++ "/key")
    context : List<&2, U32> <- read_file(dir ++ "/context")
    IO.print(run(parse_src(src), parse_mode(mode), input, key, context,
      parse_len(Nat.read(len))))

def main() -> IO(Unit):
  do IO<Unit>:
    dir : String <- env_or("B3_DIR", ".")
    src : String <- env_or("B3_IMPL", "impl")
    mode : String <- env_or("B3_MODE", "hash")
    len : String <- env_or("B3_LEN", "32")
    run_dir(dir, src, mode, len)
