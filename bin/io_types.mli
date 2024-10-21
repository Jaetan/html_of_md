(** A module defining types and functions for handling input and output sources such as files, directories, or streams. *)

(** Abstract type representing an input source, such as a file, directory, or standard input. *)
type input

(** Abstract type representing an output target, such as a file, directory, or standard output. *)
type output

val input_of_string : string -> input
(** [input_of_string s] constructs an {!input} from the string [s].
    The string can represent a file path, directory, or standard input.

    @param s the string describing the input source
    @return the constructed input *)

val output_of_string : string -> output
(** [output_of_string s] constructs an {!output} from the string [s].
    The string can represent a file path, directory, or standard output.

    @param s the string describing the output target
    @return the constructed output *)

val validate_input_output : input -> output -> (unit, string) result
(** [validate_input_output input output] checks if the combination of {!input} and {!output} is valid.

    @param input the input source to validate
    @param output the output target to validate
    @return [Ok ()] if the combination is valid, or [Error msg] if not *)

val handle_input : (unit -> 'a) -> (string -> 'a) -> (string -> 'a) -> input -> 'a
(** [handle_input f_stdin f_input_file f_input_dir input] processes the given {!input} based on its type:
    - Calls [f_stdin] for standard input.
    - Calls [f_input_file] for an input file.
    - Calls [f_input_dir] for an input directory.

    @param f_stdin the function to call for standard input
    @param f_input_file the function to call for an input file
    @param f_input_dir the function to call for an input directory
    @param input the input to handle *)

val handle_output : (unit -> 'a) -> (string -> 'a) -> (string -> 'a) -> output -> 'a
(** [handle_output f_stdout f_output_file f_output_dir output] processes the given {!output} based on its type:
    - Calls [f_stdout] for standard output.
    - Calls [f_output_file] for an output file.
    - Calls [f_output_dir] for an output directory.

    @param f_stdout the function to call for standard output
    @param f_output_file the function to call for an output file
    @param f_output_dir the function to call for an output directory
    @param output the output to handle *)
