import Lean.Elab.Command
import Mathlib.Data.Nat.Basic

open Lean Parser

namespace Plonky3

def runAsCommand (command_string: String) (loc: Syntax) (log: Bool := false): Elab.Command.CommandElabM Unit := do
  if log then logInfo m!"Running command:\n{command_string}"
  let .ok command_string_stx := runParserCategory (← getEnv) `command command_string
    | throwError s!"Failed to parse command {command_string}"

  -- Attempted brute force of giving the generated command the location of the macro
  -- since elabCommand already includes withRef and withLogging
  let .some headPos := loc.getPos?
    | throwError s!"Unable to get pos of loc in runAsCommand"
  let .some tailPos := loc.getTailPos?
    | throwError s!"Unable to get tailPos of loc in runAsCommand"

  let .some command_string_stx := command_string_stx.replaceM (λ x => Option.some (match x with
    | .node (SourceInfo.none) syntaxNodeKind children =>
      Lean.Syntax.node (SourceInfo.synthetic headPos tailPos) syntaxNodeKind children
    | _ => x
  ))
    | throwError s!"Failed to assign ref to {command_string}"
  let command_string_tstx : TSyntax `command := ⟨command_string_stx⟩

  match command_string_tstx.raw with
    | .missing => logInfo m!"Missing"
    | .node sourceInfo syntaxNodeKind children => match sourceInfo with
      | .original a b c d => logInfo m!"Original"
      | .synthetic a b => logInfo m!"Synthetic {a} {b}"
      | _ => logInfo m!"None"
    | .atom a b => logInfo m!"Atom"
    | .ident a b c d => logInfo m!"Ident"

  -- logInfo m!"Command TSyntax: {command_string_tstx.raw}"
  withRef loc (Lean.Elab.Command.elabCommand command_string_tstx)
  -- let msgs := (← get).messages
  -- msgs.reported.forM (λ x => logInfo m!"Reported: {x.data}")
  -- msgs.unreported.forM (λ x => logInfo m!"Unreported: {x.data}")

/--
Converts a numeric index into an accessor in a nested structure
Note that the structure must have a placeholder final member for this to work
e.g. this will work to get the third element from a ∧ b ∧ c ∧ d ∧ true,
but not to get the third element from a ∧ b ∧ c
-/
def transformIndex (n: ℕ): String :=
  match n with
    | 0 => ".1"
    | m+1 =>
      let r := transformIndex m
      s!".2{r}"
end Plonky3

-- elab start:("Exercise"<|>"Example") str
--     "Given:" objs:bracketedBinder*
--     "Assume:" hyps:bracketedBinder*
--     "Conclusion:" concl:term
--     tkp:"Proof:" prf?:(tacticSeq)? tk:"QED" : command => do
--   let ref := mkNullNode #[]
--   let prf ← prf?.getDM <| withRef ref `(tacticSeq| skip)
--   let term ← withRef start `(by%$ref
--     skip%$ref
--     ($prf)
--     skip%$ref)
--   Lean.Elab.Command.elabCommand (← `(command|example $(objs ++ hyps):bracketedBinder* : $concl := $term))

-- Exercise "Test"
--   Given: (n : Nat)
--   Assume: (h : n = 0)
--   Conclusion: True
-- Proof: QED
