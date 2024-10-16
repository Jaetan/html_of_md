open Markdown_parser

module Pandoc : MarkdownParser = struct
  type ast = PandocAST

  type token = PandocToken

  let tokenize _ = [PandocToken] (* Implement Pandoc-specific tokenization *)

  let parse _ = PandocAST (* Implement Pandoc-specific parsing *)

  let to_html _ = "" (* Convert Pandoc-specific AST to HTML *)
end
