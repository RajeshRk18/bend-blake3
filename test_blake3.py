#!/usr/bin/env python3
"""Checks the Bend BLAKE3 implementation against the official test vectors."""

import argparse
import concurrent.futures
import json
import os
import random
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
BEND = shutil.which("bend") or os.path.expanduser("~/.bend/bin/bend")
VECTORS = os.path.join(HERE, "vectors.json")
SOURCES = [f for f in os.listdir(HERE) if f.endswith(".bend")]

# The vectors define input of length n as the bytes i % 251.
def make_input(n):
    return bytes(i % 251 for i in range(n))


def newer_than(target, sources):
    if not os.path.exists(target):
        return False
    t = os.path.getmtime(target)
    return all(os.path.getmtime(os.path.join(HERE, s)) <= t for s in sources)


def build(target, flag, entry="cli.bend"):
    if newer_than(os.path.join(HERE, target), SOURCES):
        return
    r = subprocess.run([BEND, entry, "-o", flag], cwd=HERE,
                       capture_output=True, text=True)
    if r.returncode != 0 or not os.path.exists(os.path.join(HERE, target)):
        sys.exit("build failed: " + r.stdout + r.stderr)


class Runner:
    """Feeds one case to the compiled hasher and returns its hex digest."""

    def __init__(self, vectors, argv):
        self.argv = argv
        self.dir = tempfile.mkdtemp(prefix="bend-blake3-")
        with open(os.path.join(self.dir, "key"), "wb") as f:
            f.write(vectors["key"].encode())
        with open(os.path.join(self.dir, "context"), "wb") as f:
            f.write(vectors["context_string"].encode())

    def close(self):
        shutil.rmtree(self.dir, ignore_errors=True)

    def digest(self, data, mode, out_len, impl="impl"):
        with open(os.path.join(self.dir, "input"), "wb") as f:
            f.write(data)
        env = dict(os.environ, B3_DIR=self.dir, B3_MODE=mode,
                   B3_LEN=str(out_len), B3_IMPL=impl)
        r = subprocess.run(self.argv, cwd=HERE, env=env,
                           capture_output=True, text=True)
        if r.returncode != 0:
            return "run failed: " + (r.stderr.strip() or r.stdout.strip())
        return r.stdout.strip()


def compare(runner, cases, modes, out_len, label, impl="impl"):
    bad = 0
    for case in cases:
        data = make_input(case["input_len"])
        for mode, field in modes:
            want = case[field][:out_len * 2]
            got = runner.digest(data, mode, out_len, impl)
            if got != want:
                bad += 1
                print("FAIL %s len=%d mode=%s\n  want %s\n  got  %s"
                      % (label, case["input_len"], mode, want, got))
    return bad


MODES = [("hash", "hash"), ("keyed", "keyed_hash"), ("derive", "derive_key")]

