Kontrol DSS 2024 Stuff
----------------------

# Loop Invariants

One of the proposed examples is to do loop invariants, showcasing one of our advertised strengths: going beyond bounded model checking.

## SumToN example

Following Raouls excellent post, recreate the creation and proving of the `sumToN` loop invariant.

- [src/Gauss.sol](src/Gauss.sol) contains the code to be verified
- [src/GaussSpec.sol](src/GaussSpec.sol) contains the specs
- [src/GaussSpecCode.md](src/GaussSpecCode.md) contains the deployed bytecode, to be used in the invariant. It also contains lemmas dealing with `#sizeWordStack`
- [src/invariant.md](src/invariant.md) contains the rule to summarize the loop and the correspondent claim

### How to reproduce

We can either prove the invariant correct or use it in the proof at [src/GaussSpec.sol](src/GaussSpec.sol).

#### Proving the invariant correct:

1. Build the project with the correct flags:
   ```
   kontrol build --require src/GaussSpecCode.md --module-import GaussSpec:GAUSS-SPEC-CODE --regen --rekompile --verbose
   ```
2. Run the proof with `kevm` (shipped with `kontrol` via `kup`):
   ```
   kevm prove --definition out/kompiled --spec-module GAUSS-CLAIM src/invariant.md --max-depth 1 --save-directory kevm-out --verbose
   ```

#### Proving [src/GaussSpec.sol](src/GaussSpec.sol)`::prove_sumToN` correct

1. Build the project with the correct flags. Note that we're `--requires`ing two files:
   ```
   kontrol build --require src/GaussSpecCode.md --require src/invariant.md --module-import GaussSpec:GAUSS-INVARIANT --regen --rekompile --verbose
   ```
2. Run the proof with `kontrol`. Note the absence of `--bmc-depth`:
   ```
   kontrol prove --mt GaussSpec.prove_sumToN --verbose
   ```
