(* Abstract types *)
type input

type output

(* Constructors *)
val input_of_string : string -> input

val output_of_string : string -> output

val validate_input_output : input -> output -> (unit, string) result

(* New handling functions *)
val handle_input : (unit -> 'a) -> (string -> 'a) -> (string -> 'a) -> input -> 'a
(* The function will call:
   - the first function for `Stdin`
   - the second function for `InputFile`
   - the third function for `InputDir`
*)

val handle_output : (unit -> 'a) -> (string -> 'a) -> (string -> 'a) -> output -> 'a
(* Similar structure for `output`:
   - first function for `Stdout`
   - second for `OutputFile`
   - third for `OutputDir`
*)

val handle_input_if_dir : input -> (string -> 'a) -> 'a option

val handle_output_if_dir : output -> (string -> 'a) -> 'a option

val get_input_dir : input -> string option