# Each defect is a single edit to the implementation that leaves it a valid
# Bend program but breaks agreement with the specification.
DEFECTS = [
    ("core.bend", "rotr(U32.xor(d, a), 16n)", "rotr(U32.xor(d, a), 17n)"),
    ("core.bend", "rotr(U32.xor(b, c), 12n)", "rotr(U32.xor(b, c), 13n)"),
    ("core.bend", "rotr(U32.xor(d, a), 8n)", "rotr(U32.xor(d, a), 9n)"),
    ("core.bend", "rotr(U32.xor(b, c), 7n)", "rotr(U32.xor(b, c), 6n)"),
    ("core.bend", "+a = U32.add(U32.add(a, b), mx)", "+a = U32.xor(U32.add(a, b), mx)"),
    ("core.bend", "+c = U32.add(c, d)\n  +b = rotr", "+c = U32.sub(c, d)\n  +b = rotr"),
    ("core.bend", "def iv0() -> U32:\n  1779033703", "def iv0() -> U32:\n  1779033704"),
    ("core.bend", "def iv3() -> U32:\n  2773480762", "def iv3() -> U32:\n  2773480763"),
    ("core.bend", "W16{m2, m6, m3, m10", "W16{m2, m6, m10, m3"),
    ("core.bend", "def CHUNK_END() -> U32:\n  2", "def CHUNK_END() -> U32:\n  3"),
    ("core.bend", "def PARENT() -> U32:\n  4", "def PARENT() -> U32:\n  5"),
    ("core.bend", "def ROOT() -> U32:\n  8", "def ROOT() -> U32:\n  9"),
    ("core.bend", "U32.or(U32.shln(b2, 16n),\n    U32.shln(b3, 24n))",
     "U32.or(U32.shln(b2, 24n),\n    U32.shln(b3, 16n))"),
    ("core.bend", "  st = round(st, m)\n  +m = permute(m)\n  st = round(st, m)\n  +m = permute(m)\n  st = round(st, m)\n  +m = permute(m)\n  st = round(st, m)\n  +m = permute(m)\n  st = round(st, m)\n  +m = permute(m)\n  st = round(st, m)\n  +m = permute(m)\n  st = round(st, m)",
     "  st = round(st, m)\n  +m = permute(m)\n  st = round(st, m)\n  +m = permute(m)\n  st = round(st, m)\n  +m = permute(m)\n  st = round(st, m)\n  +m = permute(m)\n  st = round(st, m)\n  +m = permute(m)\n  st = round(st, m)"),
    ("core.bend", "U32.xor(t0, t8)", "U32.xor(t0, t9)"),
    ("core.bend", "def CHUNK_START() -> U32:\n  1", "def CHUNK_START() -> U32:\n  3"),
    ("core.bend", "def KEYED_HASH() -> U32:\n  16", "def KEYED_HASH() -> U32:\n  17"),
    ("core.bend", "def DERIVE_KEY_MATERIAL() -> U32:\n  64",
     "def DERIVE_KEY_MATERIAL() -> U32:\n  65"),
    ("core.bend", "  ctr_add(c, Ctr{1, 0})", "  ctr_add(c, Ctr{2, 0})"),
    ("core.bend", "  [U32.and(w, 255), U32.and(U32.shrn(w, 8n), 255),",
     "  [U32.and(U32.shrn(w, 8n), 255), U32.and(w, 255),"),
    ("core.bend", "U32.from_nat(Nat.add(Nat.mod(Nat.sub(n, 1n), 64n), 1n))",
     "U32.from_nat(Nat.mod(n, 64n))"),
    ("core.bend", "compress(key, b, ctr, 64, U32.or(flags, start))",
     "compress(key, b, ctr, 63, U32.or(flags, start))"),
    ("core.bend", "r4, r5, r6, r7}, Ctr{0, 0}, 64,", "r4, r5, r6, r7}, Ctr{1, 0}, 64,"),
    ("core.bend", "Bool.pick(Ctr, Nat.is_lt(Nat.double(ctr_nat(k)), n),",
     "Bool.pick(Ctr, Nat.is_le(Nat.double(ctr_nat(k)), n),"),
    ("core.bend", "  CV{w0, w1, w2, w3, w4, w5, w6, w7}",
     "  CV{w0, w1, w2, w3, w4, w5, w6, w8}"),
    ("core.bend", "Ctr{U32.shl(lo), U32.or(U32.shl(hi), U32.shrn(lo, 31n))}",
     "Ctr{lo, U32.or(U32.shl(hi), U32.shrn(lo, 31n))}"),
    ("core.bend", "  +s = U32.add(al, bl)", "  +s = U32.sub(al, bl)"),
    ("core.bend", "  Nat.add(U32.to_nat(lo), Nat.mul(U32.to_nat(hi)",
     "  Nat.add(Nat.double(U32.to_nat(lo)), Nat.mul(U32.to_nat(hi)"),
    ("blake3.bend", "C.KEYED_HASH()", "C.DERIVE_KEY_MATERIAL()"),
]


def check_defect(index, name, old, new):
    """Apply one defect in a throwaway copy and report whether the gate held."""
    work = tempfile.mkdtemp(prefix="bend-blake3-defect-")
    try:
        for f in os.listdir(HERE):
            if f.endswith(".bend"):
                shutil.copy(os.path.join(HERE, f), work)
        source = open(os.path.join(HERE, name)).read()
        if source.count(old) != 1:
            return index, "does not apply cleanly to %s" % name
        with open(os.path.join(work, name), "w") as f:
            f.write(source.replace(old, new))
        r = subprocess.run([BEND, "PROOF.bend"], cwd=work,
                           capture_output=True, text=True)
        label = "%s -> %s" % (old.splitlines()[0], new.splitlines()[0])
        if r.returncode == 0 and "All terms check." in r.stdout:
            return index, "%s was not caught" % label
        # A defect the checker rejects on its own says nothing about the laws.
        if "Location: LAWS." not in r.stdout + r.stderr:
            return index, "%s was rejected by the checker, not by a law" % label
        return index, None
    finally:
        shutil.rmtree(work, ignore_errors=True)


