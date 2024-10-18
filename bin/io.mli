type input = Stdin | InputFile of string | InputDir of string

type output = Stdout | OutputFile of string | OutputDir of string

val input_of_string : string -> input

val output_of_string : string -> output

val validate_input_output : input -> output -> (unit, string) result
