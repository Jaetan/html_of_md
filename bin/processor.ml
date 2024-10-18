open Io
open Html_of_md.Select_parser
open Html_of_md.Markdown_functor

let process flavour input output =
  let (module Parser) = select_parser flavour in
  let module Processor = MakeMarkdownProcessor (Parser) in
  let handle_markdown input_channel output_channel =
    let decoder = Uutf.decoder ~encoding:`UTF_8 (`Channel input_channel) in
    let result = Processor.process decoder in
    output_string output_channel result ; Ok ()
  in
  let handle_with_channels input_filename output_filename =
    let open Result in
    let handle_input_file input_file cont =
      try In_channel.with_open_bin input_file (fun ic -> cont ic)
      with Sys_error msg -> Error ("Failed to open input file: " ^ input_file ^ ": " ^ msg)
    in
    let handle_output_file output_file cont =
      try Out_channel.with_open_bin output_file (fun oc -> cont oc)
      with Sys_error msg -> Error ("Failed to open output file: " ^ output_file ^ ": " ^ msg)
    in
    match (input_filename, output_filename) with
    | Some input_file, Some output_file ->
        handle_input_file input_file (fun ic -> handle_output_file output_file (fun oc -> handle_markdown ic oc))
    | Some input_file, None ->
        handle_input_file input_file (fun ic -> handle_markdown ic stdout)
    | None, Some output_file ->
        handle_output_file output_file (fun oc -> handle_markdown stdin oc)
    | None, None ->
        handle_markdown stdin stdout
  in
  let process_file input output =
    match (input, output) with
    | Stdin, Stdout ->
        handle_markdown stdin stdout
    | Stdin, OutputFile output_filename ->
        handle_with_channels None (Some output_filename)
    | InputFile input_filename, Stdout ->
        handle_with_channels (Some input_filename) None
    | InputFile input_filename, OutputFile output_filename ->
        handle_with_channels (Some input_filename) (Some output_filename)
    | _ ->
        Error "Invalid input/output combination"
  in
  let process_directory dir_in dir_out process_file =
    let rec process_dir in_dir out_dir =
      let items = Sys.readdir in_dir in
      Array.fold_left
        (fun acc item ->
          let input_path = Filename.concat in_dir item in
          let output_path = Filename.concat out_dir item in
          let result =
            if Sys.is_directory input_path then (
              if not (Sys.file_exists output_path) then Unix.mkdir output_path 0o755 ;
              process_dir input_path output_path (* Continue processing subdirectories *) )
            else
              let input = InputFile input_path in
              let output = OutputFile output_path in
              match process_file input output with
              | Ok () ->
                  Ok () (* No error, return Ok without accumulating messages *)
              | Error msg ->
                  Error [msg]
            (* Wrap the error message in a list *)
          in
          match (result, acc) with
          | Ok (), Ok () ->
              Ok () (* Both succeeded *)
          | Ok (), Error errors ->
              Error errors (* Previous errors remain *)
          | Error msg, Ok () ->
              Error msg (* Current error, no previous errors *)
          | Error msg, Error errors ->
              Error (msg @ errors)
          (* Concatenate error lists *) )
        (Ok ()) (* Initial accumulator is Ok () for success without errors *)
        items
    in
    match process_dir dir_in dir_out with
    | Ok () ->
        Ok () (* No errors found *)
    | Error errors ->
        Error (List.rev errors)
    (* Return the list of errors, reversed for original order *)
  in
  match validate_input_output input output with
  | Ok () -> (
    match (input, output) with
    | InputDir dir_in, OutputDir dir_out ->
        (* Call process_directory and propagate the result directly *)
        process_directory dir_in dir_out process_file
    | _ -> (
      (* Use the flattened result from process_file *)
      match process_file input output with
      | Ok () ->
          Ok () (* Success case *)
      | Error msg ->
          Error [msg] (* Wrap the error message in a list *) ) )
  | Error msg ->
      Error [msg]
(* Wrap the validation error message in a list *)
