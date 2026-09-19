# Gates: bend-blake3

OWNS: bend-blake3/**

Scope: BLAKE3 in Bend with a public API, an independent executable
specification, machine-checked laws relating the two, and a test harness
that runs the published vectors.

- [ ] G1: Every law stated in LAWS.bend is proven; no claim is left open.
  CHECK: bend PROOF.bend
  EXPECT: All terms check.
  EVIDENCE: pending

- [ ] G2: Every module type-checks on its own, not only as part of the whole.
  CHECK: bend gpu.bend --checkup
  EXPECT: All terms check.
  EVIDENCE: pending

- [ ] G3: The implementation matches the published vectors in hash mode, at all 35 input lengths up to 102400 bytes.
  CHECK: python3 test_blake3.py --mode hash
  EXPECT: HASH OK
  EVIDENCE: pending

- [ ] G4: The implementation matches the published vectors in keyed_hash mode.
  CHECK: python3 test_blake3.py --mode keyed
  EXPECT: KEYED OK
  EVIDENCE: pending

- [ ] G5: The implementation matches the published vectors in derive_key mode.
  CHECK: python3 test_blake3.py --mode derive
  EXPECT: DERIVE OK
  EVIDENCE: pending

- [ ] G6: Extendable output matches the vectors' 131-byte outputs in all three modes.
  CHECK: python3 test_blake3.py --mode xof
  EXPECT: XOF OK
  EVIDENCE: pending

- [ ] G7: The specification matches the published vectors on its own, so the two sides are not merely checked against each other.
  CHECK: python3 test_blake3.py --mode spec
  EXPECT: SPEC OK
  EVIDENCE: pending

- [ ] G8: Implementation and specification agree on inputs the vectors do not cover: random bytes, uneven trees, output lengths that are not a multiple of 64.
  CHECK: python3 test_blake3.py --mode diff
  EXPECT: DIFF OK
  EVIDENCE: pending

- [ ] G9: The JavaScript backend compiles and agrees with the native backend.
  CHECK: python3 test_blake3.py --mode js
  EXPECT: JS OK
  EVIDENCE: pending

- [ ] G10: The proofs are not vacuous: each of the 29 seeded defects is rejected by the proof gate.
  CHECK: python3 test_blake3.py --mode mutate
  EXPECT: MUTATION OK
  EVIDENCE: pending

- [ ] G13: The Metal build compiles, and its digests match the published
  vectors in all three modes at 131 bytes of output.
  CHECK: python3 test_blake3.py --mode gpu
  EXPECT: GPU OK
  EVIDENCE: pending

- [ ] G11: The example runs and prints the published digest of "abc".
  CHECK: bend main.bend
  EXPECT: 6437b3ac38465133ffb63b75273a8db548c558465d79db03fd359c6cd5bd9d85
  EVIDENCE: pending

- [x] G12: README claims match the laws actually closed in PROOF.bend and
  the checks the harness actually runs; nothing is claimed that no gate
  supports.
  EVIDENCE: manual review 2026-09-19, revised after the README was rewritten
  without mid-sentence colons or semicolons. Every figure was re-counted after
  the rewrite and none moved. Counted against the sources: LAWS.bend holds 37 laws and
  PROOF.bend 37 proofs, 16 quantified over every input word and 21 with fixed
  inputs, matching the README's split. DEFECTS holds 29 entries, each required
  to fail at a named law rather than at the type checker, and run_diff covers
  33 lengths; both match the text. The harness offers exactly the nine modes
  the README lists, and this ledger holds 13 gates as stated. gpu.bend exports
  four hashing functions, so the README no longer says five. spec.bend imports
  only Base, and core.bend carries no GPU marker, so the default build needs
  only clang. The JavaScript limit was measured: 16384 bytes passes, 31744
  overflows. The 4 MB digest matches the official reference implementation
  compiled from source, and is the same on the CPU and Metal builds and at 1,
  2, 4 and 8 threads. The speed table was measured best of five with the input
  already read. CUDA is named as untested, because it is. An earlier README
  claim of a parallel speedup compared a cold first run with warm runs and was
  wrong; it is replaced by measured figures, which show extra threads and the
  GPU are both slower. No README claim lacks a gate.
