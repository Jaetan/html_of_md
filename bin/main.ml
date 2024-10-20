(**
  Entry point for the Markdown to HTML converter.

  This module serves as the command-line interface for the Markdown to HTML conversion
  program. It utilizes the Cmdliner library to define command-line arguments, including
  the markdown flavour, input and output sources, and their encodings. The specified
  arguments are parsed and passed to the processing function to convert the input
  Markdown into HTML format.

  @see: Html_of_md.Flavour for markdown flavour definitions.
  @see: Io_types for input and output type handling.
  @see: Processor for the main processing logic.
*)
open Cmdliner

open Html_of_md.Flavour
open Io_types
open Processor

(* Cmdliner converter for flavour *)
let flavour = Arg.conv (flavour_of_string, pp_flavour)

(* Cmdliner argument definitions *)
let flavour_arg =
  let doc =
    "Specify the markdown flavour to use. Possible values are: gfm, commonmark, pandoc, original, multimarkdown, markdownextra, rmarkdown."
  in
  Arg.(required & pos 0 (some flavour) None & info [] ~docv:"FLAVOUR" ~doc)

(** Cmdliner argument definition for input source. *)
let input_arg =
  let doc = "Input file or directory, or '-' for stdin." in
  Arg.(value & opt string "-" & info ["input"; "i"] ~docv:"INPUT" ~doc)

(** Cmdliner argument definition for output destination. *)
let output_arg =
  let doc = "Output file or directory, or '-' for stdout." in
  Arg.(value & opt string "-" & info ["output"; "o"] ~docv:"OUTPUT" ~doc)

(** Cmdliner argument definition for specifying input encoding. *)
let input_encoding_arg =
  let doc = "Specify the input encoding (default is utf-8)." in
  Arg.(value & opt string "utf-8" & info ["input-encoding"] ~docv:"ENCODING" ~doc)

(** Cmdliner argument definition for specifying output encoding. *)
let output_encoding_arg =
  let doc = "Specify the output encoding (default is utf-8)." in
  Arg.(value & opt string "utf-8" & info ["output-encoding"] ~docv:"ENCODING" ~doc)

(**
  Combine the command-line arguments into a tuple for easier access in the main function.
*)
let args_t =
  let open Term in
  const (fun flavour input output input_enc output_enc -> (flavour, input, output, input_enc, output_enc))
  $ flavour_arg $ input_arg $ output_arg $ input_encoding_arg $ output_encoding_arg

(**
  Main function to process the command.

  This function receives the parsed command-line arguments, initializes the input and
  output types, and invokes the processing logic. It also handles logging of errors
  during the conversion process.

  @param flavour the markdown flavour to use for processing.
  @param input_str the input source (file, directory, or stdin).
  @param output_str the output destination (file, directory, or stdout).
  @param input_enc the specified input encoding.
  @param output_enc the specified output encoding.
  @return a Cmdliner exit code indicating success or failure.
*)
let main (flavour, input_str, output_str, input_enc, output_enc) =
  let input = input_of_string input_str in
  let output = output_of_string output_str in
  Format.printf "Markdown flavour: %a\n" pp_flavour flavour ;
  Format.printf "Input: %s\n" input_str ;
  Format.printf "Output: %s\n" output_str ;
  Format.printf "Input Encoding: %s\n" input_enc ;
  Format.printf "Output Encoding: %s\n" output_enc ;
  match process flavour input output with
  | Ok () ->
      `Ok ()
  | Error errors ->
      List.iter (fun msg -> Format.printf "Error: %s\n" msg) errors ;
      `Error (false, String.concat ", " errors)

(**
  Define the command-line interface for the converter.

  This function sets up the command with its description and versioning information.
*)
let cmd =
  let doc = "A markdown to HTML converter." in
  let info = Cmd.info "html_of_md" ~version:"1.0" ~doc in
  Cmd.v info Term.(ret (const main $ args_t))

let () = exit (Cmd.eval cmd)
