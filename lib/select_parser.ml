open Markdown_parser
open Gfm
open Common_mark
open Pandoc
open Original
open Multi_markdown
open Markdown_extra
open R_markdown
open Flavour

let select_parser (flav : flavour) =
  match flav with
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
