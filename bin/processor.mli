(**
  Module for processing Markdown documents.

  This module defines the `process` function that takes a specified markdown flavour
  and processes the input according to the provided input and output types.

  The processing involves tokenizing the input, parsing it into an abstract syntax tree (AST),
  and converting the AST to HTML based on the selected markdown flavour.

  @see: Html_of_md.Flavour for the list of available markdown flavours.
  @see: Io_types for the definitions of input and output types.
*)

open Html_of_md.Flavour
open Io_types

val process : flavour -> input -> output -> (unit, string list) result
(**
  Processes a Markdown document based on the specified flavour and input/output types.

  @param flavour the markdown flavour to be used for processing.
  @param input the input type which can be stdin, a file, or a directory.
  @param output the output type which can be stdout, a file, or a directory.
  @return a result indicating success (unit) or an error with a list of error messages.
*)
