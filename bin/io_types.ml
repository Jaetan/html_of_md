(** A module providing concrete implementations for handling different input and output types, such as files, directories, or streams. *)

(** Concrete type representing an input source.
    - [Stdin] represents standard input.
    - [InputFile of string] represents a file input.
    - [InputDir of string] represents a directory input. *)
type input = Stdin | InputFile of string | InputDir of string

(** Concrete type representing an output target.
    - [Stdout] represents standard output.
    - [OutputFile of string] represents a file output.
    - [OutputDir of string] represents a directory output. *)
type output = Stdout | OutputFile of string | OutputDir of string

(** [input_of_string s] constructs an {!input} from the string [s].
    - If [s] is "-" it returns [Stdin].
    - If [s] is a directory, it returns [InputDir s].
    - Otherwise, it returns [InputFile s].

    @param s the string describing the input source
    @return the constructed input *)
let input_of_string input_str =
  if input_str = "-" then Stdin else if Sys.is_directory input_str then InputDir input_str else InputFile input_str

(** [output_of_string s] constructs an {!output} from the string [s].
    - If [s] is "-" it returns [Stdout].
    - If [s] is a directory, it returns [OutputDir s].
    - Otherwise, it returns [OutputFile s].

    @param s the string describing the output target
    @return the constructed output *)
let output_of_string output_str =
  if output_str = "-" then Stdout else if Sys.is_directory output_str then OutputDir output_str else OutputFile output_str

(** [validate_input_output input output] checks if the combination of {!input} and {!output} is valid.
    Valid combinations include:
    - [Stdin] with [Stdout] or [OutputFile].
    - [InputFile] with [Stdout] or [OutputFile].
    - [InputDir] with [OutputDir].

    @param input the input source to validate
    @param output the output target to validate
    @return [Ok ()] if the combination is valid, or [Error msg] if not *)
let validate_input_output input output =
  match (input, output) with
  | Stdin, Stdout | Stdin, OutputFile _ ->
      Ok ()
  | InputFile _, Stdout | InputFile _, OutputFile _ ->
      Ok ()
  | InputDir _, OutputDir _ ->
      Ok ()
  | _ ->
      Error "Invalid input-output combination"

(** [handle_input handle_stdin handle_file handle_dir input] processes the given {!input} based on its type.
    - Calls [handle_stdin] for [Stdin].
    - Calls [handle_file] for an input file.
    - Calls [handle_dir] for an input directory.

    @param handle_stdin function to call for standard input
    @param handle_file function to call for file input
    @param handle_dir function to call for directory input
    @param input the input to handle
    @return the result of the appropriate function *)
let handle_input handle_stdin handle_file handle_dir = function
  | Stdin ->
      handle_stdin ()
  | InputFile filename ->
      handle_file filename
  | InputDir dir ->
      handle_dir dir

(** [handle_output handle_stdout handle_file handle_dir output] processes the given {!output} based on its type.
    - Calls [handle_stdout] for [Stdout].
    - Calls [handle_file] for an output file.
    - Calls [handle_dir] for an output directory.

    @param handle_stdout function to call for standard output
    @param handle_file function to call for file output
    @param handle_dir function to call for directory output
    @param output the output to handle
    @return the result of the appropriate function *)
let handle_output handle_stdout handle_file handle_dir = function
  | Stdout ->
      handle_stdout ()
  | OutputFile filename ->
      handle_file filename
  | OutputDir dir ->
      handle_dir dir
