open Html_of_md.Flavour
open Io_types

val process : flavour -> input -> output -> (unit, string list) result
