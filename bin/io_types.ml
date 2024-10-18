(* Concrete type definitions *)
type input = Stdin | InputFile of string | InputDir of string

type output = Stdout | OutputFile of string | OutputDir of string

(* Existing functions *)
let input_of_string input_str =
  if input_str = "-" then Stdin else if Sys.is_directory input_str then InputDir input_str else InputFile input_str

let output_of_string output_str =
  if output_str = "-" then Stdout
  else if Sys.is_directory output_str then OutputDir output_str
  else OutputFile output_str

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

(* New handling functions *)

let handle_input handle_stdin handle_file handle_dir = function
  | Stdin ->
      handle_stdin ()
  | InputFile filename ->
      handle_file filename
  | InputDir dir ->
      handle_dir dir

let handle_output handle_stdout handle_file handle_dir = function
  | Stdout ->
      handle_stdout ()
  | OutputFile filename ->
      handle_file filename
  | OutputDir dir ->
      handle_dir dir

let handle_input_if_dir input f =
  match input with
  | InputDir dir ->
      Some (f dir) (* Call the function with the directory *)
  | _ ->
      None (* Return None for non-directory inputs *)

let handle_output_if_dir output f =
  match output with
  | OutputDir dir ->
      Some (f dir) (* Call the function with the directory *)
  | _ ->
      None (* Return None for non-directory outputs *)

let get_input_dir = function InputDir dir -> Some dir | _ -> None (* Return None for InputFile and Stdin *)
