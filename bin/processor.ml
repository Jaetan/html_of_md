(**
  Module for processing Markdown documents with different flavours.

  This module provides functionality to process Markdown content based on a specified
  flavour and handles various input and output types (stdin, files, and directories).
  It utilizes a parser module selected according to the given flavour to convert
  Markdown into HTML.

  The processing flow involves tokenizing the input, parsing it into an abstract
  syntax tree (AST), and converting the AST to HTML.

  @see: Html_of_md.Flavour for the available markdown flavours.
  @see: Io_types for the definitions of input and output types.
*)

open Html_of_md.Markdown_functor
open Html_of_md.Select_parser
open Io_types

(**
  Processes a Markdown document based on the specified flavour and input/output types.

  This function orchestrates the reading of input data, processing it into HTML, and
  writing the output to the specified destination. It supports various combinations
  of input and output types, including stdin, files, and directories.

  @param flavour the markdown flavour to be used for processing.
  @param input the input type which can be stdin, a file, or a directory.
  @param output the output type which can be stdout, a file, or a directory.
  @return a result indicating success (unit) or an error with a list of error messages.
*)
let process flavour input output =
  let (module Parser) = select_parser flavour in
  let module Processor = MakeMarkdownProcessor (Parser) in
  (*
   * Handles the processing of Markdown input.
   *
   * @param input_channel: The input channel from which Markdown data is read.
   * @param output_channel: The output channel where the processed result is written.
   *
   * This closure creates a UTF-8 decoder for the input channel, processes the
   * Markdown content using the `Processor.process` function, and writes the
   * resulting output to the output channel. It returns `Ok ()` upon successful
   * completion.
   *)
  let handle_markdown input_channel output_channel =
    let decoder = Uutf.decoder ~encoding:`UTF_8 (`Channel input_channel) in
    let result = Processor.process decoder in
    output_string output_channel result ; Ok ()
  in
  (*
   * Manages the opening of input and output files, and delegates the handling
   * of Markdown processing to the appropriate channels.
   *
   * @param input_filename: An optional string representing the name of the input
   *                        file to read Markdown content from.
   * @param output_filename: An optional string representing the name of the
   *                         output file to write processed Markdown content to.
   *
   * This closure uses helper functions to safely open input and output files. It
   * handles different combinations of provided filenames:
   * - Both provided: Opens both files and processes the input.
   * - Input provided, output not: Processes input and writes to stdout.
   * - Output provided, input not: Reads from stdin and writes to the output file.
   * - Neither provided: Reads from stdin and writes to stdout.
   *
   * If there is an error opening a file, it returns an `Error` with a descriptive
   * message.
   *)
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
  (*
   * Processes a file based on the provided input and output specifications.
   * It utilizes helper functions to manage input and output handling and
   * directs the processing of Markdown content accordingly.
   *
   * @param input: The input specification which can represent stdin, a file,
   *                or a directory.
   * @param output: The output specification which can represent stdout, a
   *                 file, or a directory.
   *
   * The closure employs a series of nested function calls to determine the
   * correct input-output handling based on the provided parameters:
   *
   * - If input is from stdin:
   *   - If output is stdout, it processes Markdown directly from stdin to stdout.
   *   - If output is a file, it processes from stdin to the specified output file.
   *   - If output is a directory, it returns an error indicating invalid output.
   *
   * - If input is from a file:
   *   - If output is stdout, it processes from the input file to stdout.
   *   - If output is a file, it processes from the input file to the specified output file.
   *   - If output is a directory, it returns an error indicating invalid output.
   *
   * - If input is from a directory:
   *   - It returns an error for all output specifications since this function only handles one file.
   *
   * This structure allows for a flexible processing of input and output while
   * maintaining error handling for invalid scenarios.
   *)
  let process_file input output =
    handle_input
      (fun () ->
        handle_output
          (fun () -> handle_markdown stdin stdout)
          (fun out_filename -> handle_with_channels None (Some out_filename))
          (fun _dir -> Error "Invalid output")
          output )
      (fun in_filename ->
        handle_output
          (fun () -> handle_with_channels (Some in_filename) None)
          (fun out_filename -> handle_with_channels (Some in_filename) (Some out_filename))
          (fun _dir -> Error "Invalid output")
          output )
      (fun _dir -> Error "Invalid output" (* Directly return error since input must be a file *))
      input
  in
  (*
   * Processes all files and subdirectories within a specified input directory,
   * directing the output to a corresponding output directory. It recursively
   * traverses the directory structure, handling each file and directory appropriately.
   *
   * @param dir_in: The input directory to process, containing files and subdirectories.
   * @param dir_out: The output directory where processed files will be saved,
   *                  mirroring the structure of the input directory.
   *)
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
              process_dir input_path output_path )
            else
              let input = input_of_string input_path in
              let output = output_of_string output_path in
              match process_file input output with Ok () -> Ok () | Error msg -> Error [msg]
          in
          match (result, acc) with
          | Ok (), Ok () ->
              Ok () (* Both current and previous operations succeeded. *)
          | Ok (), Error errors ->
              Error errors (* Current operation succeeded, previous errors remain. *)
          | Error msg, Ok () ->
              Error msg (* Current operation failed, return its error. *)
          | Error msg, Error errors ->
              Error (msg @ errors) )
        (Ok ())
        items
    in
    process_dir dir_in dir_out
  in
  match validate_input_output input output with
  | Ok () ->
      handle_input
        (fun () ->
          handle_output
            (fun () ->
              process_file input output |> Result.map_error (fun msg -> [msg]) )
            (fun output_file ->
              process_file input (output_of_string output_file) |> Result.map_error (fun msg -> [msg]) )
            (fun _output_dir ->
              Error ["Invalid output: cannot output to a directory when input is from stdin."] )
            output )
        (fun input_file ->
          handle_output
            (fun () ->
              process_file (input_of_string input_file) output |> Result.map_error (fun msg -> [msg]) )
            (fun output_file ->
              process_file input (output_of_string output_file) |> Result.map_error (fun msg -> [msg]) )
            (fun _output_dir ->
              Error ["Invalid output: cannot output to a directory when input is a file."] )
            output )
        (fun input_dir ->
          handle_output
            (fun () -> Error ["Invalid output (input directory to stdout)"]) (* InputDir to Stdout (error) *)
            (fun _out_filename -> Error ["Invalid output (input directory to output file)"]) (* InputDir to OutputFile (error) *)
            (fun output_dir ->
              process_directory input_dir output_dir )
            output )
        input
  | Error msg ->
      Error [msg]
