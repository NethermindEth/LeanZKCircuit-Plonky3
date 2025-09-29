import LeanZKCircuit_Plonky3.Plonky3.Circuit
import LeanZKCircuit_Plonky3.Plonky3.Command.Air.define_air

open Plonky3

-- #define_subair? "TestSubAirType" using "plonky3_encapsulation" where
--   Column["test_subcolumn"]

-- #define_air? "TestCircuit" using "plonky3_encapsulation" where
--   Column["test_column"]
--   MainSubAir["test_subair" : "TestSubAirType" width := 3]
--   PreprocessedSubAir["p_subair" : "TestSubAirType" width := 3]
