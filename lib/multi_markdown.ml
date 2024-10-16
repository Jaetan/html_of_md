open Markdown_parser

module MultiMarkdown : MarkdownParser = struct
  type ast = CommonMarkAST

  type token = CommonMarkToken

  let tokenize _ = [CommonMarkToken] (* Implement CommonMark-specific tokenization *)

  let parse _ = CommonMarkAST (* Implement CommonMark-specific parsing *)

  let to_html _ = "" (* Convert CommonMark-specific AST to HTML *)
end
