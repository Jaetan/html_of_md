type input = Stdin | InputFile of string | InputDir of string

type output = Stdout | OutputFile of string | OutputDir of string

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
