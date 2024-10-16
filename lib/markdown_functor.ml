open Markdown_parser

module MakeMarkdownProcessor (Parser : MarkdownParser) = struct
  let process input =
    let tokens = Parser.tokenize input in
    let ast = Parser.parse tokens in
    Parser.to_html ast
end
