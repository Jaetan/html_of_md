open Markdown_parser

module Gfm : MarkdownParser = struct
  type ast = GfmAST

  type token = GfmToken

  let tokenize _ = [GfmToken] (* Implement GFM-specific tokenization *)

  let parse _ = GfmAST (* Implement GFM-specific parsing *)

  let to_html _ = "" (* Convert GFM-specific AST to HTML *)
end
