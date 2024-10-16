open Markdown_parser

module MarkdownExtra : MarkdownParser = struct
  type ast = MarkdownExtraAST

  type token = MarkdownExtraToken

  let tokenize _ = [MarkdownExtraToken] (* Implement MarkdownExtra-specific tokenization *)

  let parse _ = MarkdownExtraAST (* Implement MarkdownExtra-specific parsing *)

  let to_html _ = "" (* Convert MarkdownExtra-specific AST to HTML *)
end
