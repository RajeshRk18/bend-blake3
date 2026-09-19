# bend-blake3

BLAKE3 in [Bend](https://bend-lang.com/). Implemented the hash function, the
keyed hash, the key derivation function, and extendable output, on the CPU or on
the GPU. A second program in this repository states what every result must be.
The two are proven equal where Bend can decide it, and tested equal everywhere
else.

## Use

```python
import Base
import ./blake3.bend as B

def main() -> IO(Unit):
  IO.print(B.hex(B.hash(B.ascii("abc"))))
```

| Function | Result |
| --- | --- |
| `hash(input)` | 32 bytes |
| `hash_xof(input, len)` | `len` bytes |
| `keyed_hash(key, input, len)` | `Some` of `len` bytes. `None` if the key is not exactly 32 bytes |
| `derive_key(context, material, len)` | `len` bytes |
| `hex(bytes)`, `ascii(text)` | conversions |

A byte string is a `List<&2, U32>`. Every element must be below 256.

`gpu.bend` exports the same four hashing functions and puts the chunk tree on
the GPU. Change the import to use it, and keep taking `hex` and `ascii` from
`blake3.bend`. Read Speed before you do. Metal is the path measured and gated
here. The same build targets CUDA 12 on Linux, which nobody has tested.

## Files

| File | Holds |
| --- | --- |
| `core.bend` | compression function, chunks, tree, output |
| `blake3.bend` | public API |
| `gpu.bend` | the same API with the tree on the GPU |
| `spec.bend` | the executable specification |
| `LAWS.bend` | the claims |
| `PROOF.bend` | the proofs. `bend PROOF.bend` is the gate |
| `main.bend` | example |
| `cli.bend`, `gpucli.bend` | drivers used by the tests |
| `test_blake3.py` | test harness |
| `vectors.json` | the published BLAKE3 test vectors |
| `GATES.md` | the acceptance ledger these checks answer to |

The implementation walks a chunk tree. Each node splits its input in two and
mixes the halves with a parallel call. The specification works a different way.
It keeps one chunk state and a stack of subtree chaining values, the way the
published algorithm describes it.

The two programs share no code. `spec.bend` imports only `Base`, declares its
own constants, and holds every array as a plain indexed list. That separation is
what makes the proofs worth stating. A specification copied from the
implementation would prove nothing.

## What is proven

`bend PROOF.bend` closes 37 laws in about seventy seconds. A law is a claim
about the code. Bend rejects the file until every claim has a proof.

Sixteen laws hold for every input. They fix no message.

- each of the eight mixing steps of the round function
- the round function, the message permutation, and the feed-forward
- the chaining value taken from a compression output
- little-endian bytes to words, words to bytes, and a whole 64 byte block

Bend proves these by computation, so one line covers every value of every word
it quantifies over. No test vector takes part.

The full compression function cannot be proven this way. It runs seven rounds
and each round feeds the next, so the expanded term doubles at every step. One
round proves in a second. Two rounds do not finish in two minutes.

The other twenty-one laws fix their inputs and run both programs end to end.

- the initialization vector and all seven flag values, against the constants the
  specification declares for itself
- the hash of messages of 0, 1, 63, 64, 65, 127, 128, 129, 1023, 1024 and 1025
  bytes, which reach one block, a full block, a block boundary, a full chunk,
  and a two chunk tree
- 131 bytes of extendable output, which needs three output blocks
- the keyed hash, and its refusal of a 31 byte and a 33 byte key
- key derivation, which runs the pipeline twice
- a parent node, keyed and unkeyed, whose counter and block length the root
  output would otherwise hide
- the split rule, which must take the largest power of two chunks strictly below
  the total, checked at nine chunk counts up to 1025

The 1025 byte law earns its cost. That message is two chunks, so it is the first
size where the recursive tree and the stack machine must agree on a parent node.
Bend checks that they do.

Trees of three chunks or more are proven a piece at a time, through the split
rule and the two parent node laws. Hashing one whole inside the checker costs
two minutes. The tests below do it in a hundredth of a second.

## What is tested

```
python3 test_blake3.py --mode hash     # 35 lengths, published vectors
python3 test_blake3.py --mode keyed
python3 test_blake3.py --mode derive
python3 test_blake3.py --mode xof      # 131 byte output, all three modes
python3 test_blake3.py --mode spec     # the specification against the vectors
python3 test_blake3.py --mode diff     # implementation against specification
python3 test_blake3.py --mode js       # the JavaScript backend
python3 test_blake3.py --mode gpu      # the Metal build against the vectors
python3 test_blake3.py --mode mutate   # the proofs reject seeded defects
```

The first four modes run the 35 published input lengths, up to 102400 bytes, in
all three modes, at 32 and at 131 bytes of output. `spec` runs the specification
over the same vectors, so neither program is only checked against the other.
`diff` compares the two on 33 further lengths of random bytes, and it includes
uneven trees and output lengths that are not a multiple of 64. `gpu` holds the
Metal build to the same answers.

`mutate` keeps the rest honest. It seeds 29 single edits into the
implementation, one at a time, and requires a named law to reject each one. An
edit that only upsets the type checker does not count. Without this, a proof
that holds for nothing would look exactly like a proof that means something.

`GATES.md` records all of it as 13 gates. Each gate carries the command that
decides it and the evidence from the last run.

## Building

```
bend main.bend                # check and run the example
bend gpu.bend --checkup       # check each module alone
bend cli.bend -o b3           # native binary
bend gpucli.bend -o b3gpu     # Metal build, needs Xcode's metal compiler
./b3 --threads 8              # thread count, but read Speed first
./b3gpu --gpu 4GB             # Metal, keep b3gpu.gpu beside the binary
```

`core.bend` carries no GPU marker, so the default build needs only clang and
runs anywhere. `gpu.bend` marks the top call of the tree with `!`, which sends
that call and everything under it to the GPU. Only a build that imports
`gpu.bend` needs the Metal toolchain.

`b3` and `b3gpu` read `input`, `key` and `context` from the directory named by
`B3_DIR`. They take `B3_MODE`, `B3_LEN` and `B3_IMPL`, and `B3_IMPL` works on
`b3` only. Each reads at most 4,000,000 bytes of input.

`bend main.bend` runs `main` inside the checker, which walks the term and
overflows its stack on a large input. Compile a binary for real work. The
JavaScript backend recurses once per list cell and overflows above about 16 KB.

## Speed

Measured on an Apple M4, best of five, hashing only, with the input already
read.

| Input | 1 thread | 8 threads | Metal |
| --- | --- | --- | --- |
| 100 KB | 2 ms | 4 ms | 151 ms |
| 1 MB | 22 ms | 42 ms | 261 ms |
| 4 MB | 86 ms | 166 ms | 728 ms |
| 16 MB | 335 ms | 661 ms | 2572 ms |

That is about 48 MB/s on one thread, and it holds steady across sizes. The
portable reference implementation in Rust, built with `-O` and no SIMD, hashes
the same 4 MB in 8 ms on this machine. A SIMD BLAKE3 is faster again by a wide
margin.

More threads make it slower rather than faster. A perfectly balanced tree of
2048 chunks behaves the same way, so the uneven BLAKE3 tree shape is not the
cause. The input shape is. Each node splits its work with `List.take` and
`List.drop`, so it walks a linked list before it forks. That walk is sequential
and it happens in the parent. Together with the fork and join overhead it costs
more than the parallel mixing saves.

Metal is correct and slower again, and it carries a fixed cost. A 64 byte input
takes about 300 ms through the GPU path against 1 ms on the CPU. A GPU wants
uniform numeric work, and walking a linked list is the opposite of that.

Building the chunk tree once, as a tree, would fix both. Splits would cost
nothing, the recursion would be structural, and the parallel call would finally
get balanced work under it. Until then the parallel call and the GPU path are
correct and idle.

The digest is identical on every path and at every thread count. The hash, xof
and gpu gates all check it.
