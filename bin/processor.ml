open Html_of_md.Markdown_functor
open Html_of_md.Select_parser
open Io_types

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
    handle_input
      (fun () ->
        handle_output
          (fun () -> handle_markdown stdin stdout) (* g1: Stdin to Stdout *)
          (fun out_filename -> handle_with_channels None (Some out_filename)) (* g2: Stdin to OutputFile *)
          (fun _dir -> Error "Invalid output") (* g3: Stdin to OutputDir (error) *)
          output ) (* Pass the output argument here *)
      (fun in_filename ->
        handle_output
          (fun () -> handle_with_channels (Some in_filename) None) (* g'1: InputFile to Stdout *)
          (fun out_filename -> handle_with_channels (Some in_filename) (Some out_filename) )
            (* g'2: InputFile to OutputFile *)
          (fun _dir -> Error "Invalid output") (* g'3: InputFile to OutputDir (error) *)
          output ) (* Pass the output argument here *)
      (fun _dir ->
        handle_output
          (fun () -> Error "Invalid output") (* g''1: InputDir to Stdout (error) *)
          (fun _out_filename -> Error "Invalid output") (* g''2: InputDir to OutputFile (error) *)
          (fun _dir_out -> Error "Internal inconsistency: InputDir to OutputDir in process_file" )
            (* g''3: InputDir to OutputDir (error) *)
          output ) (* Pass the output argument here *)
      input
  in
  let process_directory dir_in dir_out =
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
              let input = input_of_string input_path in
              let output = output_of_string output_path in
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
  let handle_input_dir_error input =
    match get_input_dir input with
    | Some dir ->
        Ok dir
    | None ->
        Error ["Invalid input: cannot get directory from a file or a common stream (stdin/stdout)."]
  in
  match validate_input_output input output with
  | Ok () ->
      handle_input
        (fun () ->
          handle_output
            (fun () ->
              (* Handle input as stdin and output as stdout *)
              process_file input output |> Result.map_error (fun msg -> [msg]) )
            (fun output_file ->
              (* Handle input as stdin and output as file *)
              process_file input (output_of_string output_file) |> Result.map_error (fun msg -> [msg]) )
            (fun output_dir ->
              (* Handle input as stdin and output as directory *)
              match handle_input_dir_error input with
              | Ok dir ->
                  process_directory dir output_dir
              | Error msg ->
                  Error msg )
            output )
        (fun input_file ->
          handle_output
            (fun () ->
              (* Handle input as file and output as stdout *)
              process_file (input_of_string input_file) output |> Result.map_error (fun msg -> [msg]) )
            (fun output_file ->
              (* Handle input as file and output as file *)
              process_file input (output_of_string output_file) |> Result.map_error (fun msg -> [msg]) )
            (fun output_dir ->
              (* Handle input as file and output as directory *)
              match handle_input_dir_error input with
              | Ok dir ->
                  process_directory dir output_dir
              | Error msg ->
                  Error msg )
            output )
        (fun _dir ->
          (* Handle input as directory *)
          handle_output
            (fun () -> Error ["Invalid output"]) (* InputDir to Stdout (error) *)
            (fun _out_filename -> Error ["Invalid output"]) (* InputDir to OutputFile (error) *)
            (fun output_dir ->
              (* InputDir to OutputDir; process the directory *)
              match handle_input_dir_error input with
              | Ok dir ->
                  process_directory dir output_dir
              | Error msg ->
                  Error msg )
            output )
        input
  | Error msg ->
      Error [msg]
(* Wrap the validation error message in a list *)
