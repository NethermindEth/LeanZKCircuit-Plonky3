import LeanZKCircuit_Plonky3.Plonky3.Command.Air.Syntax.air_definition
import LeanZKCircuit_Plonky3.Plonky3.Command.util

open Lean

namespace Plonky3
  def create_air_base_member_projection_lemma
    (circuit: String) (simp_attribute: String) (member: String) (loc: Syntax) (log : Bool := false)
  : Elab.Command.CommandElabM Unit := do
    let lemma_string :=
      s!"@[{simp_attribute}]\n" ++
      s!"lemma {circuit}_{member}_project {"{"}F ExtF{"}"}\n" ++
      s!"  (c: {circuit} F ExtF) [Field F] [Field ExtF] :\n" ++
      s!"@Circuit.{member} F (by assumption) ExtF (by assumption) {circuit} _ c = c.{member} :=\n" ++
      s!"  rfl"
    runAsCommand lemma_string loc log

  def create_all_air_base_member_projection_lemmas
    (circuit: String) (simp_attribute: String) (loc: Syntax) (log : Bool := false)
  : Elab.Command.CommandElabM Unit := do
    create_air_base_member_projection_lemma circuit simp_attribute "bus" loc log
    create_air_base_member_projection_lemma circuit simp_attribute "challenge" loc log
    create_air_base_member_projection_lemma circuit simp_attribute "main" loc log
    create_air_base_member_projection_lemma circuit simp_attribute "permutation" loc log
    create_air_base_member_projection_lemma circuit simp_attribute "preprocessed" loc log
    create_air_base_member_projection_lemma circuit simp_attribute "public_values" loc log
    create_air_base_member_projection_lemma circuit simp_attribute "last_row" loc log

  def create_all_air_valid_base_member_projection_lemmas
    (defn: AirDefinition) (loc: Syntax) (log : Bool := false)
  : Elab.Command.CommandElabM Unit := do
    create_all_air_base_member_projection_lemmas s!"Valid_{defn.name}" defn.simp_attribute loc log
end Plonky3
