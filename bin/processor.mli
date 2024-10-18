open Io
open Html_of_md.Flavour

val process_file : flavour -> input -> output -> (unit, string) result

val process_directory :
  flavour -> string -> string -> (flavour -> input -> output -> (unit, string) result) -> (unit, string list) result

val process : flavour -> input -> output -> (unit, string list) result
