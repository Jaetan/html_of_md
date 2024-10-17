open Cmdliner
open Html_of_md.Flavour
open Html_of_md.Markdown_functor
open Html_of_md.Select_parser

type input = Stdin | InputFile of string | InputDir of string

type output = Stdout | OutputFile of string | OutputDir of string

(* Converts a string into the appropriate input type *)
let input_of_string input_str =
  if input_str = "-" then Stdin else if Sys.is_directory input_str then InputDir input_str else InputFile input_str

(* Converts a string into the appropriate output type *)
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
      Error (`Msg "Invalid input-output combination")

let process_file flavour input output =
  let open_input_channel = function
    | Stdin ->
        stdin
    | InputFile filename -> (
      try open_in filename with Sys_error msg -> failwith ("Error opening input file: " ^ filename ^ ". " ^ msg) )
    | InputDir dirname ->
        failwith ("Error: Cannot open directory '" ^ dirname ^ "' as input channel")
  in
  let open_output_channel = function
    | Stdout ->
        stdout
    | OutputFile filename -> (
      try open_out filename with Sys_error msg -> failwith ("Error opening output file: " ^ filename ^ ". " ^ msg) )
    | OutputDir dirname ->
        failwith ("Error: Cannot open directory '" ^ dirname ^ "' as output channel")
  in
  let ic = open_input_channel input in
  let oc = open_output_channel output in
  try
    let (module Parser) = select_parser flavour in
    let module Processor = MakeMarkdownProcessor (Parser) in
    let result = Processor.process ic in
    output_string oc result ; close_in_noerr ic ; close_out_noerr oc ; Ok ()
  with e -> close_in_noerr ic ; close_out_noerr oc ; raise e

let process_directory flavour dir_in dir_out process_file =
  let rec process_dir in_dir out_dir =
    let items = Sys.readdir in_dir in
    Array.iter
      (fun item ->
        let input_path = Filename.concat in_dir item in
        let output_path = Filename.concat out_dir item in
        if Sys.is_directory input_path then (
          (* Recursively process subdirectory *)
          if not (Sys.file_exists output_path) then Unix.mkdir output_path 0o755 ;
          process_dir input_path output_path )
        else
          (* Convert string paths to InputFile and OutputFile *)
          let input = InputFile input_path in
          let output = OutputFile output_path in
          (* Process individual file *)
          process_file flavour input output |> ignore )
      items
  in
  process_dir dir_in dir_out

let process flavour input output =
  match validate_input_output input output with
  | Ok () -> (
    match (input, output) with
    | InputDir dir_in, OutputDir dir_out ->
        process_directory flavour dir_in dir_out process_file ;
        Ok ()
    | _ ->
        process_file flavour input output )
  | Error (`Msg msg) ->
      Error (`Msg msg)

(* Cmdliner converter for flavour *)
let flavour = Arg.conv (flavour_of_string, pp_flavour)

(* Cmdliner argument definitions *)
let flavour_arg =
  let doc =
    "Specify the markdown flavour to use. Possible values are: gfm, commonmark, pandoc, original, multimarkdown, \
     markdownextra, rmarkdown."
  in
  Arg.(required & pos 0 (some flavour) None & info [] ~docv:"FLAVOUR" ~doc)

let input_arg =
  let doc = "Input file or directory, or '-' for stdin." in
  Arg.(value & opt string "-" & info ["input"; "i"] ~docv:"INPUT" ~doc)

let output_arg =
  let doc = "Output file or directory, or '-' for stdout." in
  Arg.(value & opt string "-" & info ["output"; "o"] ~docv:"OUTPUT" ~doc)

let input_encoding_arg =
  let doc = "Specify the input encoding (default is utf-8)." in
  Arg.(value & opt string "utf-8" & info ["input-encoding"] ~docv:"ENCODING" ~doc)

let output_encoding_arg =
  let doc = "Specify the output encoding (default is utf-8)." in
  Arg.(value & opt string "utf-8" & info ["output-encoding"] ~docv:"ENCODING" ~doc)

(* Combine the arguments into a tuple for easier access in the main function *)
let args_t =
  let open Term in
  const (fun flavour input output input_enc output_enc -> (flavour, input, output, input_enc, output_enc))
  $ flavour_arg $ input_arg $ output_arg $ input_encoding_arg $ output_encoding_arg

(* Main function to process the command *)
let main (flavour, input_str, output_str, input_enc, output_enc) =
  let input = input_of_string input_str in
  let output = output_of_string output_str in
  Format.printf "Markdown flavour: %a\n" pp_flavour flavour ;
  Format.printf "Input: %s\n" input_str ;
  Format.printf "Output: %s\n" output_str ;
  Format.printf "Input Encoding: %s\n" input_enc ;
  Format.printf "Output Encoding: %s\n" output_enc ;
  match process flavour input output with Ok () -> `Ok () | Error (`Msg msg) -> `Error (false, msg)

(* Define the command-line interface *)
let cmd =
  let doc = "A markdown to HTML converter." in
  let info = Cmd.info "html_of_md" ~version:"1.0" ~doc in
  Cmd.v info Term.(ret (const main $ args_t))

(* Execute the program *)
let () = exit (Cmd.eval cmd)
