`sumToN` Verification: The Lemmas
---------------------------------

In this file we provide two different things:
1. A proof of the state update that the `while` loop present in [Gauss.sol::sumToN](Gauss.sol) causes
2. A rewrite rule that substitutes the execution of the `while` loop with the proven state update

## Proving the loop's state update

Thie following `GAUSS-CLAIM` module contains the claim that proves the state update performed by the while loop:

```k
// Importing GaussSpecCode.md is global to this whole file
requires "GaussSpecCode.md"

module GAUSS-CLAIM
  imports FOUNDRY
  imports GAUSS-SPEC-CODE

  claim [gauss-claim]:
    <k>
     ( JUMPI 775 bool2Word ( N:Int <=Int I:Int ) => JUMP 775 )
     ~> #pc [ JUMPI ]
     ~> #execute
     ~> _CONTINUATION:K
    </k>
    <useGas>
      false
    </useGas>
    <program>
      #binRuntime
    </program>
    <jumpDests>
      #computeValidJumpDests ( #binRuntime )
    </jumpDests>
    <wordStack>
      ( I => N ) : ( I *Int (I +Int 1) /Int 2 => N *Int (N +Int 1) /Int 2 ) : 0 : N : WS:WordStack
    </wordStack>
    <pc>
      745
    </pc>
    <activeTracing>
      false
    </activeTracing>
    <stackChecks>
      true
    </stackChecks>
    requires 0 <=Int N andBool N <Int 2 ^Int 128
     andBool 0 <=Int I andBool I <=Int N
     andBool #sizeWordStack(WS) <Int 1013
endmodule
```

To prove this `claim`, as said in the main README, you can run the following from the project root:
1. Build the project correctly
   ```
   kontrol build --require src/GaussSpecCode.md --module-import GaussSpec:GAUSS-SPEC-CODE --regen --rekompile --verbose
   ```
2. Run the claim using `kevm`:
   ```
   kevm prove --definition out/kompiled --spec-module GAUSS-CLAIM src/invariant.md --max-depth 1 --save-directory kevm-out --verbose
   ```

## Turning the state update into a rewrite rule

Once we've proven the state update correct, we can transform it into a K rewrite rule, which will be used instead of regular execution when the loop is encountered.

Note that the only difference between the proven claim and the rewrite rule is that we have moved the functions such as `*Int`, `bool2Word( · )` or `#binRuntime` down to the `requires` clauses. This is because K (and, by extension, Kontrol) doesn't allow functions in the Left Hand Side of a rerwite rule.
The algorithm is simple: every time you see a function behind a `=>`, move it to a requires clause. Also note that this moving-around-functions doesn't affect the meaning of the rewrite rule.

The following `GAUSS-INVARIANT` module contains the rewrite rule that summarizes the `while` loop present in [Gauss.sol::sumToN](Gauss.sol).

```k
module GAUSS-INVARIANT [symbolic]
  imports FOUNDRY
  imports GAUSS-SPEC-CODE

  rule [gauss-invariant]:
    <k>
     ( JUMPI 775 CONDITION => JUMP 775 )
     ~> #pc [ JUMPI ]
     ~> #execute
     ~> _CONTINUATION:K
   </k>
   <useGas>
     false
   </useGas>
   <program>
     PROGRAM
   </program>
   <jumpDests>
     JUMPDESTS
   </jumpDests>
   <wordStack>
     ( I => N ) : ( RESULT => N *Int (N +Int 1) /Int 2 ) : 0 : N : WS:WordStack
   </wordStack>
   <pc>
     745
   </pc>
   <activeTracing>
     false
   </activeTracing>
   requires CONDITION ==K bool2Word ( N:Int <=Int I:Int )
    andBool PROGRAM   ==K #binRuntime
    andBool JUMPDESTS ==K #computeValidJumpDests ( #binRuntime )
    andBool RESULT    ==Int I *Int (I +Int 1) /Int 2
    andBool 0 <=Int N andBool N <Int 2 ^Int 128
    andBool 0 <=Int I andBool I <=Int N
    andBool #sizeWordStack(WS) <Int 1013
   [priority(30)]

endmodule
```

To prove `check_equivalence` using this rule, as said in the main README, you can run the following from the project root:
1. Build the project with the correct flags. Note that we're `--requires`ing two files:
   ```
   kontrol build --require src/GaussSpecCode.md --require src/invariant.md --module-import GaussSpec:GAUSS-INVARIANT --regen --rekompile --verbose
   ```
2. Run the proof with `kontrol`. Note the absence of `--bmc-depth`:
   ```
   kontrol prove --mt GaussSpec.check_equivalence --verbose
   ```