def run_mutations(workers=2):
    """Each defect must make the proof gate fail; a passing gate is vacuous.
    Defects are applied to a copy, so the checked-in sources are never edited."""
    bad = 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as pool:
        futures = [pool.submit(check_defect, i, *d)
                   for i, d in enumerate(DEFECTS)]
        for f in concurrent.futures.as_completed(futures):
            index, problem = f.result()
            if problem:
                bad += 1
                print("FAIL defect %d %s" % (index, problem))
    return bad


def run_diff(runner):
    """Implementation against specification on inputs the vectors do not cover:
    random bytes, odd lengths, unbalanced trees, odd output lengths."""
    rng = random.Random(20260918)
    lengths = [0, 1, 17, 63, 64, 65, 100, 512, 1023, 1024, 1025, 1500, 2048,
               2049, 2050, 3072, 3073, 4096, 4097, 5000]
    lengths += [rng.randrange(0, 5000) for _ in range(10)]
    lengths += [20000, 50000, 102400]
    bad = 0
    for n in lengths:
        data = bytes(rng.randrange(256) for _ in range(n))
        for mode, _ in MODES:
            for out_len in (32, 77):
                got = runner.digest(data, mode, out_len, "impl")
                want = runner.digest(data, mode, out_len, "spec")
                if got != want:
                    bad += 1
                    print("FAIL diff len=%d mode=%s out=%d\n  impl %s\n  spec %s"
                          % (n, mode, out_len, got, want))
    return bad


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--mode", required=True,
                    choices=["hash", "keyed", "derive", "xof", "spec", "diff",
                             "js", "gpu", "mutate"])
    args = ap.parse_args()

    if args.mode == "mutate":
        bad = run_mutations()
        print("MUTATION OK" if bad == 0 else "MUTATION FAILED: %d" % bad)
        sys.exit(1 if bad else 0)

    vectors = json.load(open(VECTORS))
    cases = vectors["cases"]

    if args.mode == "gpu":
        build("b3gpu", "b3gpu", "gpucli.bend")
        runner = Runner(vectors, ["./b3gpu", "--gpu", "4GB"])
        bad = compare(runner, cases, MODES, 131, "gpu")
        runner.close()
        print("GPU OK" if bad == 0 else "GPU FAILED: %d" % bad)
        sys.exit(1 if bad else 0)

    if args.mode == "js":
        build("cli.js", "cli.js")
        runner = Runner(vectors, ["bun", "cli.js"])
        # The JS backend recurses per list cell, so it is checked on the
        # inputs that fit its stack.
        small = [c for c in cases if c["input_len"] <= 16384]
        bad = compare(runner, small, MODES, 32, "js")
        runner.close()
        print("JS OK" if bad == 0 else "JS FAILED: %d" % bad)
        sys.exit(1 if bad else 0)

    build("b3", "b3")
    runner = Runner(vectors, ["./b3"])
    if args.mode == "spec":
        bad = compare(runner, cases, MODES, 32, "spec", impl="spec")
        runner.close()
        print("SPEC OK" if bad == 0 else "SPEC FAILED: %d" % bad)
        sys.exit(1 if bad else 0)
    if args.mode == "diff":
        bad = run_diff(runner)
        runner.close()
        print("DIFF OK" if bad == 0 else "DIFF FAILED: %d" % bad)
        sys.exit(1 if bad else 0)
    if args.mode == "xof":
        bad = compare(runner, cases, MODES, 131, "xof")
        label = "XOF"
    else:
        modes = [m for m in MODES if m[0] == args.mode]
        bad = compare(runner, cases, modes, 32, args.mode)
        label = args.mode.upper()
    runner.close()
    print("%s OK" % label if bad == 0 else "%s FAILED: %d" % (label, bad))
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
