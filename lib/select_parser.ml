(** A module responsible for selecting the appropriate Markdown parser based on the given
    Markdown flavour. Each flavour corresponds to a different parsing strategy that
    implements the {!MarkdownParser} signature. *)

open Markdown_parser
open Gfm
open Common_mark
open Pandoc
open Original
open Multi_markdown
open Markdown_extra
open R_markdown
open Flavour

(** [select_parser flavour] returns the appropriate Markdown parser module
    for the specified {!Flavour.flavour}. Each flavour is mapped to a distinct
    parser that implements the {!MarkdownParser} signature.

    @param flavour the Markdown flavour to select the parser for
    @return a first-class module that implements the {!MarkdownParser} signature *)
let select_parser flavour =
  match flavour with
  | GFM ->
      (module Gfm : MarkdownParser)
  | CommonMark ->
      (module CommonMark : MarkdownParser)
  | Pandoc ->
      (module Pandoc : MarkdownParser)
  | Original ->
      (module Original : MarkdownParser)
  | MultiMarkdown ->
      (module MultiMarkdown : MarkdownParser)
  | MarkdownExtra ->
      (module MarkdownExtra : MarkdownParser)
  | RMarkdown ->
      (module RMarkdown : MarkdownParser)
