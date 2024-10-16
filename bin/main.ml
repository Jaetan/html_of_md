open Cmdliner
open Html_of_md.Flavour
open Html_of_md.Markdown_functor
open Html_of_md.Select_parser

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
let main (flavour, input, output, input_enc, output_enc) =
  Format.printf "Markdown flavour: %a\n" pp_flavour flavour ;
  Format.printf "Input: %s\n" input ;
  Format.printf "Output: %s\n" output ;
  Format.printf "Input Encoding: %s\n" input_enc ;
  Format.printf "Output Encoding: %s\n" output_enc ;
  let (module Parser) = select_parser flavour in
  let module Processor = MakeMarkdownProcessor (Parser) in
  let output = Processor.process input in
  print_endline output ; `Ok ()

(* Define the command-line interface *)
let cmd =
  let doc = "A markdown to HTML converter." in
  let info = Cmd.info "html_of_md" ~version:"1.0" ~doc in
  Cmd.v info Term.(ret (const main $ args_t))

(* Execute the program *)
let () = exit (Cmd.eval cmd)
