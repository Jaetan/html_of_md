open Markdown_parser

module Original : MarkdownParser = struct
  type ast = OriginalAST

  type token = OriginalToken

  let tokenize _ = [OriginalToken] (* Implement Original-specific tokenization *)

  let parse _ = OriginalAST (* Implement Original-specific parsing *)

  let to_html _ = "" (* Convert Original-specific AST to HTML *)
end
